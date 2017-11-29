class HomeController < ApplicationController
  skip_before_filter :authorize

  def index
    @news = News.where('hidden = ?', false).order('created_at DESC').limit(2)
    @featured_projects = Project.search(false).where('featured = ? and hidden = ?',  true, false).order('featured_at DESC').limit(4)
    @featured_vis = Visualization.where('featured = ? and hidden = ?', true, false).order('featured_at DESC').first
    @curated_projects = Project.search(false).where('curated = ? AND hidden = ?', true, false).order('updated_at DESC').limit(4)
    @user = User.find(1)
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
end
