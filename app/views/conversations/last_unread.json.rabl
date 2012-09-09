object @conversations

node(:url) { |conversation| conversation_url(conversation) }

node(:message) do |conversation|
  m = conversation.messages.last
  {
    body: m.body,
    date_sent: m.created_at,
    read: m.read,
    sender:
      {
        profile_picture: m.sender.profile_picture,
        name: m.sender.name
      }
  }
end
