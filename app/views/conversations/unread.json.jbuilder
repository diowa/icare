# frozen_string_literal: true

json.array! @conversations, partial: 'message', as: :conversation
