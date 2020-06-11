# frozen_string_literal: true

module UsersHelper
  def facebook_profile_picture(user, type = :square)
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
          src:    facebook_profile_picture(user, type),
          alt:    '',
          class:  [('verified' if user.facebook_verified?), style].compact.join(' ') }.merge(opts)
  end

  def language_tags(user)
    return unless user.languages&.any?

    render_common_tags = (user != current_user)
    common_languages = get_common_tags(current_user.languages, user.languages) if render_common_tags
    html = user.languages.map { |language| render_tag t('.language', language: language['name']), (render_common_tags && common_languages.include?(language['id'])) }
    safe_join html
  end

  def favorite_tags(user, user_favorites)
    return unless user_favorites&.any?

    render_tags user_favorites, current_user.facebook_favorites, render_common_tags: (user != current_user), content: t('.likes'), class: 'tag tag-facebook tag-sm', css_class: 'tag-sm'
  end

  private

  def get_common_tags(my_tags, user_tags)
    return [] if my_tags&.empty?

    (my_tags.map { |tag| tag['id'] }) & (user_tags.map { |tag| tag['id'] })
  end

  def render_tags(user_tags, my_tags, opts = {})
    options = { render_common_tags: false }.merge(opts)
    common_tags = get_common_tags(my_tags, user_tags) if options[:render_common_tags]
    html = tag.div(options[:content], class: options[:class])
    user_tags.each do |tag|
      html << render_tag(tag['name'], options[:render_common_tags] && common_tags.include?(tag['id']), options[:css_class])
    end
    html
  end

  def render_tag(tag_text, common, css_class = nil)
    tag.div tag_text, class: ['tag', ('tag-common' if common), css_class].compact.join(' ')
  end
end
