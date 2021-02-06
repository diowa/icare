class RenameOpenFeedbacks < ActiveRecord::Migration[6.1]
  def up
    Feedback.where(status: 'open').update_all status: 'normal'
    change_column_default :feedbacks, :status, 'normal'
  end

  def down
    Feedback.where(status: 'normal').update_all status: 'open'
    change_column_default :feedbacks, :status, 'open'
  end
end
