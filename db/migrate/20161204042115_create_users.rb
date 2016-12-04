class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :uid
      t.string :avatar
      t.string :wechat_openid
      t.string :open_wechat_openid
      t.integer :sex
      t.string :province
      t.string :city
      t.string :country

      t.timestamps
    end
  end
end
