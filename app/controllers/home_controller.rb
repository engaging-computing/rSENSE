class HomeController < ApplicationController
  skip_before_filter :authorize

  def index
    @news = News.where('hidden = ?', false).order('created_at DESC').limit(2)
    @featured_projects = Project.search(false).where('featured = ? and hidden = ?',  true, false).order('featured_at DESC').limit(4)
    @featured_vis = Visualization.where('featured = ? and hidden = ?', true, false).order('featured_at DESC').first
    @curated_projects = Project.search(false).where('curated = ? AND hidden = ?', true, false).order('updated_at DESC').limit(4)

    @box_project_front_page = true
  end

  def about
  end

  def contact
  end

  def api_v1
  end

  def formulas_help
  end

  def privacy_policy
  end

  def report_content_login_check
    @prev_URL =  params[:prev_URL]
    
    if not current_user.nil?
      redirect_to '/report_content_form'
    end
  end  

  def report_content_form
    @prev_url = params[:prev_URL]
    @current_user = current_user

    if current_user.nil?
      redirect_to '/report_content'
    end

  end

  def report_content_submit


    @prev_URL = params[:prev_URL]

    begin
      UserMailer.report_content_email(params).deliver
    rescue Net::SMTPFatalError
      @reason = 'Failed to send email.'
      return
    end

    render 'report_content_success'

  end

  def report_content_submitted

    # TODO why is this here?
    puts 'in submitted routine'
    redirect_to 'home/index'
    
  end
end
