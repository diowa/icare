class AddSenderUniqueIdToConversations < ActiveRecord::Migration[6.0]
  def change
    remove_index :conversations, %i[sender_id receiver_id]
    add_index :conversations, %i[sender_id receiver_id conversable_type conversable_id], name: 'unique_index_for_sender', unique: true
  end
end
