class SearchController < ApplicationController
  verify :params => :search, :add_flash => {:error => 'You must have a search term to search'}, :redirect_to => :back, :only => :index
  
  layout 'blog'
  
  # Run a search
  def index
    @meta[:title] = 'Search results'
    @meta[:description] = "Search results for &quot;#{params[:search]}&quot;"
    
    @search_terms = params[:search].split(' ')

    @posts = Post.contains(params[:search]).reverse_chronological_order.paginate(:per_page => 10, :page => params[:page])
    @pages = Page.contains(params[:search]).all(:order => :name) if params[:page] && params[:page].to_i == 1
  end
  
end
