# frozen_string_literal: true

module UsersHelper
  def auth0_profile_picture(user, type = :square)
    if user_signed_in? && user.image?
      "#{user.image}?type=#{type}"
    else
      asset_pack_path('media/images/user.jpg')
    end
  end

  def user_profile_picture(user, size: [50, 50], type: :square, style: 'img-fluid', opts: {})
    tag :img,
        { width:  ("#{size[0]}px" if size),
          height: ("#{size[1]}px" if size),
          src:    auth0_profile_picture(user, type),
          alt:    '',
          class:  style }.merge(opts)
  end
end
