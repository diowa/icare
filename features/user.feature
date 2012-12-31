Feature: User
  In order to manage their profiles
  User should have proper views

  Scenario: A verified user should see the verified box in his profile
    When a verified user logs in
    And he visit his profile
    Then he should see the verified box

  Scenario: A user should see references in tags
    When a user with references logs in
    And he visit his profile
    Then he should see his references
