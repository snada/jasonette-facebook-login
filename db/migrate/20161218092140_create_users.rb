class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :fb_id
      t.string :fb_pic
      t.string :fb_name

      t.timestamps
    end
  end
end
