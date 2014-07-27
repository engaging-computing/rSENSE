class ContribKeysController < ApplicationController
  skip_before_filter :authorize, only: [:enter, :clear]

  def create
    @key = ContribKey.new(contrib_key_params)

    unless can_edit?(@key.project)
      flash[:error] = 'Action Not Authorized'
      redirect_to @key.project
      return
    end

    if can_edit?(@key.project) && @key.save
      flash[:notice] = 'Added contributor key.'
      redirect_to [:edit, @key.project]
    else
      flash[:error] = @key.errors.full_messages
      redirect_to [:edit, @key.project]
    end
  end

  def destroy
    @key = ContribKey.find(params[:id])

    if can_edit?(@key.project)
      @key.destroy
      flash[:notice] = 'Deleted contributor key.'
      redirect_to [:edit, @key.project]
    else
      flash[:error] = 'Action Not Authorized'
      redirect_to @key.project
    end
  end

  def enter
    @project = Project.find(params[:project_id])
    keys = @project.contrib_keys.where(key: params[:key])
    contributor_name = params[:contributor_name]

    if keys.count > 0 && !(contributor_name.nil?)
      session[:key] = keys.first.name
      session[:contrib_access] = @project.id
      session[:contributor_name] = params[:contributor_name]
      flash[:notice] = 'You have entered a valid contributor key.'
    elsif !(keys.count > 0) && contributor_name.nil?
      flash[:error] = 'Invalid contributor key.', 'Enter a contributor Name.'
    elsif !(keys.count > 0)
      flash[:error] = 'Invalid contributor key.'
    elsif contributor_name.nil?
      flash[:error] = 'Enter a contributor Name.'
    end

    redirect_to @project
  end

  def clear
    session[:contrib_access] = nil
    flash[:notice] = 'Your have cleared your contributor key.'
    if params[:project_id]
      redirect_to Project.find(params[:project_id])
    else
      redirect_to projects_path
    end
  end

  private

  def contrib_key_params
    params[:contrib_key].permit(:name, :key, :project_id)
  end
end
