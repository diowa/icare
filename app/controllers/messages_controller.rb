class MessagesController < ApplicationController

  def create
    conversation = current_user.conversations.find(params[:conversation_id])
    if conversation.messages.create(params[:message].merge(sender: current_user))
      redirect_to conversation_path(conversation)
    else
      redirect_to conversation_path(conversation), flash: { error: t('flash.messages.error.create') }
    end
  end
end
