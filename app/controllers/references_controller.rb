class ReferencesController < ApplicationController

  skip_before_filter :check_admin, only: [:index]

  after_filter :mark_as_read, only: [:show]

  def index
    # TODO nested eager loading
    @references = current_user.references.desc(:updated_at).page params[:page]
  end

  def new
    @itinerary = Itinerary.find(params[:itinerary_id])
    @reference = current_user.references.build
    @reference.itinerary = @itinerary
    @reference.build_references_outgoing
  end

  def create
    @itinerary = Itinerary.find(params[:itinerary_id])
    @reference = current_user.references.build(params[:reference])
    @reference.itinerary = @itinerary
    @reference.referencing_user_id = @itinerary.user.id
    if current_user.save
      redirect_to reference_path(@reference)
    else
      flash.now[:error] = @reference.errors.full_messages
      render :new
    end
  end

  def show
    @reference = current_user.references.find(params[:id])
  end

  def edit
    @reference.outgoing_reference.content_required = true
  end

  def update
    @reference.outgoing_reference.content_required = true
    if @reference.outgoing_reference.update_attributes(params[:incoming_reference][:outgoing_reference_attributes])
      redirect_to calendar_path, flash: { success: t('flash.success.reference_updated') }
    else
      flash.now[:error] = @reference.errors.full_messages
      render "edit"
    end
  end

private

  def mark_as_read
    @reference.update_attribute(:read, Time.now.utc)
  end
end
