require 'base64'

class UsersController < ApplicationController
  before_filter :authorize_admin, only: [:index]

  skip_before_filter :authorize, only:
    [:new, :create, :validate, :pw_request, :pw_send_key, :pw_reset]

  include ActionView::Helpers::DateHelper
  include ApplicationHelper

  # GET /users
  # GET /users.json
  def index
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

    @users = User.search(params[:search]).paginate(
      page: params[:page], per_page: pagesize).order("created_at #{sort}")
    logger.error @users.map { |u| u.created_at }
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
      show_hidden = @cur_user.id == @user.id

      respond_to do |format|
        format.html { render status: :ok }
        format.json { render json: @user.to_hash(recur, show_hidden), status: :ok }
      end
    end
  end

  # GET /users/1/contributions
  # GET /users/1.json
  def contributions
    @user = User.find(params[:id])

    # See if we are only looking for specific contributions
    @filter = params[:filters].to_s.downcase

    if params[:page_size].nil?
      page_size = 10
    else
      page_size = params[:page_size].to_i
    end

    show_hidden = (@cur_user.id == @user.id) || can_admin?(@user)

    @contributions = []

    case @filter
    when 'my projects'
      @contributions = @user.projects.search(params[:search], show_hidden)
    when 'data sets'
      @contributions = @user.data_sets.search(params[:search])
    when 'visualizations'
      @contributions = @user.visualizations.search(params[:search], show_hidden)
    when 'liked projects'
      @contributions = []
      @user.likes.each do |like|
        y = Project.where('(lower(title) LIKE lower(?)) AND (id = ?)', "%#{params[:search]}%",
                          like.project_id).first || next
        next if y.hidden == true && !can_edit?(y)
        @contributions << y
      end
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

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])

    unless @cur_user.admin or @user == @cur_user
      render_404
      return
    end
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    @user.reset_validation!

    respond_to do |format|
      if @user.save
        session[:user_id] = @user.id

        UserMailer.validation_email(@user)

        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render json: @user.to_hash(false), status: :created, location: @user }
      else
        # flash[:debug] = @user.errors.inspect
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])
    auth = false
    auth_error = 'Not authorized to update user'

    auth  = true if @cur_user.admin?
    auth  = true if can_edit?(@user) && session[:pw_change]

    if !auth && can_edit?(@user)
      if (params[:user][:password].nil? && params[:user][:email].nil?) or
           @user.authenticate(params[:current_password])
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
      if @cur_user.id == @user.id
        session[:user_id] = nil
      end
      @user.likes.each do |l|
        l.destroy
      end
      @user.projects.each do |p|
        p.hidden = true
        p.save
      end
      @user.media_objects.each do |m|
        m.destroy
      end
      @user.visualizations.each do |v|
        v.hidden = true
        v.save
      end
      @user.data_sets.each do |d|
        d.destroy
      end
      @user.tutorials.each do |t|
        t.hidden = true
        t.save
      end

      @user.hidden = true
      @user.email  = "#{SecureRandom.hex}@deleted.org"
      @user.save!

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

    if @user.email.nil? or @user.email.empty?
      @reason = "You didn't set an email."
      return
    end

    @user.reset_validation!
    unless @user.save
      @reason = 'There was a database error.'
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

  # GET /users/pw_reset
  def pw_reset
    key = params[:key]

    @user = User.find_by_validation_key(key)
    if @user.nil?
      session[:user_id]   = nil
      session[:pw_change] = nil
      logger.info 'No such validation key'
      render_404
      return
    else
      session[:user_id]   = @user.id
      session[:pw_change] = true
      redirect_to edit_user_path(@user)
    end
  end

  private

  def user_params
    if @cur_user.try(:admin)
      params[:user].permit(:content, :email, :email_confirmation, :name, :password, :password_confirmation,
                           :admin, :validated, :hidden, :bio, :last_login)
    else
      params[:user].permit(:content, :email, :email_confirmation, :name, :password, :password_confirmation,
                           :hidden, :bio)
    end
  end
end
