class ReferenceBuild
  def initialize(params, user, itinerary)
    @params = params
    @user = user
    @itinerary = itinerary
  end

  def reference
    reference = @user.references.new
    reference.itinerary = @itinerary
    reference.referencing_user_id = @itinerary.user.id
    reference.read_at = Time.now.utc
    reference.build_outgoing @params
    reference
  rescue
    nil
  end
end
