xml.instruct!

xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/", "xmlns:atom" => "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title       "Foliosus Web Design blog"
    xml.link        blog_url
    xml.pubDate     @posts.blank? ? Time.now.rfc2822 : @posts.first.updated_at.rfc2822
    xml.description "Foliosus Web Design LLC is a small web agency in Portland, Oregon, specializing in bespoke web sites and web applications."
    xml.language    "en-us"
    xml.atom        :link, :href => rss_url, :rel => 'self', :type => 'application/rss+xml'

    @posts.each do |post|
      xml.item do
        xml.title       post.title
        xml.link        blog_post_url(post)
        xml.description { xml.cdata!(single_post(post, :comments => false, :comment_form => false, :excerpt => true).gsub('href="/', 'href="http://foliosus.com/')) }
        xml.pubDate     post.updated_at.rfc2822
        xml.guid        blog_post_url(post)
        xml.author      "foliosus@foliosus.com (Brent Miller)"
      end
    end

  end
end