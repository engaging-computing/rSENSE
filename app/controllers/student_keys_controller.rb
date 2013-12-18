class StudentKeysController < ApplicationController
  skip_before_filter :authorize, only: [:enter]

  def create
    @key = StudentKey.new(params[:student_key])

    unless can_edit?(@key.project)
      flash[:error] = "Action Not Authorized"
      redirect_to @key.project
      return
    end

    if can_edit?(@key.project) && @key.save
      flash[:notice] = "Added student key."
      redirect_to @key.project
    else
      flash[:error] = @key.errors.inspect
      redirect_to @key.project
    end
  end

  def destroy
    @key = StudentKey.find(params[:id])

    if can_edit?(@key.project)
      @key.destroy
      flash[:notice] = "Deleted student key."
      redirect_to @key.project
    else
      flash[:error] = "Action Not Authorized"
      redirect_to @key.project
    end
  end

  def enter
    @project = Project.find(params[:project_id])
    keys = @project.student_keys.where(key: params[:key])
    
    if keys.count > 0
      session[:student_access] = @project.id
      flash[:notice] = "You have entered a valid student key."
      redirect_to @project
    else
      flash[:error] = "Invalid student key."
      redirect_to @project
    end
  end
end
