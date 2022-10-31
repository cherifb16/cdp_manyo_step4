class TasksController < ApplicationController
  before_action :set_task, only: %i[ show edit update destroy ]

  def index
    if params[:sort_deadline_on]
      tasks = current_user.tasks.sort_deadline_on.sort_created_at
    elsif params[:sort_priority]
      tasks = current_user.tasks.sort_priority.sort_created_at
    else
      tasks = current_user.tasks.sort_created_at
    end
    
    if params[:search].present?
      if params[:search][:status].present? && params[:search][:title].present?
        tasks = tasks.search_status(params[:search][:status]).search_title(params[:search][:title])
      elsif params[:search][:status].present?
        tasks = tasks.search_status(params[:search][:status])
      elsif params[:search][:title].present?
        tasks = tasks.search_title(params[:search][:title])
      end
    end

    @tasks = tasks.page(params[:page]).per(10)
  end

  def show
    current_user_required(@task.user)
  end

  def new
    @task = Task.new
  end

  def edit
    current_user_required(@task.user)
  end

  def create
    @task = Task.new(task_params)
    @task.user = current_user

    if @task.save
      redirect_to tasks_path, notice: t('.created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @task.update(task_params)
      redirect_to tasks_path, notice: t('.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    redirect_to tasks_url, notice: t('.destroyed')
  end

  private
    def set_task
      @task = Task.find(params[:id])
    end

    def task_params
      params.require(:task).permit(:title, :content, :deadline_on, :priority, :status)
    end
end
