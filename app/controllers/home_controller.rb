class HomeController < ApplicationController

  skip_before_filter :authorize

  before_filter -> { is_mobile?(params[:mobile])}, only: :index

  def index
    #@box_project_front_page = true
  end

  def about
  end

  def contact
  end

  def api_v1
  end

  def privacy_policy
  end

  private
  
  def is_mobile?(mobile = nil)
    puts "\n\n\n#{mobile}\n\n\n"
    if mobile == nil
      request.format = :mobile if request.user_agent =~ /Mobile|webOS/
    end
  end
end
