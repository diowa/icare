# frozen_string_literal: true

module UsersHelper
  DEFAULT_USER_PROFILE_SIZE = 40

  def auth0_profile_picture(user, type = :square)
    if user_signed_in? && user.image?
      "#{user.image}?type=#{type}"
    else
      asset_pack_path('static/user.jpg')
    end
  end

  def user_profile_picture(user, size: DEFAULT_USER_PROFILE_SIZE, type: :square, options: {})
    tag.img(**{
      width:  size,
      height: size,
      src:    auth0_profile_picture(user, type),
      alt:    '',
      class:  'img-fluid'
    }.merge(options))
  end
end
