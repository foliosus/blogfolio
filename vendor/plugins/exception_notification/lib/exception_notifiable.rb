require 'ipaddr'

# Copyright (c) 2005 Jamis Buck. Portions Copyright (c) 2007 Reed College.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
module ExceptionNotifiable
  def self.included(target)
    target.extend(ClassMethods)
    target.send(:append_view_path, ExceptionNotifier::CUSTOM_TEMPLATES_PATH)
  end

  module ClassMethods
    def consider_local(*args)
      local_addresses.concat(args.flatten.map { |a| IPAddr.new(a) })
    end

    def local_addresses
      addresses = read_inheritable_attribute(:local_addresses)
      unless addresses
        addresses = [IPAddr.new("127.0.0.1")]
        write_inheritable_attribute(:local_addresses, addresses)
      end
      addresses
    end

    def exception_data(deliverer=self)
      if deliverer == self
        read_inheritable_attribute(:exception_data)
      else
        write_inheritable_attribute(:exception_data, deliverer)
      end
    end

    def exceptions_to_treat_as_404
      exceptions = [ActiveRecord::RecordNotFound,
                    ActionController::UnknownController,
                    ActionController::UnknownAction]
      exceptions << ActionController::RoutingError
      exceptions
    end
    
    def exceptions_to_treat_as_401
      exceptions = []
      exceptions << AuthenticatedSystem::UserNotAuthorized if const_defined?(:AuthenticatedSystem) && AuthenticatedSystem.const_defined?(:UserNotAuthorized)
    end
  end #ClassMethods

  def local_request?
    remote = IPAddr.new(request.remote_ip)
    !self.class.local_addresses.detect { |addr| addr.include?(remote) }.nil?
  end

  def render_error(code)
    respond_to do |type|
      type.html { render :template => "shared/#{code}.html.erb", :status => code }
      type.all  { render :nothing => true, :status => code }
    end
  end

  def rescue_action_in_public(exception)
    logger.warn("Rescuing in public: #{exception}")
    case exception
      when *self.class.exceptions_to_treat_as_401
        render_error(401)
      when *self.class.exceptions_to_treat_as_404
        render_error(404)
      when ActiveRecord::ConnectionNotEstablished
        render_error(503)
      else          
        render_error(500)

        deliverer = self.class.exception_data
        data = case deliverer
          when nil then {}
          when Symbol then send(deliverer)
          when Proc then deliverer.call(self)
        end

        ExceptionNotifier.deliver_exception_notification(exception, self, request, data)
    end
  end
end