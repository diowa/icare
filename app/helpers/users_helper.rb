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
        class: [("verified" if user.class == User.model_name && user.facebook_verified?), ("thumbnail" if options[:thumbnail]), options[:class]].compact.join(" ") }.merge(options[:html]))
  end

  def nationality_flag(user, tooltip = true, tooltip_placement = "bottom")
    options = { class: "flag-#{user.nationality.downcase}" }
    options = options.merge({ rel: "tooltip", title: user.nationality_name, data: { placement: tooltip_placement } }) if tooltip
    content_tag(:i, nil, options) if user.nationality?
  end

  def navbar_notifications(title, opts = {})
    options = { icon: "globe",
                id: "notifications",
                link: nil,
                mock: false,
                unread: 0 }.merge(opts)
    content = "<p><b>TODO</b></p>#{"<p><small>#{options[:link]}</small></p>" if options[:link]}"
    content_tag(:li,
                class: "notifications#{(" read" if options[:unread] == 0)}#{(" mock" if options[:mock])}", 
                id: "navbar-notifications-#{options[:id]}") do
      content_tag(:a,
                  content_tag(:i, nil, class: "icon-#{options[:icon]}") + (content_tag(:span, options[:unread], class: "label label-important count") if options[:unread] > 0),
                  href: "#",
                  rel: "popover",
                  data: { placement: 'bottom', content: content, title: title, html: true, trigger: "manual" })
    end
  end

end
