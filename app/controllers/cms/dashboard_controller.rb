class Cms::DashboardController < Cms::BaseController
      
  def index
    @unpublished_pages = Page.unpublished.all(:order => "updated_at desc")
    @unpublished_pages = @unpublished_pages.select { |page| current_user.able_to_publish?(page) }
    @incomplete_task_items = current_user.task_items.incomplete.all(
      :include => :page, 
      :order => "task_items.due_date desc, pages.name")
  end
end
