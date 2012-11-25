class ReferencesController < ApplicationController

  skip_before_filter :check_admin, only: [:index]
  before_filter :check_not_myself, only: [:new, :create]

  after_filter :mark_as_read, only: [:show]

  def index
    @user = User.any_of({ username: params[:user_id] }, { uid: params[:user_id] }, { _id: params[:user_id] }).first
    @references = @user.references.desc(:updated_at).page params[:page]
  end

  def new
    @reference = current_user.references.build
    @reference.itinerary = @itinerary
    @reference.build_outgoing
  end

  def create
    @reference = Reference.build_from_params(params[:reference], current_user, @itinerary)
    if current_user.save
      redirect_to user_reference_path(current_user, @reference)
    else
      flash.now[:error] = @reference.errors.full_messages
      render :new
    end
  end

  def show
    @user = User.any_of({ username: params[:user_id] }, { uid: params[:user_id] }, { _id: params[:user_id] }).first
    @reference = @user.references.find(params[:id])
    @itinerary = @reference.itinerary
  end

  def edit
    @reference = current_user.references.find(params[:id])
  end

  def update
    @reference = current_user.references.find(params[:id])
    if @reference.update_attributes(params[:reference])
      redirect_to user_reference_path(current_user, @reference)
    else
      flash.now[:error] = @reference.errors.full_messages
      render "edit"
    end
  end

private

  def check_not_myself
    @itinerary = Itinerary.find(params[:itinerary_id])
    redirect_to root_path if @itinerary.user == current_user
  end

  def mark_as_read
    @reference.update_attribute(:read, Time.now.utc)
  end
end
