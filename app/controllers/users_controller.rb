require 'base64'

class UsersController < ApplicationController
  before_filter :authorize_admin, only: [:index]

  skip_before_filter :authorize, only: [:show, :index, :pw_request, :pw_send_key, :pw_reset, :contributions]

  include ActionView::Helpers::DateHelper
  include ApplicationHelper

  # GET /users
  # GET /users.json
  def index
    puts params
    # Main List
    if !params[:sort].nil?
      sort = params[:sort]
    else
      sort = 'DESC'
    end

    if !params[:per_page].nil?
      pagesize = params[:per_page]
    else
      pagesize = 30
    end

    # constrain results by date
    start_date = Date.strptime('2013-08-01', '%Y-%m-%d')
    end_date = Date.today
    unless params[:start_date].nil?
      if params[:start_date] != ''
        start_date = Date.strptime(params[:start_date], '%Y-%m-%d')
      end
    end
    unless params[:end_date].nil?
      if params[:end_date] != ''
        end_date = Date.strptime(params[:end_date], '%Y-%m-%d')
      end
    end

    @users = User.search(params[:search]).where(created_at: start_date.beginning_of_day..end_date.end_of_day)
    logger.error @users.map(&:created_at)
    if params[:activeUsers] == '1'
      # grab only users who have done something
      @users = @users.where('projects_count > 0 OR data_sets_count > 0 OR visualizations_count > 0')
    end
    @count = @users.count
    @users = @users.paginate(page: params[:page], per_page: pagesize).order("created_at #{sort}")
    respond_to do |format|
      format.html { render status: :ok }
      format.json { render json: @users.map { |u| u.to_hash(false) }, status: :ok }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find_by_id(params[:id])

    if @user.nil?
      respond_to do |format|
        format.html { render file: "#{Rails.root}/public/404.html", status: :not_found }
        format.json { render json: {}, status: :unprocessable_entity }
      end
    else

      recur = params.key?(:recur) ? params[:recur] == 'true' : false

      show_hidden = !current_user.nil? && current_user.id == @user.id

      @project = Project.new

      respond_to do |format|
        format.html { render status: :ok }
        format.json { render json: @user.to_hash(recur, show_hidden), status: :ok }
      end
    end
  end

  # GET /users/1/contributions
  # GET /users/1.json
  def contributions
    @user = User.find_by_id(params[:id])

    # See if we are only looking for specific contributions
    @filter = params[:filters].to_s.downcase

    if params[:page_size].nil?
      page_size = 10
    else
      page_size = params[:page_size].to_i
    end

    show_hidden = (!current_user.nil? && (current_user.id == @user.id)) || can_admin?(@user)

    @contributions = []
    @objtype = ''

    case @filter
    when 'my projects'
      @contributions = @user.projects.search(params[:search], show_hidden)
      @objtype = 'projects'
    when 'data sets'
      @contributions = @user.data_sets.search(params[:search])
      @objtype = 'data_sets'
    when 'visualizations'
      @contributions = @user.visualizations.search(params[:search], show_hidden)
      @objtype = 'visualizations'
    when 'liked projects'
      @contributions = []
      @user.likes.each do |like|
        y = Project.where('(lower(title) LIKE lower(?)) AND (id = ?)', "%#{params[:search]}%",
                            like.project_id).first || next
        next if y.hidden == true && !can_edit?(y)
        @contributions << y
      end
      @objtype = 'likes'
    end

    @sort = if params[:sort].nil?
              'create dsc'
            else
              params[:sort].to_s.downcase
            end

    if @contributions.is_a? Array
      case @sort
      when 'create asc'
        @contributions.sort! { |l, r| l.created_at.to_s.downcase <=> r.created_at.to_s.downcase }
      when 'create dsc'
        @contributions.sort! { |l, r| r.created_at.to_s.downcase <=> l.created_at.to_s.downcase }
      when 'title asc'
        @contributions.sort! { |l, r| l.title.downcase <=> r.title.downcase }
      when 'title dsc'
        @contributions.sort! { |l, r| r.title.downcase <=> l.title.downcase }
      else
        @contributions.sort! { |l, r| r.created_at.downcase <=> l.created_at.downcase }
      end
    else
      sort_type = case @sort
                  when 'create asc' then "#{@objtype}.created_at ASC"
                  when 'create dsc' then "#{@objtype}.created_at DESC"
                  when 'title asc' then 'lower(title) ASC'
                  when 'title dsc' then 'lower(title) DESC'
                  end
      @contributions = @contributions.order(sort_type).all
    end

    page = params[:page].to_i

    if @contributions.length == 0
      @total_pages = 0
    else
      @total_pages = (@contributions.length / page_size).ceil + 1
    end

    @last_page = false
    if page + 1 == @total_pages.to_i
      @last_page = true
    end

    @contributions = @contributions[page * page_size..(page * page_size) + (page_size - 1)]

    respond_to do |format|
      format.html { render partial: 'display_contributions' }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])

    unless current_user.admin or @user == current_user
      render_404
      return
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    auth = false
    auth_error = 'Not authorized to update user'

    @user = User.find_for_database_authentication(id: params[:id])

    sign_in('user', @user)

    auth  = true if !current_user.nil? && current_user.admin?
    auth  = true if can_edit?(@user) && session[:pw_change]

    if !auth && can_edit?(@user)
      if (params[:user][:password].nil? && params[:user][:email].nil?) or
         @user.valid_password?(params[:password])
        auth  = true
      else
        auth_error = "Current password doesn't match"
      end
    end

    respond_to do |format|
      if auth && @user.update_attributes(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render json: {}, status: :ok }
      else
        @errors = @user.errors.full_messages
        format.html do
          if auth
            flash[:error] = @errors.join(' ')
          else
            flash[:error] = auth_error
          end
          redirect_to edit_user_path(@user)
        end
        @errors = auth_error unless auth
        format.json { render json: @errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])

    if can_delete?(@user)
      if current_user.id == @user.id
        session[:user_id] = nil
      end
      @user.likes.each(&:destroy)
      @user.media_objects.each(&:destroy)
      @user.visualizations.each(&:destroy)
      @user.data_sets.each(&:destroy)
      @user.projects.each do |p|
        if can_delete?(p)
          p.destroy
        else
          # switch ownership to admin if this project contains data sets
          # not by the user we are deleting
          p.user_id = 1
          p.save
        end
      end
      @user.tutorials.each(&:destroy)
      @user.news.each(&:destroy)

      @user.destroy

      respond_to do |format|
        format.html { redirect_to users_url }
        format.json { render json: {}, status: :ok }
      end
    else
      respond_to do |format|
        flash[:debug] = 'Failed can_delete?'
        format.html { redirect_to 'public/401.html' }
        format.json { render json: {}, status: :forbidden }
      end
    end
  end

  # GET /users/validate/:key
  def validate
    key = params[:key]

    @user = User.find_by_validation_key(key)

    if @user.nil? or params[:key].blank?
      render_404
    else
      @user.validated = true
      @user.save!

      render
    end
  end

  # GET /users/pw_reset
  def pw_request
    # Show the form
  end

  # POST /users/pw_send
  def pw_send_key
    @sent = false

    key = params[:email].downcase

    @user = User.where('lower(email) = ?', key).first
    if @user.nil?
      @reason = 'No such user found.'
      return
    end

    begin
      UserMailer.pw_reset_email(@user).deliver
    rescue Net::SMTPFatalError
      @reason = 'Failed to send email.'
      return
    end

    @sent = true
  end

  private

  def user_params
    if current_user.try(:admin)
      params[:user].permit(:content, :email, :email_confirmation, :name, :password, :password_confirmation,
                           :admin, :validated, :hidden, :bio, :last_login)
    else
      params[:user].permit(:content, :email, :email_confirmation, :name, :password, :password_confirmation,
                           :hidden, :bio)
    end
  end
end
