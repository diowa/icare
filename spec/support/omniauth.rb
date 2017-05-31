# frozen_string_literal: true

OMNIAUTH_MOCKED_AUTHHASH = OmniAuth::AuthHash.new('provider' => 'facebook',
                                                  'uid' => '123456',
                                                  'info' => {
                                                    'email' => 'test@example.com',
                                                    'name' => 'John Doe',
                                                    'image'  => 'http://graph.facebook.com/123456/picture'
                                                  },
                                                  'credentials' => {
                                                    'token'  => 'token',
                                                    'expires_at' => 2.days.from_now.to_i,
                                                    'expires' => true
                                                  },
                                                  'extra' => {
                                                    'raw_info' => {
                                                      'name' => 'test@example.com',
                                                      'email' => 'John Doe',
                                                      'id' => '123456'
                                                    }
                                                  })

OmniAuth.config.test_mode = true
OmniAuth.config.mock_auth[:facebook] = OMNIAUTH_MOCKED_AUTHHASH
