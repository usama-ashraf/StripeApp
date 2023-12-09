class CreateCharges < ActiveRecord::Migration[7.1]
  def change
    create_table :charges do |t|
      t.string :stripe_charge_id
      t.integer :amount
      t.string :currency
      t.boolean :refunded
      t.string :status
      t.datetime :refunded_at

      t.timestamps
    end
  end
end
