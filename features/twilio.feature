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

  Scenario: listen to the root node
    Given there are a few nodes
    And I am on the root node
    Then I should get a valid TwiML response
    And it should tell me the current outcome
    And it should say "create a new choice and outcome."
    And it should say "edit the current choice and outcome."
    And it should ask me for the next choice

  Scenario: listen to the root node and timeout
    Given there are a few nodes
    And I am on the root node
    Then I should get a valid TwiML response
    And it should redirect me to the current node if I haven't made a choice

    When I follow the redirect
    Then I should get a valid TwiML response
    And it should say "I'm sorry.  I didn't get a response.  Let's try again."

    When I follow the redirect
    Then I should get a valid TwiML response

  Scenario: listen to the root node and enter an invalid entry
    Given there are a few nodes
    When I enter "7" when I am on the root node
    Then I should get a valid TwiML response
    And it should say "7 is not a valid entry."

    When I follow the redirect
    Then I should get a valid TwiML response