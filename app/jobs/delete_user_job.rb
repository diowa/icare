# frozen_string_literal: true

class DeleteUserJob < ApplicationJob
  queue_as :delete_user_queue

  def perform(user_uid)
    AuthorizationService.delete_user user_uid
  end
end
