Feature: User
  In order to manage their profiles
  User should have proper views

  Scenario: A verified user should see the verified box in his profile
    When a verified user logs in
    And he visit his profile
    Then he should see the verified box

  Scenario: A user should see his number of friends
    When a user logs in
    And he visit his profile
    Then he should see his friends with privacy

  Scenario: A user should see references in tags
    When a user with references logs in
    And he visit his profile
    Then he should see his references

  Scenario: A user should see common languages highlighted
    When a user logs in
    And he visit another user with common languages
    Then he should see common languages highlighted

  Scenario: A user should see common work highlighted
    When a user logs in
    And he visit another user with a common work
    Then he should see common work highlighted

  Scenario: A user should see common education highlighted
    When a user logs in
    And he visit another user with a common education
    Then he should see common education highlighted

  Scenario: A user should see mutual friends
    When a user logs in
    And he visit another user with mutual friends
    Then he should see mutual friends

  Scenario: A user should see common likes highlighted
    When a user logs in
    And he visit another user with common likes
    Then he should see common likes highlighted
