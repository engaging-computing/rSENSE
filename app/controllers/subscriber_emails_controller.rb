class SubscriberEmailsController < ApplicationController
  before_filter :authorize_admin, :redirect_cancel, only: [:index, :show, :new, :create]

  def new
    @subscriber_email = SubscriberEmail.new
  end

  def create
    @subscriber_email = SubscriberEmail.new(subscriber_email_params)
    if @subscriber_email.save
      User.subscribed_users.each do |u|
        UserMailer.send_subscriber_email(u, @subscriber_email).deliver
      end
      flash[:success] = 'Successfully sent out the email!'
      redirect_to root_path
    end
  end

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

    @subscriber_emails = SubscriberEmail.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
    logger.error @subscriber_emails.map(&:created_at)

    @count = @subscriber_emails.count
    @subscriber_emails = @subscriber_emails.paginate(page: params[:page], per_page: pagesize).order("created_at #{sort}")
    respond_to do |format|
      format.html { render status: :ok }
      format.json { render json: @subscriber_emails.map { |u| u.to_hash(false) }, status: :ok }
    end
  end

  def show
    @subscriber_email = SubscriberEmail.find(params[:id])
    recur = params.key?(:recur) ? params[:recur] == 'true' : false
    respond_to do |format|
      format.html { render status: :ok }
      format.json { render json: @subscriber_email.to_hash(recur, show_hidden), status: :ok }
    end
  end

  private

  def subscriber_email_params
    params[:subscriber_email].permit(:subject, :message)
  end

  def redirect_cancel
    redirect_to root_path if params[:cancel]
  end
end
