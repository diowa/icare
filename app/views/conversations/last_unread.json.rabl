# frozen_string_literal: true

object @conversations

node(:url) { |conversation| conversation_url(conversation) }

node(:message) do |conversation|
  m = conversation.messages.last
  {
    body:      m.body,
    date_sent: m.created_at,
    read_at:   m.read_at,
    sender:
               {
                 # TODO: Former user object
                 image: m.sender&.image? ? m.sender.image : image_path('user.jpg'),
                 name:  m.sender ? m.sender.name : 'Former user'
               }
  }
end
