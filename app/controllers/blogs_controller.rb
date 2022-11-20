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
    @blog = current_user.blogs.new(blog_params)
    if !@blog.user.premium? && blog_params[:random_eyecatch]
      @blog.random_eyecatch = false
      @blog.errors.add(:random_eyecatch, 'は有料会員のみ利用できます')
      render :new, status: :found
    elsif @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if !@blog.user.premium? && blog_params[:random_eyecatch]
      @blog.random_eyecatch = false
      @blog.errors.add(:random_eyecatch, 'は有料会員のみ利用できます')
      render :edit, status: :found
    elsif @blog.update(blog_params)
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
    params.require(:blog).permit(:title, :content, :secret, :random_eyecatch)
  end
end
