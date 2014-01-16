class ContribKeysController < ApplicationController
  skip_before_filter :authorize, only: [:enter]

  def create
    @key = ContribKey.new(params[:contrib_key])

    unless can_edit?(@key.project)
      flash[:error] = "Action Not Authorized"
      redirect_to @key.project
      return
    end

    if can_edit?(@key.project) && @key.save
      flash[:notice] = "Added contributor key."
      redirect_to @key.project
    else
      flash[:error] = @key.errors.full_messages
      redirect_to @key.project
    end
  end

  def destroy
    @key = ContribKey.find(params[:id])

    if can_edit?(@key.project)
      @key.destroy
      flash[:notice] = "Deleted contributor key."
      redirect_to @key.project
    else
      flash[:error] = "Action Not Authorized"
      redirect_to @key.project
    end
  end

  def enter
    @project = Project.find(params[:project_id])
    keys = @project.contrib_keys.where(key: params[:key])
    
    if keys.count > 0
      session[:contrib_access] = @project.id
      flash[:notice] = "You have entered a valid contributor key."
      redirect_to @project
    else
      flash[:error] = "Invalid contributor key."
      redirect_to @project
    end
  end
end
