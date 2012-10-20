class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings

    if params[:ratings]
      session[:ratings] = params[:ratings]
    elsif session[:ratings]
      @ratings = session[:ratings]
    end

    # TOTO: avoid logic duplication
    if params[:order]
      session[:order] = params[:order]
    elsif session[:order]
      @order = session[:order]
    end

    if @ratings or @order
      fill_ratings_and_order_from_params
      redirect_to movies_path(order: @order, ratings: @ratings)
    end

    fill_ratings_and_order_from_params
    
    @movies = if @order
      Movie.order(@order)
    else
      Movie
    end.where(rating: @ratings.keys).all
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private

  def fill_ratings_and_order_from_params
    @ratings ||= params[:ratings] || @all_ratings.inject({}) {|h, k| h[k]=1; h}
    @order ||= params[:order]
  end
end
