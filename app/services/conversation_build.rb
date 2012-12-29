class ConversationBuild
  def initialize(params, user)
    @params = params
    @user = user
  end

  def conversation
    @conversation ||= build @params, @user
  end

  private
  def build(params, user)
    itinerary = Itinerary.find params[:itinerary_id]
    conversation = itinerary.conversations.build params[:conversation]
    conversation.messages.build params[:conversation][:message]
    conversation.users = [ user, itinerary.user ]
    conversation
  rescue
    # TODO
  end
end
