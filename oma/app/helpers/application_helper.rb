# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # Return div#communication with a p for every item in the flash
  def show_flash
    content_tag(:div, flash.collect{|code, content| content_tag(:p, content, :class => code)}.join("\n"), :id => 'communication')
  end
  
  # Format a phone number
  def phone_number(number)
    "(#{number[0,3]}) #{number[3,3]}-#{number[6,4]}" if number.length > 0
  end
  
  # Output a markdown block of text in HTML
  def markdown(text)
    m = Markdown.new(h(text))
    m.smart = true
    m.to_html
  end
  
  # Output the first <code>length</code> characters of markdown <text>
  def teaser(obj, text_method = :description, length = 100)
    m = Markdown.new(h(obj.send(text_method)))
    m.smart = true
    m = m.to_html.gsub(/h\d>/, 'h4>').gsub(/ul>/, 'p>').gsub('</li>', '<br />')
    sanitize(truncate_html(m, 200), :tags => %w(p br h4)).gsub('...</p>', "... #{link_to 'read more', obj, :title => "Read the rest of this #{obj.class.to_s.underscore.humanize.downcase}"}</p>")
  end
  
  # Ensure that the first textarea on the page is enabled for snazzy Markdown editing
  def text_editor
    render :partial => "shared/text_editor"
  end
  
  def navigation_link(text, url, options = {})
    options.merge!(:class => 'current') if url == request.path || url == request.url
    link_to(text, url, options)
  end

end
