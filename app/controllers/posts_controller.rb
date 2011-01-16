class PostsController < ApplicationController
  
  before_filter :facebook_session_ok?
  before_filter :find_post, :only => [:show, :edit, :update, :destroy, :publish]
  respond_to :html, :xml, :json
  
  # GET /posts
  # GET /posts.xml
  # GET /posts.json
  def index
    respond_with(@posts = Post.find(:all, :conditions => { :user => session[:user_id]}))
  end

  # GET /posts/1
  # GET /posts/1.xml
  # GET /posts/1.json
  def show
    respond_with(@post)
  end

  # GET /posts/new
  # GET /posts/new.xml
  def new
    respond_with(@post = Post.new)
  end

  # GET /posts/1/edit
  def edit; end

  # POST /posts
  # POST /posts.xml
  def create
    @post = Post.create(params[:post])
    respond_with(@post, :location => post_path(@post))
  end

  # PUT /posts/1
  # PUT /posts/1.xml
  def update
    @post.update_attributes(params[:post])
    respond_with(@post, :location => post_path(@post))
  end

  # DELETE /posts/1
  # DELETE /posts/1.xml
  def destroy
    @post.destroy
    respond_with(@post, :location => posts_path)
  end
  
  # PUT /posts/1/publish
  def publish
    if session[:access_token]
      @post = Post.find(params[:id])
      @post.publish_to params[:publish_place], session[:access_token]
      @post.save
    end
    respond_with(@post, :location => posts_path)
  end
  
  protected
  
  def find_post
    @pos = Post.find(params[:id])
  end
  
  def facebook_session_ok?
    unless session[:access_token] and session[:user_id]
      redirect_to access_to_facebook_url
    end
  end
  
  
end
