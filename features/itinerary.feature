Feature: Itinerary
  In order to share itineraries
  User should be able to manage them

  Scenario: A user should be allowed to create new itineraries
    When a user logs in

  Scenario: A user should be allowed to search itineraries
    When a user logs in
    #Then he should be able to search itineraries

  Scenario: A male user should be allowed to see his itineraries
    When a male user with itineraries logs in
    Then he should be able to manage his itineraries

  Scenario: A female user should be allowed to see her itineraries
    When a female user with itineraries and pink itineraries logs in
    Then she should be able to manage her itineraries

  Scenario: Malicious titles and descriptions are correctly managed
    Given an itinerary with a malicious title and description
    When a user searches for an itinerary
    Then there are not security issues
