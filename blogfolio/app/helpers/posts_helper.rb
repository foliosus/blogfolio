require 'hpricot'

module PostsHelper
  # Show the metadata for a post, wrapped in a <p class="metadata">
  def show_metadata(post)
    content_tag(:p, post.created_at.strftime('<span class="month">%b</span> <span class="day">%d</span> <span class="year">&rsquo;%y</span>'), :class => 'date') + content_tag(:p, "Filed in #{post.categories.collect{|cat| link_to cat.name.downcase, blog_category_path(cat)}.join(', ')}", :class => 'metadata')
  end
  
  # Format a single post for output.  Accepts the following options (with their defaults): 
  # * <code>:heading => :h2</code> sets the tag used for the post title
  # * <code>:comments => true</code> shows the formatted comment list
  # * <code>:comment_form => true</code> shows the form for new comments
  # * <code>:metadata => true</code> shows the post metadata (categories, date, etc.)
  # * <code>:excerpt => false</code> when true only shows the beginning of the post
  # * <code>:more_text => 'Read more &hellip;'</code> text to show in "Read more" link
  # * <code>:title_link => :blog_post</code> renders a blog_post_url around the title if present; set to false to remove the title link
  def single_post(post, options = {})
    options.reverse_merge!( :comments => true, 
                            :comment_form => true,
                            :heading => :h2, 
                            :metadata => true, 
                            :excerpt => false,
                            :more_text => 'Read the rest &hellip;',
                            :title_link => :blog_post)
    
    output = []
    
    if options[:title_link]
      output << content_tag(options[:heading], link_to(post.title, eval("#{options[:title_link]}_url(post)"), :title => "Read #{post.title} (with comments)"), :class => 'title')
    else
      output << content_tag(options[:heading], post.title, :class => 'title')
    end
    
    output << show_metadata(post) if options[:metadata]
    
    # Perform the excerpting
    if options[:excerpt]
      link = link_to(options[:more_text], post_path(post), :title => "Read the rest of #{post.title}", :class => 'more' )
      post.content =~ /(.*)<!--\s?more\s?-->(.*)/m
      if $2
        post.content = $1 + link
      else
        post.content = post.summary + "\r\n\r\n#{link}"
      end
    end

    body = Hpricot(post.content.gsub(/<!--(.*?)-->/m, ''))

    # Convert any "pre" segments to code
    ['xml', 'yaml', 'ruby'].each do |code|
      convertor = Syntax::Convertors::HTML.for_syntax code
      body.search("pre.#{code}") do |e|
        e.innerHTML = convertor.convert( e.innerHTML ).gsub(/<\/?pre>/,'')
      end
    end

    # Simple format & auto-link the body
    body = simple_format(auto_link(sanitize(body.to_html)))
    ['pre', 'ol', 'ul', 'blockquote', 'h1', 'h2', 'h3', 'h4', 'div', 'p'].each do |tag|
      body = body.gsub(/<p><#{tag}/,"<#{tag}").gsub(/\/#{tag}><\/p>/,"/#{tag}>")
    end
    body = Hpricot(body)
    body.search("pre p"){|e| e.swap(e.inner_html)}
    body.search("pre br").remove # Remove <br /> tags inside <pre> tags -- the simple_format method incorrectly inserts them
    body.search("ol>br").remove
    body.search("ul>br").remove
    
    output << body.to_html

    if options[:comments]
      output << content_tag(:h2, 'Conversation in progress&hellip;', :class => 'comments') unless post.comments.blank?
      index = 0
      output << content_tag(:ol, post.comments.collect{|comment| index += 1; single_comment(comment, :class => cycle('odd', 'even') + (index == 1 ? ' first' : ''), :index => index) }.join("\n\n"), :class => 'comments')
      new_comment = Comment.new(params[:comment])
      new_comment.post = post
      output << controller.instance_eval{render_to_string(:partial => 'comments/form')} if options[:comment_form]
    end
    
    # Return the output wrapped in a <div class="post">
    content_tag(:div, output.join("\n\n\t\t"), :class => 'post')
  end
  
  def single_comment(comment, options = {})
    options.reverse_merge!(:heading => :h4, :tag => :li, :id => "comment_#{comment.id}", :explicit_numbers => true, :index => 1)
    tag = options.delete(:tag)
    heading = options.delete(:heading)
    explicit_numbers = options.delete(:explicit_numbers)
    index = options.delete(:index)
    options[:class] ||= ''
    options[:class] += ' author' if comment.email == 'foliosus@foliosus.com'
    options[:class] = options[:class].lstrip
    content_tag(tag,
      (explicit_numbers ? content_tag(:span, index, :class => 'number') : '') + 
      content_tag(heading, 
                  "On #{comment.created_at.strftime('%B')} #{comment.created_at.day.ordinalize} " + (comment.homepage.blank? ?  comment.author : link_to(comment.author, comment.homepage, {:rel => 'nofollow', :title => "Visit #{comment.author}'s homepage"})) + " said:") + 
      simple_format(auto_link(sanitize(comment.body))),
      options
    )
  end
end
