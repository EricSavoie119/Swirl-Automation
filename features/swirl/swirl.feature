@swirl
Feature: As an automation engineer
  I would like to create automation for swirl

  @swirl
  Scenario: Load the browser and swirl log in
    Given I sign in to swirl insurance
    And   I click on the "applicants" button
    And   I find the most recent applicant without FQS
