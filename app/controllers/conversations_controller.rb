class ConversationsController < ApplicationController

  skip_before_filter :check_admin, only: [:index]

  before_filter :clean_message_params, only: [:create, :update]

  after_filter :mark_as_read, only: [:show]

  def index
    # TODO nested eager loading
    @conversations = current_user.conversations.includes(:users).desc(:updated_at).page params[:page]
  end

  def unread
    # TODO nested eager loading
    respond_to do |format|
      format.json do
        @conversations = current_user.conversations.includes(:users).unread(current_user).desc(:updated_at).limit(5)
      end
      format.html do
        redirect_to :conversations
      end
    end
  end

  def new
    @itinerary = Itinerary.includes(:user).find(params[:itinerary_id])
    @conversation = current_user.conversations.build
  end

  def create
    @itinerary = Itinerary.find(params[:itinerary_id])
    @conversation = @itinerary.conversations.build(params[:conversation])
    @conversation.messages.build(params[:conversation][:message])
    @conversation.users << current_user
    @conversation.users << @itinerary.user
    if @conversation.save
      redirect_to conversation_path(@conversation)
    else
      flash.now[:error] = @conversation.errors.full_messages
      render :new
    end
  end

  def update
    @conversation = current_user.conversations.find(params[:id])
    @conversation.messages.build(params[:conversation][:message])
    if @conversation.save
      redirect_to conversation_path(@conversation)
    else
      flash.now[:error] = @conversation.errors.full_messages
      @conversation.reload
      @itinerary = Itinerary.find(@conversation.conversable_id)
      render :show
    end
  end

  def show
    @conversation = current_user.conversations.includes(:users).find(params[:id])
    @itinerary = Itinerary.find(@conversation.conversable_id)
  end

private

  def clean_message_params
    params[:conversation][:message]['sender'] = current_user
    params[:conversation][:message]['read'] = nil
  end

  def mark_as_read
    @conversation.mark_as_read(current_user)
  end
end
