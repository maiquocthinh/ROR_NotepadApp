class CreateNotesAndBackupNotesAndUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users, id: false do |t|
      t.string :id, limit: 12, null: false, primary_key: true
      t.string :email, limit: 255
      t.string :username, limit: 255
      t.string :avatar, limit: 255, default: 'https://i.imgur.com/iNsPoYP.jpg'
      t.string :hash_password, limit: 255

      t.index :email, unique: true
      t.index :username, unique: true

      t.timestamps
    end

    create_table :backup_notes, id: false do |t|
      t.string :id, limit: 13, null: false, primary_key: true
      t.text :content
      t.string :user_id, limit: 12

      t.index :user_id

      t.timestamps
    end

    add_foreign_key :backup_notes, :users, column: :user_id, on_delete: :cascade, on_update: :cascade

    create_table :notes, id: false do |t|
      t.string :id, limit: 12, null: false, primary_key: true
      t.text :content
      t.string :slug, limit: 20
      t.string :external_slug, limit: 20
      t.integer :views, default: 0
      t.boolean :need_password, default: false
      t.string :hash_password, limit: 255
      t.boolean :temporary, default: true
      t.string :user_id, limit: 12

      t.index :slug, unique: true
      t.index :external_slug, unique: true
      t.index :user_id

      t.timestamps
    end

    add_foreign_key :notes, :users, column: :user_id, on_delete: :cascade, on_update: :cascade
  end
end
