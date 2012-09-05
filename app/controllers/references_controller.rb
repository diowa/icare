class ReferencesController < ApplicationController

  before_filter :set_and_check_reference, except: :index

  def index
    @references = current_user.references.visible
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

  def not_relevant
    @reference.outgoing_reference.content_required = false
    if @reference.outgoing_reference.update_attributes(relevant: false)
      redirect_to calendar_path, flash: { success: t('flash.success.reference_updated') }
    else
      flash.now[:error] = @reference.errors.full_messages
      render "edit"
    end
  end

  def relevant
    @reference.outgoing_reference.content_required = false
    if @reference.outgoing_reference.update_attributes(relevant: true)
      flash.now[:success] = t('flash.success.reference_updated')
    else
      flash.now[:error] = @reference.errors.full_messages
    end
    render "edit"
  end

  def set_and_check_reference
    @reference = current_user.references.find(params[:id])
    redirect_to calendar_path, flash: { error: t('flash.error.reference_updated') } unless @reference.visible?
  end
end
