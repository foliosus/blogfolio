# Uniform
module Reed #:nodoc:
  module UniForm
    # = UniFormBuilder
    # Use a standard form markup structure, based on Uni-Form (http://dnevnikeklektika.com/uni-form).  Create two functions for every form item: one with and one without a general wrapper (uniform_wrapper).  Any field can accept some modifiers in the incoming options hash.  For example, the following view code:
    #
    #   <% uni_form_for :person, :url => {:action => 'update'} do |f| -%>
    #     <fieldset class="inlineLabels">
    #       <legend>Name</legend>
    #       <%= f.text_field :last_name, :label => 'Last name', :hint => "Only alphabetic characters, ' and - are allowed", :required => true %>
    #     </fieldset>
    #   <% end -%>
    #
    # renders as:
    #
    #   <form action="/update/1" method="post">
    #     <fieldset class="inlineLabels">
    #       <div class="ctrlHolder odd">
    #         <label for="person_last_name"><em>*</em>Last name</label>
    #         <input id="person_last_name" name="person[last_name]" type="text" tabindex="1" size="40" maxlength="40" value="Smith">
    #         <p class="formHint">Only alphabetic characters, ' and - are allowed</p>
    #       </div>
    #     </fieldset>
    #   </form>
    #
    # Text passed in through <code>:label</code> is put in the <code><label></code> tag. <code>:required => true</code> yields the <code><em>*</em></code> in the label. The <code>tabindex</code> is rendered automatically. All fields in the form will be taxindexed in order of appearance. For text fields, the <code>size</code> and <code>maxlength</code> attributes are generated using the field length from the database.  <code>:hint</code> is optional.  If not specified, the resulting <code><p class="formHint"></p></code> isn't rendered.
    # 
    # The <code>ctrlHolder</code> divs alternate <code>odd</code> and <code>even</code> classes.  To force a reset of the odd/even cycle, pass <code>:odd => true</code>.
    # 
    # All fields should be put inside fieldsets. They may take the classes "inlineLabels" or "blockLabels".  The former makes a column of labels followed by a column of form fields. The latter makes all of the form elements line up on the left of the form, with the fields appearing below their labels.
    # 
    # Sometimes it is desirable to have multiple fields appear together, for example when inputting a name:
    # 
    #   <%= f.start_multiple_fields_group :label => 'Name', :required => true, :first => true %>
    #     <%= f.text_field :first_name, :label => 'First' %>
    #     <%= f.text_field :middle_initial, :label => 'Middle initial', :size => 2 %>
    #     <%= f.text_field :last_name, :size => 15, :label => 'Last', :hint => 'First, middle and last names' %>
    #   <%= f.end_multiple_fields_group %>
    # 
    # renders:
    # 
    #   <div class="ctrlHolder odd">
    # 	  <label for="person_name"><em>*</em>Name</label>
    #     <input id="person_first_name" maxlength="15" name="person[first_name]" size="15" tabindex="1" type="text">
    #     <input id="person_middle_initial" maxlength="15" name="person[middle_initial]" size="2" tabindex="2" type="text">
    #     <input id="person_last_name" maxlength="60" name="person[last_name]" size="15" tabindex="3" type="text">
    #     <p class="formHint">First, middle and last names</p>
    #   </div>
    # 
    # By grouping the fields in the same <code>ctrlHolder</code> they can be styled to appear on a single line with a single hint.
    # == Field helpers
    # Most of the form field helper functions are dynamically generated.  They follow the same naming conventions as typical Rails form helper functions:
    # * <code>check_box</code>
    # * <code>file_field</code>
    # * <code>hidden_field</code>
    # * <code>label</code>
    # * <code>password_field</code>
    # * <code>radio_button</code>
    # * <code>text_area</code>
    # * <code>text_field</code>
    # However, each of these also has a &quot;avoid the UniForm wrapper&quot; form that can be called:
    # * <code>check_box_without_wrapper</code>
    # * <code>file_field_without_wrapper</code>
    # * <code>hidden_field_without_wrapper</code>
    # * <code>label_without_wrapper</code>
    # * <code>password_field_without_wrapper</code>
    # * <code>radio_button_without_wrapper</code>
    # * <code>text_area_without_wrapper</code>
    # * <code>text_field_without_wrapper</code>
    # These may be used to have parts of a UniForm that don't follow the UniForm standards.
    class UniFormBuilder < ActionView::Helpers::FormBuilder
    
      # Track which <code>tabindex<code> has been used most recently.  This attribute defaults to 0 at object initialization.
      attr_accessor :tabindex
    
      # Set @tabindex to 0, assume we're using the HTML wrappers, and do whatever initialization needs to happen
      def initialize(*args)
        @tabindex = 0
        @wrapper = true
        super
      end
    
      (field_helpers - %w(hidden_field check_box radio_button apply_form_for_options!) + %w(select date_select datetime_select time_select)).each do |selector|
        src = <<-END_SRC
          # Output a #{selector} wrapped in the standard markup structure.  Takes the following in addition to the standard options: :hint => 'hint text', :label => 'label text', :required => true for required fields.
          def #{selector}(field,#{' choices,' if selector == 'select'} options = {})
            # First handle the html_options if they exist
            html_options = options.delete(:html_options) if options[:html_options]
          
            # Now, add the default tabindex
            (html_options ? html_options : options).reverse_merge!(:tabindex => next_tabindex)
                    
            # Strip out our uni_form specific tags from options, store them in new_options
            new_options, options = remove_uniform_options(options)
            new_options[:label] ||= field.to_s.humanize.capitalize
          
            # Set size & maxlength options if necessary
            if '#{selector}' == 'text_field'
              col = object_name.to_s.classify.constantize.new.column_for_attribute(field)
              options.reverse_merge!(:size => col.limit, :maxlength => col.limit) if col && col.type == :string && col.limit > 0
            end
          
            # Create the tag
            content = (@wrapper ? label_wrapper(field, new_options) : '') + super(field,#{' choices,' if selector == 'select'} options#{', html_options || {}' if selector == 'select'}) + hint_wrapper(new_options[:hint])
            @wrapper ? uniform_wrapper(content, {:first => options.delete(:first)}) : content
          end

          # Output a #{selector} without calling uniform_wrapper.
          def #{selector}_without_wrapper(field, #{'choices, ' if selector == 'select'}options = {})
            #{selector}(field, #{'choices, ' if selector == 'select'}options.merge(:wrapper => false, :hint => nil))
          end
        END_SRC
        class_eval src, __FILE__, __LINE__
      end
    
      # Output a check box wrapped in the standard markup structure.  Takes the following in addition to the standard options: :hint => hint text, :label => label text, :required => true for required fields.
      def check_box(field, options = {}, checked_value = '1', unchecked_value = '0')
        new_options, options = remove_uniform_options(options)
        new_options[:label] ? super + label_wrapper(field, new_options) : super
      end
    
      # Output a check box without the uniform_wrapper()
      def check_box_without_wrapper(field, options = {}, checked_value = '1', unchecked_value = '0')
        check_box(field, options.merge(:wrapper => false), checked_value, unchecked_value)
      end

      # Output a radio button wrapped in the standard markup structure.  Takes the following in addition to the standard options: :hint => hint text, :label => label text, :required => true for required fields.
      def radio_button(field, tag_value, options = {})
        new_options, options = remove_uniform_options(options)
        new_options[:label] ? super + label_wrapper(field, new_options) : super
      end
    
      # Output a radio button without the uniform_wrapper()
      def radio_button_without_wrapper(field, tag_value, options = {})
        radio_button(field, tag_value, options.merge(:wrapper => false))
      end

      # Output a grouped set of fields, such as a month/day/year input set, or a set of radio buttons or check boxes.
      def multiple_field_group(options = {}, &block)
        first = options.delete(:first)
        the_class = options.delete(:class)
        @template.concat(start_uniform_wrapper(:first => first, :class => the_class))
        @template.concat(label_wrapper(options[:label].underscore.gsub(/ /,'_'), options)) if options[:label]
        @template.concat(hint_wrapper(options[:hint])) if options[:hint]
        @wrapper = false
        content = @template.capture(&block)
        @template.concat(content)
        @wrapper = true
        @template.concat(end_uniform_wrapper)
      end
      
      # Output a fieldset, complete with legend
      def fieldset(legend, options = {}, &block)
        options[:class] = case options[:class]
          when nil then 'inlineLabels'
          when /(block|inline)Labels/ then options[:class]
          else "inlineLabels #{options[:class]}"
        end
        content = @template.capture(&block)
        @template.concat(@template.tag(:fieldset, options, true) + "\n")
        @template.concat("\t" + @template.content_tag(:legend, legend)) unless legend.blank?
        @template.concat(content)
        @template.concat("</fieldset>")
      end
      
      protected
    
      # Increment @tabindex, and return its new value for use
      def next_tabindex
        @tabindex += 1
        return @tabindex
      end
    
      # Wrap up one "line" of a form -- a group of fields that receive a single label
      def uniform_wrapper(inner_content, options = {})
        start_uniform_wrapper(options) + inner_content + "\n" + "</div>\n"
      end
    
      # Opening HTML of a uniForm block: <code><div class="ctrlHolder odd"></code>, except it alternates between <code>odd</code> and <code>even</code>
      def start_uniform_wrapper(options = {})
        @odd = (options.delete(:first) ? true : !@odd)
        the_class = 'ctrlHolder ' + (@odd ? 'odd' : 'even')
        if options[:class]
          options[:class] = options[:class] + ' ' + the_class
        else
          options.merge!(:class => the_class)
        end
        @template.tag(:div, options, true) + "\n"
      end
    
      # Closing HTML of a uniForm block
      def end_uniform_wrapper
        "</div>\n"
      end
    
      # HTML to produce the full <code>label</code> tag associated with a field
      def label_wrapper(field, options)
        the_label = (options.delete(:required) ? "<em>*</em>" : "") + options.delete(:label)
        the_class = options.delete(:class).to_s + ' ' + (@wrapper ? '' : 'nestedLabel')
        the_class = nil if the_class == ' '
        options.merge!(:for => "#{@object_name}_#{field}", :class => the_class)
        "\t" + @template.content_tag(:label, the_label, options) + "\n"
      end
    
      # HTML to produce a hint that appears after a field
      def hint_wrapper(hint)
        hint ? "\t<p class=\"formHint\">#{hint}</p>\n" : ''
      end
    
      private
    
      # Remove the custom options from an incoming options Hash, and return them
      def remove_uniform_options(options)
        new_options = {}
        %w(label required hint wrapper odd).each{|key| new_options[key.to_sym] = options.delete(key.to_sym) }
        @wrapper = new_options[:wrapper].blank? ? @wrapper : new_options[:wrapper].delete
        return [new_options, options]
      end
    end
  
    # Create a wrapper function for our custom UniForm
    def uni_form_for(name, object = nil, options = {}, &proc)
      concat(content_tag(:p, '<em>*</em> indicates a required field', :class => 'form_required') + "\n")
      options.merge!(:builder => UniFormBuilder)
      if options[:html]
        if options[:html][:class]
          options[:html][:class] = options[:html][:class] + ' uniForm'
        else
          options[:html][:class] = 'uniForm'
        end
      else
        options.merge! :html => {:class => 'uniForm'}
      end
      form_for(name, object, options, &proc)
    end
  end
end