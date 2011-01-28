class ChangeTaskToTaskItemDueToNamespaceIssue < ActiveRecord::Migration
  def self.up
    rename_table :tasks, :task_items
  end

  def self.down
    rename_table :task_items, :tasks
  end
end
