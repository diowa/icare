class CsUserImporter
  def self.import_from(url)

    html_document = RestClient.get(url)
    doc = Nokogiri::HTML(html_document)
    generalinfo_query = "//th[@class='generalinfo' and contains(.,'%s')]"
    court_query = "//strong[contains(.,'%s')]"

    #TODO token validation
    name = (begin doc.xpath("//h1[@class='profile']").first.text.strip rescue nil end)
    cs_profile_image = (begin doc.xpath("//img[@alt='#{name}']//@src").first.text rescue nil end) if name
    cs_user = {
      email:              "#{name.downcase.gsub(/\W/, "")}@cs.fake",
      password:           "cesidio",
      name:               name,
      about:              (begin doc.xpath("//h2[@id='description_title']").first.next.text.strip rescue nil end),
      gender:             (begin doc.xpath(sprintf(generalinfo_query, "gender")).first.next.text.strip.downcase rescue nil end),
      occupation:         (begin doc.xpath(sprintf(generalinfo_query, "occupation")).first.next.text.strip rescue nil end),
      education:          (begin doc.xpath(sprintf(generalinfo_query, "education")).first.next.text.strip rescue nil end),
      birthday:           (begin doc.xpath(sprintf(generalinfo_query, "age")).first.next.text.strip.to_i.years.ago.midnight.utc rescue nil end),
      interests:          (begin doc.xpath("//h2[@id='interests_title']").first.next.text.strip rescue "" end),
      music_movies_books: (begin doc.xpath("//h2[@id='music_movies_books_title']").first.next.text.strip rescue "" end),
      cs_profile_image:   cs_profile_image
    }
    cs_court = {
      in_house_kids:   (begin doc.xpath(sprintf(court_query, "Has children")).first.next.text.strip.downcase == "yes" rescue false end),
      can_host_kids:   (begin doc.xpath(sprintf(court_query, "Can host children")).first.next.text.strip.downcase == "yes" rescue false end),
      in_house_pets:   (begin doc.xpath(sprintf(court_query, "Has pets")).first.next.text.strip.downcase == "yes" rescue false end),
      can_host_pets:   (begin doc.xpath(sprintf(court_query, "Can host pets")).first.next.text.strip.downcase == "yes" rescue false end),

      smoking_allowed: (begin doc.xpath(sprintf(court_query, "No smoking allowed")).empty? rescue false end),

      description:     (begin doc.xpath("//h2[@id='couchinfo']//following-sibling::p").text.strip rescue nil end)
    }
    new_user = User.new(cs_user)
    new_user.build_court(cs_court)
    new_user
  end
end