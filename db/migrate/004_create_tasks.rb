class CreateTasks < ActiveRecord::Migration
  def up
    create_table :tasks do |t|
      t.string :text, null: false
      t.integer :list_id, null: false
    end
  end

  def down
    drop_table :tasks
  end
end