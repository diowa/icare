@facebook
Feature: Authentication
  In order to use Icare
  Users should be able to log in with Facebook

  Scenario: A guest should not be able to see protected pages
    When a guest tries to access a protected page
    Then he should see an "error" message "Please login first."

  Scenario: A guest that signs in from Facebook should create a new user
    When a guest gives access permission to this application on Facebook
    Then he should be logged in
    And a new user should be added to database

  Scenario: A logged in user should be able to log out
    When a guest gives access permission to this application on Facebook
    Then he should be able to log out
    And he should see the log in button
