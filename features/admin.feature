Feature: Admin
  In order to manage users
  Admin should have some extra privileges

  Scenario: An admin should be see reports
    When an admin logs in
    Then he should see reports

  Scenario: An admin should be allowed to view user index
    When an admin logs in
    Then he should be allowed to view user index

  Scenario: An admin should be allowed to ban other users
    When an admin logs in
    Then he should be able to ban other users

  Scenario: An admin should not be allowed to ban himself
    When an admin logs in
    Then he should not be able to ban himself

  Scenario: An admin should be allowed to unban banned users
    When an admin logs in
    Then he should be able to unban a banned user

  Scenario: A normal user should not see reports
    When a user logs in
    Then he should not see reports

  Scenario: A normal user should not be allowed to view user index
    When a user logs in
    Then he should not be allowed to view user index
