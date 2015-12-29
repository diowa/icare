class ConversationsController < ApplicationController
  after_action :mark_as_read, only: [:show]

  def index
    # NOTE nested eager loading is not available
    @conversations = current_user.conversations.includes(:users).desc(:updated_at).page params[:page]
  end

  def show
    @conversation = current_user.conversations.includes(:users).find(params[:id])
    @itinerary = Itinerary.find(@conversation.conversable_id)
  end

  def new
    @itinerary = Itinerary.includes(:user).find(params[:itinerary_id])
    @conversation = current_user.conversations.build
  end

  def create
    @itinerary = Itinerary.includes(:user).find(params[:itinerary_id])
    @conversation = ConversationBuild.new(permitted_params.conversation, current_user, @itinerary).conversation
    if @conversation.save
      redirect_to conversation_path(@conversation)
    else
      # TODO: conversation may be nil
      flash.now[:error] = @conversation.errors.full_messages
      render :new
    end
  end

  def update
    @conversation = current_user.conversations.find(params[:id])
    @conversation.messages.build ConversationBuild.new(permitted_params.conversation, current_user, @itinerary).message
    if @conversation.save
      redirect_to conversation_path(@conversation)
    else
      flash.now[:error] = @conversation.errors.full_messages
      @conversation.reload
      @itinerary = Itinerary.find(@conversation.conversable_id)
      render :show
    end
  end

  def unread
    # NOTE nested eager loading is not available
    respond_to do |format|
      format.json do
        @conversations = current_user.conversations.includes(:users).unread(current_user).desc(:updated_at).limit(5)
      end
      format.html do
        redirect_to :conversations
      end
    end
  end

  private

  def mark_as_read
    @conversation.mark_as_read(current_user)
  end
end
