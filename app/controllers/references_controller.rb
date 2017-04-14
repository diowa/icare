# frozen_string_literal: true

class ReferencesController < ApplicationController
  before_action :set_user, only: %i[index show update]
  before_action :check_not_myself, only: %i[new create]

  after_action :mark_as_read, only: [:show]

  def index
    @references = @user.references.desc(:updated_at).page params[:page]
  end

  def new
    @reference = current_user.references.build
    @reference.itinerary = @itinerary
    @reference.build_outgoing
  end

  def create
    @reference = ReferenceBuild.new(reference_params, current_user, @itinerary).reference
    if @reference.save
      redirect_to user_reference_path(current_user, @reference)
    else
      flash.now[:error] = @reference.errors.full_messages
      render :new
    end
  end

  def show
    @reference = @user.references.find params[:id]
    @itinerary = @reference.itinerary
  end

  def update
    @reference = current_user.references.find params[:id]
    if @reference.build_outgoing(reference_params) && @reference.save
      redirect_to user_reference_path(current_user, @reference)
    else
      @itinerary = @reference.itinerary
      flash.now[:error] = @reference.errors.full_messages
      render :show
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def reference_params
    params.require(:reference).permit :body, :rating
  end

  def check_not_myself
    @itinerary = Itinerary.find(params[:itinerary_id])
    redirect_to root_path if @itinerary.user == current_user
  end

  def mark_as_read
    @reference.update_attribute :read_at, Time.now.utc
  end
end
