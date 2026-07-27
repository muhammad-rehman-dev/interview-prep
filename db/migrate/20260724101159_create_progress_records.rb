class CreateProgressRecords < ActiveRecord::Migration[7.2]
  def change
    create_table :progress_records do |t|
      t.string :visitor_token
      t.string :record_type
      t.integer :record_id
      t.string :status
      t.text :notes

      t.timestamps
    end
    add_index :progress_records, :visitor_token
  end
end
