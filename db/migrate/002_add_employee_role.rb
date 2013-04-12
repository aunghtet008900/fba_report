class AddEmployeeRole <  ActiveRecord::Migration
  def up
    change_table :employees do |t|
      t.string :role
    end
  end

  def down
    remove_column :employees, :role
  end
end

