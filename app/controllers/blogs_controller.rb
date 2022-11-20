# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_own_blog, only: %i[edit update destroy]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show
    @blog = Blog.where(id: params[:id]).where(user: current_user).or(Blog.published.where(id: params[:id])).take!
  end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    @blog = if current_user.premium
              current_user.blogs.new(blog_params_premium)
            else
              current_user.blogs.new(blog_params)
            end
    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    is_update_success = if @blog.user.premium?
                          @blog.update(blog_params_premium)
                        else
                          @blog.update(blog_params)
                        end
    if is_update_success
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_own_blog
    @blog = Blog.find_by!(id: params[:id], user: current_user)
  end

  def blog_params
    params.require(:blog).permit(:title, :content, :secret)
  end

  def blog_params_premium
    params.require(:blog).permit(:title, :content, :secret, :random_eyecatch)
  end
end
