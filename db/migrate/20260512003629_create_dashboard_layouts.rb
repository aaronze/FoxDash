class CreateDashboardLayouts < ActiveRecord::Migration[7.0]
  def change
    create_table :dashboard_layouts do |t|
      t.references :user, null: false, foreign_key: true
      t.json :layout

      t.timestamps
    end
  end
end
