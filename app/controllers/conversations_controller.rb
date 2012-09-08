class ConversationsController < ApplicationController

  skip_before_filter :check_admin, only: [:index]

  before_filter :check_user, only: :show
  before_filter :clean_message_params, only: [:create, :update]

  after_filter :mark_as_read, only: [:show]

  def index
    # TODO nested eager loading
    @conversations = current_user.conversations
  end

  def new
    @itinerary = Itinerary.includes(:user).find(params[:itinerary_id])
    @conversation = Conversation.new
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
    @conversation = Conversation.find(params[:id])
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
    @conversation = Conversation.find(params[:id])
    @itinerary = Itinerary.find(@conversation.conversable_id)
  end

protected

  def check_user
    #@conversation = Conversation.find(params[:id])
    #redirect_to root_path, flash: { error: t('flash.error.not_authenticated') } unless current_user.conversations.include?(@conversation)
  end

private

  def clean_message_params
    params[:conversation][:message]['sender'] = current_user
    params[:conversation][:message]['unread'] = nil
  end

  def mark_as_read
    @conversation.mark_as_read(current_user)
  end
end
