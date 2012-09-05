module UsersHelper

  def facebook_profile_picture(user, type = :square)
    "http://graph.facebook.com/#{user.class == User ? user.uid : user}/picture?type=#{type}"
  end

  def user_profile_picture(user, opts = {})
    options = { size: [50, 50],
                type: :square,
                thumbnail: true,
                html: {}
              }.merge(opts)
    tag(:img,
        { width: ("#{options[:size][0]}px" if options[:size][0]),
        height: ("#{options[:size][1]}px" if options[:size][1]),
        src: facebook_profile_picture(user, options[:type]),
        alt: "",
        class: [("thumbnail" if options[:thumbnail]), options[:class]].compact.join(" ") }.merge(options[:html]))
  end

  def nationality_flag(user, tooltip = true, tooltip_placement = "bottom")
    options = { class: "flag-#{user.nationality.downcase}" }
    options = options.merge({ rel: "tooltip", title: user.nationality_name, data: { placement: tooltip_placement } }) if tooltip
    content_tag(:i, nil, options) if user.nationality?
  end
end
