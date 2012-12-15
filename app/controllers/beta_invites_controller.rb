class BetaInvitesController < ApplicationController

  before_filter :check_admin

  def index
    @beta_invites = BetaInvite.all
  end

  def new
    @beta_invite = BetaInvite.new
  end

  def create
    @beta_invite = BetaInvite.new(params[:beta_invite])

    if @beta_invite.save
      redirect_to beta_invites_path, notice: 'Beta invite was successfully created.'
    else
      render :new
    end
  end

  def destroy
    @beta_invite = BetaInvite.find(params[:id])
    @beta_invite.destroy
    redirect_to beta_invites_path
  end
end
