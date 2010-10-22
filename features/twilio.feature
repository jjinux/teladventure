Feature: Twilio
  So that I can entertain myself
  As a user
  I want to call a phone number and create an interactive story

  Scenario: start the adventure
    Given there are a few nodes

    When I receive a phone call
    Then I should get a valid TwiML response
    And it should say "Hello"

    When I follow the redirect
    Then I should get a valid TwiML response
    And it should tell me the current outcome
    And it should ask me for the next choice
    And it should redirect me to the current node if I haven't made a choice

    When I follow the redirect
    Then I should get a valid TwiML response
    And it should say "I'm sorry.  I didn't get a response.  Let's try again."

    When I follow the redirect
    Then I should get a valid TwiML response
    And it should tell me the current outcome