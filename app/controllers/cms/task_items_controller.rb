class Cms::TaskItemsController < Cms::BaseController
  
  before_filter :set_toolbar_tab
  before_filter :load_page, :only => [:new, :create]
  
  def new
    @task_item = @page.task_items.build(:assigned_by => current_user)
  end
  
  def create
    @task_item = @page.task_items.build(params[:task_item])
    @task_item.assigned_by = current_user
    if @task_item.save
      flash[:notice] = "Page was assigned to '#{@task_item.assigned_to.login}'"
      redirect_to @page.path
    else
      render :action => 'new'
    end
  end
  
  def complete
    if params[:task_item_ids]
      TaskItem.all(:conditions => ["id in (?)", params[:task_item_ids]]).each do |t|
        if t.assigned_to == current_user
          t.mark_as_complete!
        end
      end
      flash[:notice] = "Tasks marked as complete"
      redirect_to cms_dashboard_path
    else
      @task_item = TaskItem.find(params[:id])
      if @task_item.assigned_to == current_user
        if @task_item.mark_as_complete!
          flash[:notice] = "Task was marked as complete"
        end
      else
        flash[:error] = "You cannot complete task_items that are not assigned to you"
      end
      redirect_to @task_item.page.path
    end
  end
  
  private
    def load_page
      @page = Page.find(params[:page_id])
    end
  
    def set_toolbar_tab
      @toolbar_tab = :sitemap
    end  
  
end