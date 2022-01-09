class CreateDevices < ActiveRecord::Migration[6.0]
  def change
    create_table :devices do |t|
      t.integer :user_id, null: false
      t.string :uuid, null: false, limit: 64
      t.string :refresh_token, null: false, limit: 32
      t.string :last_issued, null: false, limit: 32
      t.datetime :last_issued_at, null: false
      t.integer :expires_at, null: false
      t.string :user_agent, null: false
      t.string :ip, null: false, limit: 32
      t.string :client, null: false, limit: 16
      t.string :client_version, null: false, limit: 32
      t.timestamps

      t.index %i[user_id]
      t.index %i[uuid], unique: true
      t.index %i[refresh_token], unique: true
    end
  end
end
