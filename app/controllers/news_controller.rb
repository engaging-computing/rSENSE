class NewsController < ApplicationController
  # GET /news
  # GET /news.json
  skip_before_filter :authorize, only: [:show, :index]
  before_filter :authorize_admin, only: [:create, :update, :destroy]
  include ApplicationHelper

  def index
    if @cur_user.try(:admin)
      @news = News.order('created_at DESC').limit(10)
    else
      @news = News.where(hidden: false).order('created_at DESC').limit(10)
    end

    @new_news = News.new

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @news.map(&:to_hash) }
    end
  end

  # GET /news/1
  # GET /news/1.json
  def show
    @news = News.find(params[:id])

    recur = ((params[:recur] == true) ? true : false) || false

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @news.to_hash(recur) }
    end
  end

  # POST /news
  # POST /news.json
  def create
    @news = News.new(news_params)
    @news.user_id = @cur_user.id

    respond_to do |format|
      if @news.save
        format.html do
          redirect_to @news,
          notice: 'News entry was successfully created.'
        end
        format.json do
          render json: @news.to_hash(false),
                 status: :created, location: @news
        end
      else
        flash[:error] = @news.errors.full_messages
        format.html { redirect_to @news }
        format.json do
          render json: @news.errors,
                 status: :unprocessable_entity
        end
      end
    end
  end

  # PUT /news/1
  # PUT /news/1.json
  def update
    @news = News.find(params[:id])

    respond_to do |format|
      if @news.update_attributes(news_params)
        format.html do
          redirect_to @news,
          notice: 'News was successfully updated.'
        end
        format.json { render json: {}, status: :ok }
      else
        format.html { render action: 'show' }
        format.json { render json: @news.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /news/1
  # DELETE /news/1.json
  def destroy
    @news = News.find(params[:id])

    @news.media_objects.each(&:destroy)

    @news.destroy

    respond_to do |format|
      format.html { redirect_to news_index_url }
      format.json { render json: {}, status: :ok }
    end
  end

  private

  def news_params
    params[:news].permit(:title, :content, :summary, :featured_media_id,
                         :user_id, :hidden)
  end
end
