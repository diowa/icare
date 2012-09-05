class MessagesController < ApplicationController

  before_filter :check_user

  def create
    @message = conversation.messages.create(params[:message].merge(sender: current_user))
    redirect_to conversation_path(conversation)
  end

  protected

  def conversation
    @conversation ||= Conversation.find(params[:conversation_id])
  end

  def check_user
    redirect_back_or_to root_path, flash: { error: t('flash.error.not_authenticated') } unless current_user.conversations.include?(conversation)
  end
end
