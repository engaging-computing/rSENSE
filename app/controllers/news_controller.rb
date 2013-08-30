class NewsController < ApplicationController
  # GET /news
  # GET /news.json
  skip_before_filter :authorize, only: [:show, :index]
  include ApplicationHelper
  
  def index
    @news = News.where(:hidden => false).order("created_at DESC").limit(5)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @news.map {|p| p.to_hash()} }
    end
  end

  # GET /news/1
  # GET /news/1.json
  def show
    @news = News.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @news }
    end
  end

  # GET /news/1/edit
  def edit
    @news = News.find(params[:id])
  end

  # POST /news
  # POST /news.json
  def create
    if is_admin?
      @news = News.new({user_id: @cur_user.id, title: "New Blog Entry"})
      respond_to do |format|
        if @news.save
          format.html { redirect_to @news, notice: 'News entry was successfully created.' }
          format.json { render json: @news.to_hash(false), status: :created, location: @news }
        else
          format.html { render :status => 404 }
          format.json { render json: @news.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { render :status => 403 }
        format.json { render json: @news.errors, status: :forbidden }
      end
    end
  end

  # PUT /news/1
  # PUT /news/1.json
  def update
    @news = News.find(params[:id])

    respond_to do |format|
      if @news.update_attributes(params[:news])
        format.html { redirect_to @news, notice: 'News was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @news.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /news/1
  # DELETE /news/1.json
  def destroy
    @news = News.find(params[:id])
    @news.destroy

    respond_to do |format|
      format.html { redirect_to news_index_url }
      format.json { head :no_content }
    end
  end
end
