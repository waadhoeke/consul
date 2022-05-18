class RemoveMainButtonTextAndMainButtonUrl < ActiveRecord::Migration[5.2]
  def change
    if ActiveRecord::Base.connection.column_exists?(:budget_phases, :main_button_url)
      remove_column :budget_phases, :main_button_url
    end
    if ActiveRecord::Base.connection.column_exists?(:budget_phases, :main_button_text)
      remove_column :budget_phases, :main_button_text
    end
    if ActiveRecord::Base.connection.column_exists?(:budget_phase_translations, :main_button_url)
      remove_column :budget_phase_translations, :main_button_url
    end
    if ActiveRecord::Base.connection.column_exists?(:budget_phase_translations, :main_button_text)
      remove_column :budget_phase_translations, :main_button_text
    end
    if ActiveRecord::Base.connection.column_exists?(:budget_translations, :main_button_url)
      remove_column :budget_translations, :main_button_url
    end
    if ActiveRecord::Base.connection.column_exists?(:budget_translations, :main_button_text)
      remove_column :budget_translations, :main_button_text
    end
    if ActiveRecord::Base.connection.column_exists?(:budgets, :main_button_url)
      remove_column :budgets, :main_button_url
    end
    if ActiveRecord::Base.connection.column_exists?(:budgets, :main_button_text)
      remove_column :budgets, :main_button_text
    end
  end
end
