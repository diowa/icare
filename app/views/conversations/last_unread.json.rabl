object @conversations

node(:url) { |conversation| conversation_url(conversation) }

node(:message) do |conversation|
  m = conversation.messages.last
  {
    body: m.body,
    date_sent: m.created_at,
    read_at: m.read_at,
    sender:
      {
        # TODO: Former user object
        profile_picture: m.sender ? m.sender.profile_picture : 'http://placehold.it/25x25',
        name: m.sender ? m.sender.name : 'Former user'
      }
  }
end
