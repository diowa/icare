# OmniAuth
OMNIAUTH_MOCKED_AUTHHASH = OmniAuth::AuthHash.new(provider: 'facebook',
                                                  uid: '123456',
                                                  info: {
                                                    email: 'test@example.com',
                                                    name: 'John Doe',
                                                    first_name: 'John',
                                                    last_name: 'Doe',
                                                    image: 'http://graph.facebook.com/123456/picture?type=square',
                                                    urls: { 'Facebook' => 'http://www.facebook.com/profile.php?id=123456' } },
                                                  credentials: {
                                                    token: 'facebook token',
                                                    expires_at: 2.days.from_now.to_i,
                                                    expires: true },
                                                  extra: {
                                                    raw_info: {
                                                      id: '123456',
                                                      username: 'johndoe',
                                                      name: 'John Doe',
                                                      first_name: 'John',
                                                      last_name: 'Doe',
                                                      link: 'http://www.facebook.com/profile.php?id=123456',
                                                      birthday: '10/03/1981',
                                                      work: [
                                                        { employer: { id: '100', name: 'First Inc.' }, start_date: '0000-00' },
                                                        { employer: { id: '101', name: 'Second Ltd.' }, start_date: '0000-00' },
                                                        { employer: { id: '102', name: 'Third S.p.A.' }, start_date: '0000-00', end_date: '0000-00' }],
                                                      favorite_athletes: [
                                                        { id: '200', name: 'First Athlete' },
                                                        { id: '201', name: 'Second Athlete' }],
                                                      education: [{ school: { id: '300', name: 'A College' }, type: 'College' }],
                                                      gender: 'male',
                                                      email: 'test@example.com',
                                                      timezone: 1,
                                                      locale: 'en_US',
                                                      languages: [
                                                        { id: '113153272032690', name: 'Italian' },
                                                        { id: '106059522759137', name: 'English' },
                                                        { id: '108224912538348', name: 'French' }],
                                                      updated_time: '2012-12-16T08:49:27+0000' } })

OmniAuth.config.test_mode = true
OmniAuth.config.mock_auth[:facebook] = OMNIAUTH_MOCKED_AUTHHASH
