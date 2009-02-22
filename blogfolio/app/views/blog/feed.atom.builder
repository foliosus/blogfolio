atom_feed :root_url => blog_url do |feed|
  feed.title("Foliosus Web Design blog")
  feed.updated(@posts.first.updated_at)
 
  for post in @posts
    feed.entry(post) do |entry|
      entry.title(post.title)
      entry.content(single_post(post, :comments => false, :comment_form => false, :excerpt => true).gsub('href="/', 'href="http://foliosus.com/'), :type => 'html')
      entry.author do |author|
        author.name('Brent Miller')
      end
    end
  end
end