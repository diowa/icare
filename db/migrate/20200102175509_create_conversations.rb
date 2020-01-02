class CreateConversations < ActiveRecord::Migration[6.0]
  def change
    create_table :conversations do |t|
      t.references :conversable, polymorphic: true, index: true
      t.belongs_to :sender
      t.belongs_to :receiver

      t.timestamps null: false

      t.index %i[sender_id receiver_id], unique: true
    end

    create_table :messages do |t|
      t.belongs_to :conversation, index: true
      t.belongs_to :sender, index: true

      t.text :body
      t.datetime :read_at

      t.timestamps null: false
    end
  end
end
