# frozen_string_literal: true

class ConversationBuild
  def initialize(sender, receiver, conversable, params)
    @params = params
    @sender = sender
    @receiver = receiver
    @conversable = conversable
  end

  def conversation
    new_conversation = Conversation.new sender: sender, receiver: receiver, conversable: @conversable
    new_conversation.messages.build message
    new_conversation
  rescue
    nil
  end

  def message
    params[:message].merge sender: sender
  end

  private

  attr_reader :sender, :receiver, :params, :conversable
end
