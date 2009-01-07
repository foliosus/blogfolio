require 'uniform'
ActionView::Base.send :include, Reed::UniForm

# Reconfigure the default error output so that it fits nicer
ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  error_class = "error"
  case
    when html_tag =~ /type="radio"/
      html_tag = "<div class=\"radio error\">#{html_tag}</div>"
    when html_tag =~ /<(input|textarea|select)[^>]+class=/
      html_tag.gsub!(/(class=['\"])/,"#{$1}#{error_class} ")
    when html_tag =~ /<(input|textarea|select)/
      html_tag.gsub!(/<(input|textarea|select)/, "<#{$1} class=\"#{error_class}\"")
  end
  html_tag
end