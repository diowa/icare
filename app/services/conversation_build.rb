class ConversationBuild
  def initialize(params, user, itinerary)
    @params = params
    @user = user
    @itinerary = itinerary
  end

  def conversation
    result = @itinerary.conversations.build
    result.messages.build message
    result.users = [@user, @itinerary.user]
    result
  rescue
    nil
  end

  def message
    result = @params[:message]
    result.merge! sender: @user
  end
end
