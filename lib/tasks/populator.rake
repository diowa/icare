require 'csv'

namespace :db do

  desc 'Delete fake users from database'
  task clean_fake_users: :environment do
    User.delete_all(conditions: {email: /\.fake$/})
  end

  desc 'Cleanups database'
  task clean: :environment do
    User.all.each do |user|
      user.update_attribute(:hospitality_requests, [])
      user.update_attribute(:hospitality_request_days, [])
      user.update_attribute(:hospitality_outgoing_invites, [])
      user.update_attribute(:hospitality_outgoing_invite_days, [])
      user.update_attribute(:conversation_ids, [])
      user.update_attribute(:notifications, [])
      user.update_attribute(:reference_ids, [])
      user.update_attribute(:references, [])
    end
    Conversation.delete_all
    Reference.delete_all
    City.all.each do |city|
      city.update_attribute(:hospitality_proposal_days, [])
    end
  end

  namespace :populate do

    task cities: :environment do
      place =  JSON.parse(File.read(File.join(Rails.root, 'spec', 'fixtures', 'london_city.json')))
      city = Factory.create(:city, place: place)
    end

    desc 'Populates the database with couchsurfing users'
    task cs_users: :environment do
      require "cs_user_importer"
      User.delete_all(conditions: {email: /@cs\.fake$/})
      users_with_username = ["marton78", "marsen", "birlino", "janluk75", "diabol.ica", "agagajownik", "simonbariitaly", "jmann48", "vakirolo", "claudiopo", "soipo", "giuseppe_", "dgates", "caroldisegna", "ask_g"]
      users_with_profile_id = ["50EKC6A", "4Q2HIT0", "99EJXBA", "7CR1YY0"]
      username_urls = users_with_username.map{ |u| "http://www.couchsurfing.org/people/#{u}"}
      profile_urls = users_with_profile_id.map{ |u| "http://www.couchsurfing.org/profile.html?id=#{u}"}
      incentives = [
        { file_name: "spaghetti.jpg", title: "Cooking Italian Pasta", description: "I enjoy very much cooking and if you host me I will be very happy to cook and share a meal with you!" },
        { file_name: "massage.jpg", title: "Massage", description: "I am specialized in massages, and I am very happy to help you relax your tensions" },
        { file_name: "guitar.jpg", title: "Guitar lesson", description: "Music is my passion, I am happy to teach you all I know about it!" },
        { file_name: "graphic_design.jpg", title: "Computer graphics", description: "My daily job is to design for a famous jornal. If you have some questions about computer graphics, I am willing to teach you what I know about it" }
      ]
      court_sources = [ {lat: 51.51, lng: -0.16}, {lat: 51.54, lng: -0.13},
                        {lat: 51.52, lng: -0.15}, {lat: 51.55, lng: -0.12},
                        {lat: 51.53, lng: -0.14}, {lat: 51.56, lng: -0.11} ]
      (username_urls + profile_urls).each do |url|
        user = CsUserImporter.import_from(url)
        if user
          incentive_sample = incentives.sample.dup
          img = File.open(File.join(Rails.root, 'spec', 'fixtures', 'incentive_photos', incentive_sample.delete(:file_name)))
          photo = user.photos.create(image: img)
          user.incentives.create(incentive_sample.merge!(photo_id: photo.id))
          folder = Dir.open(File.join(Rails.root, 'spec', 'fixtures', 'court_photos', [1,2,3].sample.to_s))
          entries = folder.entries.select{|e| e =~ /\.JPG$/}
          photo_ids = []
          entries.each do |entry|
            img = File.open(File.join(folder.path, entry))
            photo = user.photos.create(image: img)
            photo_ids << photo.id
          end
          #user.court.photo_ids = photo_ids
          #user.court.source = court_sources.sample
          FactoryGirl.create(:court, user: user, photo_ids: photo_ids, source: court_sources.sample)
          user.save
          user.activate!
          print "."
        else
          print user.errors.full_messages
          print "F"
        end
      end
      puts ""
    end

    desc 'Populates the database with facebook users'
    task fb_users: :environment do
      User.delete_all(conditions: {email: /@fb\.fake$/})
      incentives = [
        { file_name: "spaghetti.jpg", title: "Cooking Italian Pasta", description: "I enjoy very much cooking and if you host me I will be very happy to cook and share a meal with you!" },
        { file_name: "massage.jpg", title: "Massage", description: "I am specialized in massages, and I am very happy to help you relax your tensions" },
        { file_name: "guitar.jpg", title: "Guitar lesson", description: "Music is my passion, I am happy to teach you all I know about it!" },
        { file_name: "graphic_design.jpg", title: "Computer graphics", description: "My daily job is to design for a famous jornal. If you have some questions about computer graphics, I am willing to teach you what I know about it" }
      ]

      csv = CSV.parse(File.read(File.join(Rails.root, 'spec', 'fixtures', 'facebook_public_users.csv')))
      csv.first.each do |uid|
        response = RestClient.get "http://graph.facebook.com/#{uid}"
        return unless response.code == 200
        user_data = JSON.parse(response)
        begin
        user = Factory.create(:facebook_user,
                               password: "#{user_data["id"]}",
                               email: "#{user_data["id"]}@facebook.fake",
                               name: "#{user_data["name"]}",
                               city: City.first,
                               about: (user_data["bio"] || user_data["about"]),
                               uid: user_data["id"],
                               nationality: Country.all.map(&:code).sample)
        incentive_sample = incentives.sample.dup
        img = File.open(File.join(Rails.root, 'spec', 'fixtures', 'incentive_photos', incentive_sample.delete(:file_name)))
        photo = user.photos.create(image: img)
        user.incentives.create(incentive_sample.merge!(photo_id: photo.id))
        folder = Dir.open(File.join(Rails.root, 'spec', 'fixtures', 'court_photos', [1,2,3].sample.to_s))
        entries = folder.entries.select{|e| e =~ /\.JPG$/}
        photo_ids = []
        entries.each do |entry|
          img = File.open(File.join(folder.path, entry))
          photo = user.photos.create(image: img)
          photo_ids << photo.id
        end
        FactoryGirl.create(:court, user: user, photo_ids: photo_ids)
        rescue
        end
        sleep 1.second #prevents flooding
        print "."
      end
      puts ""
    end

    desc 'Populates the database with requests and invites'
    task requests: :environment do
      Delorean.time_travel_to 1.month.ago
      puts "Travelled back to #{Date.today}"
      users = User.all.map
      request_comment_samples = ["Hello! I will be in London for a few days, thinking to go to a concert, enjoying the nightlife, and trying to make a real contact with locals.",
                                 "First time in london, would love to do long walks in the city, hoping to meet a host that will show me around and spend some time with me",
                                 "I am doing some long time traveling around europe, will stop in london for few days. I would be glad to help making good parties at home",
                                 "First leg of our trip. Would like to meet other Englander's for drinks or partying. Will need a couch from the 11th-13th, the first two nights we will be in a hotel getting oriented. This is our first time in Europe, so all we know is what we've seen on T.V., read, and have heard from others who have been there."]
      invite_comment_samples = ["you are welcome in my place", "I will be glad to host you in my court", "We share the same interests so you are welcome!"]

      guests, hosts = User.where(email: /\.fake$/).shuffle.in_groups(2, false)

      puts "Creating requests:"
      guests.each do |user|
        num = rand(3)
        dates = (num.days.from_now.to_date..((num + rand(7)).days.from_now.to_date)).to_a.join(",")
        hospitality_request = user.hospitality_requests.build(city: City.first,
                                                              comment: request_comment_samples.sample,
                                                              dates: dates,
                                                              num_people: (1+rand(5)) )
        if user.save
          print "."
        else
          print "F"
        end
      end
      puts ""
      puts "Creating invites:"
      hosts.each do |user|
        guests.sample(2).each do |another_user|
          dates = another_user.hospitality_request_days.first(rand(7)).map{|request_day| request_day.date.strftime}
          dates_actions = dates.inject({}) {|dates_actions, date| dates_actions.merge(date => "invite")}
          hospitality_request = another_user.hospitality_requests.first
          hospitality_outgoing_invite = user.hospitality_outgoing_invites.build(message: invite_comment_samples.sample,
                                                                                dates: dates_actions,
                                                                                city_id: hospitality_request.city.id,
                                                                                request_id: hospitality_request.id,
                                                                                invited_user_id: hospitality_request.user.id)
        end
        if user.save
          print ".."
        else
          print "FF"
        end
      end
      puts ""

      [guests, hosts].flatten.each(&:reload)

      puts "Accepting invites:"
      guests.each do |user|
        request = user.hospitality_requests.first
        hospitality_incoming_invite = request.incoming_invites.first
        next unless hospitality_incoming_invite
        request_days = user.hospitality_request_days_for(request.id).where(:"incoming_invite_days.inviting_user_id" => hospitality_incoming_invite.inviting_user.id).sample(2).map{|d| d.date.strftime}
        next if request_days.empty?
        days_with_actions = request_days.inject({}) {|request_days, date| request_days.merge(date => "accept") }
        message = "thanks for hosting me I accept #{days_with_actions.size} days"
        errors = hospitality_incoming_invite.update_incoming_invite_days(dates: days_with_actions, message: message)
        if errors.empty?
          print "."
        else
          print "F"
        end
      end
      puts ""
      Delorean.back_to_the_present

      [guests, hosts].flatten.each(&:reload)

      puts "Creating references:"
      [guests, hosts].flatten.each do |user|
        user.references.each do |reference|
          reference.outgoing_reference.content_required = true
          reference.outgoing_reference.update_attributes(message: "From #{user.name} to #{reference.referencing_user.name}", rating: [-1,0,1].sample, relevant: true)
          if user.save
            print "."
          else
            print "F"
          end
        end
      end
      puts ""


      guests, hosts = User.where(email: /\.fake$/).shuffle.in_groups(2, false)

      puts "Creating requests:"
      guests.each do |user|
        num = rand(3)
        dates = (num.days.from_now.to_date..((num + rand(7)).days.from_now.to_date)).to_a.join(",")
        hospitality_request = user.hospitality_requests.build(city: City.first,
                                                              comment: request_comment_samples.sample,
                                                              dates: dates,
                                                              num_people: (1+rand(5)) )
        if user.save
          print "."
        else
          print "F"
        end
      end
      puts ""
      puts "Creating invites:"
      hosts.each do |user|
        guests.sample(2).each do |another_user|
          dates = another_user.hospitality_request_days.first(rand(7)).map{|request_day| request_day.date.strftime}
          dates_actions = dates.inject({}) {|dates_actions, date| dates_actions.merge(date => "invite")}
          hospitality_request = another_user.hospitality_requests.first
          hospitality_outgoing_invite = user.hospitality_outgoing_invites.build(message: invite_comment_samples.sample,
                                                                                dates: dates_actions,
                                                                                city_id: hospitality_request.city.id,
                                                                                request_id: hospitality_request.id,
                                                                                invited_user_id: hospitality_request.user.id)
        end
        if user.save
          print ".."
        else
          print "FF"
        end
      end
      puts ""

    end
  end
end