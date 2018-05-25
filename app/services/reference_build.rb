# frozen_string_literal: true

class ReferenceBuild
  def initialize(params, user, itinerary)
    @params    = params
    @user      = user
    @itinerary = itinerary
  end

  def reference
    reference = @user.references.new itinerary: @itinerary,
                                     referencing_user_id: @itinerary.user.id,
                                     read_at: Time.now.utc
    reference.build_outgoing @params
    reference
  rescue
    nil
  end
end
