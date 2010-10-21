Feature: Twilio
  So that I can entertain myself
  As a user
  I want to call a phone number and create an interactive story

  Scenario: say hello
    Given there is a root node

    When I receive a phone call
    Then it should introduce me to the game

    When I follow the redirect
    Then it should introduce me to the node