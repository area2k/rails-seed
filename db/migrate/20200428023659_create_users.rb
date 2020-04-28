class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :uuid, null: false, limit: 64
      t.string :email, null: false, limit: 128
      t.string :first_name, null: false, limit: 64
      t.string :last_name, null: false, limit: 64
      t.string :locale, null: false, limit: 8, default: 'en-US'
      t.string :password_digest, limit: 64
      t.string :password_reset_token, limit: 32
      t.boolean :password_stale, null: false, default: false
      t.timestamps

      t.index %i[uuid], unique: true
      t.index %i[email], unique: true
    end
  end
end
