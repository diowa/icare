@facebook
Feature: Facebook Authentication
  In order to use Icare
  Users should be able to log in with facebook

  @javascript
  Scenario: A guest should see facebook's login page when he tries to access through facebook
    When a guest tries to access Icare through facebook
    Then he should be redirected on facebook's website

  Scenario: A guest that signs in from facebook should create a new user
    When a guest gives access permission to this application on facebook
    Then he should be logged in
    And a new user should be added to database
