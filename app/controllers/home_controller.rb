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
    unless current_user.nil?
      redirect_to '/report_content_form'
    end
  end

  def report_content_form
    @current_user = current_user

    if current_user.nil?
      redirect_to '/report_content'
    end
  end

  def report_content_submit
    if params[:location] == '' or params[:content] == ''
      redirect_to :back, flash: { error: 'Please fill out all required fields.' }
    else
      begin
        UserMailer.report_content_email(params).deliver
        redirect_to '/report_content_success'
      rescue Net::SMTPFatalError
        @reason = 'Failed to send email.'
        return
      end
    end
  end

  def report_content_success
    render 'report_content_success'
  end
end
