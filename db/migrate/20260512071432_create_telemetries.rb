class CreateTelemetries < ActiveRecord::Migration[7.0]
  def change
    create_table :telemetries do |t|
      t.datetime :timestamp, null: false
      t.float :inverter_temperature
      t.float :battery_temperature
      t.float :battery_soc
      t.float :power_load
      t.float :grid_feed_in
      t.float :grid_consumption
      t.float :battery_discharge_rate
      t.float :battery_charge_rate

      t.timestamps
    end

    add_index :telemetries, :timestamp, unique: true
  end
end
