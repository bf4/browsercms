require File.join(File.dirname(__FILE__), '/../../test_helper')

class TaskItemTest < ActiveSupport::TestCase
  def setup
    super
    @editor_a = create_admin_user(:login => "editor_a", :email => "editor_a@example.com")    
    @editor_b = create_admin_user(:login => "editor_b", :email => "editor_b@example.com")
    @non_editor = Factory(:user, :login => "non_editor", :email => "non_editor@example.com")
    @page = Factory(:page, :name => "TaskItem Test", :path => "/task_item_test")          
  end
end
  
class CreateTaskItemTest < TaskItemTest

  def test_create_task_item
    assert_that_you_can_assign_a_task_item_to_yourself
    assert_that_an_assigned_by_user_that_is_an_editor_is_required
    assert_that_an_assigned_to_user_that_is_an_editor_is_required
    assert_that_a_page_is_required
  
    create_the_task_item!
  
    assert !@task_item.completed?
    assert(@task_item.due_date < Time.now)
    assert_equal "Howdy!", @task_item.comment
  
    assert_that_an_email_is_sent_to_the_user_the_task_item_was_assigned_to
    assert_that_the_page_is_assigned_to_the_assigned_to_user
    assert_that_the_task_item_is_added_to_the_users_incomplete_task_items
  end

  protected

    def assert_that_you_can_assign_a_task_item_to_yourself
      assert_valid Factory.build(:task_item, :assigned_by => @editor_a, :assigned_to => @editor_a)
    end

    def assert_that_an_assigned_by_user_that_is_an_editor_is_required
      task_item = Factory.build(:task_item, :assigned_by => nil, :assigned_to => @editor_a)
      assert_not_valid task_item
      assert_has_error_on task_item, :assigned_by_id, "is required"

      task_item = Factory.build(:task_item, :assigned_by => @non_editor, :assigned_to => @editor_a)
      assert_not_valid task_item
      assert_has_error_on task_item, :assigned_by_id, "cannot assign task_items"
    end
  
    def assert_that_an_assigned_to_user_that_is_an_editor_is_required
      task_item = Factory.build(:task_item, :assigned_by => @editor_a, :assigned_to => nil)
      assert_not_valid task_item
      assert_has_error_on task_item, :assigned_to_id, "is required"    

      task_item = Factory.build(:task_item, :assigned_by => @editor_a, :assigned_to => @non_editor)
      assert_not_valid task_item
      assert_has_error_on task_item, :assigned_to_id, "cannot be assigned task_items"      
    end
  
    def assert_that_a_page_is_required
      task_item = Factory.build(:task_item, :page => nil)
      assert_not_valid task_item
      assert_has_error_on task_item, :page_id, "is required"      
    end

    def create_the_task_item!
      @task_item = TaskItem.create!(
        :assigned_by => @editor_a, 
        :assigned_to => @editor_b,
        :due_date => 5.minutes.ago,
        :comment => "Howdy!",
        :page => @page)      
    end

    def assert_that_an_email_is_sent_to_the_user_the_task_item_was_assigned_to
      email = EmailMessage.first(:order => "created_at desc")
      assert_equal @editor_a.email, email.sender
      assert_equal @editor_b.email, email.recipients
      assert_equal "Page '#{@page.name}' has been assigned to you", email.subject
      assert_equal "http://#{SITE_DOMAIN}#{@page.path}\n\n#{@task_item.comment}", email.body      
    end

    def assert_that_the_page_is_assigned_to_the_assigned_to_user
      assert @page.assigned_to?(@editor_b), "Expected the page to be assigned to editor b"
      assert !@page.assigned_to?(@editor_a), "Expected the page not to be assigned to editor a"
    end

    def assert_that_the_task_item_is_added_to_the_users_incomplete_task_items
      assert !@editor_a.task_items.incomplete.all.include?(@task_item), 
        "Expected Editor A's incomplete task_items not to include the task_item"
      assert @editor_b.task_items.incomplete.all.include?(@task_item),
        "Expected Editor B's incomplete task_items to include the task_item"      
    end
  
end

class ExistingIncompleteTaskItemTest < TaskItemTest
  def setup
    super
    @existing_task_item = Factory(:task_item, :assigned_by => @editor_a, :assigned_to => @editor_b, :page => @page)
  end

  def test_create_task_item_for_a_page_with_existing_incomplete_task_items
    assert !@existing_task_item.completed?
    
    @new_task_item = Factory(:task_item, :assigned_by => @editor_b, :assigned_to => @editor_a, :page => @page)
    @existing_task_item = TaskItem.find(@existing_task_item.id)

    assert @existing_task_item.completed?
    assert !@new_task_item.completed?
    assert @page.assigned_to?(@editor_a)
    assert !@page.assigned_to?(@editor_b)
    assert @editor_a.task_items.incomplete.all.include?(@new_task_item)
    assert !@editor_b.task_items.incomplete.all.include?(@existing_task_item)
  end

  def test_completing_a_task_item
    assert !@existing_task_item.completed?
    assert_equal @editor_b, @page.assigned_to
    assert @editor_b.task_items.incomplete.all.include?(@existing_task_item)    

    @existing_task_item.mark_as_complete!
    
    assert @existing_task_item.completed?
    assert @page.assigned_to.nil?
    assert !@editor_b.task_items.incomplete.all.include?(@existing_task_item)    
  end
end
