class CreateFeedbacks < ActiveRecord::Migration[5.2]
  def change
    create_table :feedbacks do |t|
      t.string :category, default: 'bug'
      t.text :message
      t.string :url
      t.string :status, default: 'open'
      t.references :user, foreign_key: true

      t.timestamps null: false
    end
  end
end
