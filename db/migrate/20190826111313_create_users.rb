# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[5.2]
  def self.up
    create_table :users do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      # t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      # t.string   :reset_password_token
      # t.datetime :reset_password_sent_at

      ## Rememberable
      # t.datetime :remember_created_at

      ## Trackable
      # t.integer  :sign_in_count, default: 0, null: false
      # t.datetime :current_sign_in_at
      # t.datetime :last_sign_in_at
      # t.inet     :current_sign_in_ip
      # t.inet     :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      # Omniauthable
      t.string :provider, null: false
      t.string :uid, null: false

      # Uneditable user info
      t.string :bio
      t.date   :birthday
      t.string :gender
      t.string :image
      t.jsonb  :languages, array: true, default: []
      t.string :name

      # Editable user info
      t.string  :locale
      t.boolean :send_email_messages,     default: false
      t.string  :telephone
      t.string  :time_zone,               default: 'UTC'
      t.decimal :vehicle_avg_consumption, default: APP_CONFIG.fuel_consumption, precision: 5, scale: 2

      # Account status
      t.boolean :admin,  default: false
      t.boolean :banned, default: false

      # Fields from Facebook
      t.string   :access_token
      t.datetime :access_token_expires_at

      t.datetime :facebook_data_cached_at,                 default: '2012-09-06'
      t.jsonb    :facebook_favorites,      array: true,    default: []
      t.jsonb    :facebook_permissions,    array: true,    default: []
      t.boolean  :facebook_verified,                       default: false

      # Uncomment below if timestamps were not included in your original model.
      t.timestamps null: false
    end

    add_index :users, :email, unique: true
    add_index :users, %i[provider uid], unique: true
    # add_index :users, :reset_password_token, unique: true
    # add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true
  end

  def self.down
    drop_table :users
  end
end
