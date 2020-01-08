# frozen_string_literal: true

class ConversationsController < ApplicationController
  after_action :mark_as_read, only: [:show]

  def index
    @conversations = current_user.conversations.order(updated_at: :desc).page params[:page]
  end

  def show
    @conversation = current_user.conversations.find(params[:id])
    @itinerary = Itinerary.find(@conversation.conversable_id)
  end

  def new
    @itinerary = Itinerary.includes(:user).find(params[:itinerary_id])
    @conversation = current_user.conversations.build
  end

  def create
    @itinerary = Itinerary.includes(:user).find(params[:itinerary_id])
    @conversation = ConversationBuild.new(current_user, @itinerary.user, @itinerary, conversation_params).conversation
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
    @conversation.messages.build ConversationBuild.new(current_user, nil, nil, conversation_params).message
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
    respond_to do |format|
      format.json do
        @conversations = current_user.conversations.unread(current_user).order(updated_at: :desc).limit(5)
      end
      format.html do
        redirect_to :conversations
      end
    end
  end

  private

  def conversation_params
    params.require(:conversation).permit message: [:body]
  end

  def mark_as_read
    @conversation.mark_as_read!(current_user)
  end
end
