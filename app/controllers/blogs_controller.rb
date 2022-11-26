# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_own_blog, only: %i[edit update destroy]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show
    @blog = Blog.viewable_to(current_user).find(params[:id])
  end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    @blog = current_user.blogs.new(blog_params(current_user.premium))
    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @blog.update(blog_params(current_user.premium))
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
    @blog = current_user.blogs.find_by!(id: params[:id])
  end

  def blog_params(is_premium)
    if is_premium
      params.require(:blog).permit(:title, :content, :secret, :random_eyecatch)
    else
      params.require(:blog).permit(:title, :content, :secret)
    end
  end
end
