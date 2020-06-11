# frozen_string_literal: true

module ConversationsHelper
  def message_classes(alternate, message, current_user)
    [('alternate' if alternate), ('unread' if message.sender != current_user && message.unread?)].join(' ')
  end

  def message_timestamp(message)
    tag.small(title: I18n.l(message.created_at.in_time_zone(current_user.time_zone), format: :long), class: 'pull-right text-muted') do
      I18n.t('conversations.messages.time_ago', time: distance_of_time_in_words(message.created_at, Time.now.utc, include_seconds: true))
    end
  end

  def message_readat(message)
    tag.small(class: 'text-muted') do
      tag.span(nil, class: 'fa fa-check') + ' ' +
        I18n.t('conversations.messages.seen', date: l(message.read_at.in_time_zone(current_user.time_zone), format: :short))
    end
  end

  def new_or_show_conversation_path(conversation)
    conversation&.persisted? ? conversation_path(conversation) : new_conversation_path(itinerary_id: conversation.conversable_id)
  end
end
