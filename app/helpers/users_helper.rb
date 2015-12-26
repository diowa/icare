module UsersHelper
  def facebook_profile_picture(user, type = :square)
    if user_signed_in?
      "//graph.facebook.com/#{user.class == User ? user.uid : user}/picture?type=#{type}"
    else
      '//fbstatic-a.akamaihd.net/rsrc.php/v2/yo/r/UlIqmHJn-SK.gif'
    end
  end

  def user_profile_picture(user, size: [50, 50], type: :square, style: 'img-responsive', opts: {})
    tag :img,
        { width: ("#{size[0]}px" if size),
          height: ("#{size[1]}px" if size),
          src: facebook_profile_picture(user, type),
          alt: '',
          class: [('verified' if user.class == User.model_name && user.facebook_verified?), style].compact.join(' ')
        }.merge(opts)
  end

  def friends_with_privacy(friends)
    case friends
    when 0...10
      '10-'
    when 10...100
      "#{friends / 10}0+"
    when 100...1000
      "#{friends / 100}00+"
    when 1000...5000
      "#{friends / 1000}000+"
    else
      '5000'
    end
  end

  def mutual_friends(user1, user2, limit = 5)
    return if user1 == user2
    mutual_friends_list = user1.facebook_friends & user2.facebook_friends
    return unless mutual_friends_list.any?
    html = content_tag(:div, t('.common_friends'), class: 'tag tag-facebook')
    mutual_friends_list.sample(limit).each do |mutual_friend|
      html << render_mutual_friend(mutual_friend)
    end
    html << link_to(t('.and_others', count: mutual_friends_list.size - 5), '#', class: 'disabled tag mock') if mutual_friends_list.size - 5 > 0
    html
  end

  def language_tags(user)
    return unless user.languages && user.languages.any?
    render_common_tags = (user != current_user)
    render_tags user.languages, current_user.languages, render_common_tags: render_common_tags, content: t('.likes'), class: 'description-facebook'

    common_languages = get_common_tags(current_user.languages, user.languages) if render_common_tags
    html = user.languages.map { |language| render_tag t('.language', language: language['name']), (render_common_tags && common_languages.include?(language['id'])) }
    html.join.html_safe
  end

  def work_and_education_tags(user, field)
    return unless user[field] && user[field].any?
    user_work_or_edu = remap_work_or_edu_tags(user[field], field)
    my_field = current_user[field]
    if (render_common_work_or_edu = (user != current_user) && my_field && my_field.any?)
      my_work_or_edu = remap_work_or_edu_tags(my_field, field)
    end
    render_tags user_work_or_edu, my_work_or_edu, render_common_tags: render_common_work_or_edu, content: User.human_attribute_name(field), class: 'tag tag-facebook'
  end

  def favorite_tags(user, user_favorites)
    return unless user_favorites && user_favorites.any?
    render_tags user_favorites, current_user.facebook_favorites, render_common_tags: (user != current_user), content: t('.likes'), class: 'tag tag-facebook tag-sm', css_class: 'tag-sm'
  end

  private

  def remap_work_or_edu_tags(field, type)
    key = (type == :work ? 'employer' : 'school')
    field.map { |h| { 'name' => h[key]['name'], 'id' => h[key]['id'] } }
  end

  def get_common_tags(my_tags, user_tags)
    return [] if my_tags.nil? || my_tags.empty?
    my_tags.map { |tag| tag['id'] } & user_tags.map { |tag| tag['id'] }
  end

  def render_mutual_friend(mutual_friend)
    content_tag(:div, class: 'tag tag-mutual-friend') do
      user_profile_picture(mutual_friend['id'], size: [25, 25], style: nil) +
        mutual_friend['name']
    end
  end

  def render_tags(user_tags, my_tags, opts = {})
    options = { render_common_tags: false }.merge(opts)
    common_tags = get_common_tags(my_tags, user_tags) if options[:render_common_tags]
    html = content_tag(:div, options[:content], class: options[:class])
    user_tags.each do |tag|
      html << render_tag(tag['name'], options[:render_common_tags] && common_tags.include?(tag['id']), options[:css_class])
    end
    html
  end

  def render_tag(tag_text, common, css_class = nil)
    content_tag :div, tag_text, class: ['tag', ('tag-common' if common), css_class].compact.join(' ')
  end
end
