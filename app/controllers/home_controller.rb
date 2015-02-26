class HomeController < ApplicationController
  skip_before_filter :authorize
  before_filter -> { is_mobile?(params[:mobile])}, only: :index
  def index
    #@news = News.where('hidden = ?', false).order('created_at DESC').limit(2)
    #@featured_projects = Project.search(false).where('featured = ? and hidden = ?',  true, false).order('featured_at DESC').limit(4)
    #@featured_vis = Visualization.where('featured = ? and hidden = ?', true, false).order('featured_at DESC').first
    #@curated_projects = Project.search(false).where('curated = ? AND hidden = ?', true, false).order('updated_at DESC').limit(4)

    @box_project_front_page = true
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
