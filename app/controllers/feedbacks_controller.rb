class FeedbacksController < ApplicationController

  skip_before_filter :check_admin, only: [:index]

  def index
    @feedbacks = Feedback.includes(:user).all.desc(:updated_at).page params[:page]
    @feedbacks = @feedbacks.where(:status.ne => 'fixed') if params[:hide_fixed]
    @url = request.env['HTTP_REFERER']
  end

  def show
    @feedback = Feedback.find(params[:id])
  end

  def new
    @feedback = Feedback.new(url: params[:url])
  end

  def create
    attrs = params[:feedback]
    attrs.delete("status") unless current_user.admin?
    @feedback = Feedback.new(attrs)
    @feedback.user = current_user
    if @feedback.save
      redirect_to feedbacks_path, flash: { success: t('flash.feedback.success.create') }
    else
      flash.now[:error] = @feedback.errors.full_messages
      render :new
    end
  end

  def edit
    @feedback = Feedback.find(params[:id])
  end

  def update
    @feedback = Feedback.find(params[:id])

    if @feedback.update_attributes(params[:feedback])
      redirect_to feedbacks_path, flash: { success: t('flash.feedback.success.update') }
    else
      flash.now[:error] = @feedback.errors.full_messages
      render :edit
    end
  end

  def destroy
    @feedback = Feedback.find(params[:id])

    if current_user.admin? && @feedback.destroy
      redirect_to feedbacks_path, flash: { success: t('flash.feedback.success.destroy') }
    else
      redirect_to feedbacks_path, flash: { error: t('flash.feedback.error.destroy') }
    end
  end
end
