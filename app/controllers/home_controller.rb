class HomeController < ApplicationController
  skip_before_filter :authorize

  before_filter -> { is_mobile?(params[:mobile]) }, only: :index

  def index
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
    if mobile.nil?
      request.format = :mobile if request.user_agent =~ /Mobile|webOS/
    end
  end
end
