class SearchController < ApplicationController
  verify :params => :search, :add_flash => {:error => 'You must have a search term to search'}, :redirect_to => :back, :only => :index
  
  # Run a search
  def index
    @meta[:title] = 'Search results'
    @meta[:description] = "Search results for &quot;#{params[:search]}&quot;"
    
    @search_terms = params[:search].split(' ')

    @posts = Post.contains(params[:search]).all
    @pages = Page.contains(params[:search]).all
  end
  
end
