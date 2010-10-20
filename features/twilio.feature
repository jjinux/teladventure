Feature: Twilio
  So that I can entertain myself
  As a user
  I want to call a phone number and create an interactive story

  Scenario: say hello
    When I receive a phone call
    Then it should say hello