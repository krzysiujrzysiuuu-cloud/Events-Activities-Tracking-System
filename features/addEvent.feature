Feature: Add Event

Background:
	Given I login as "keanu" with password "123"
Scenario:
	Given I am on the main page
	Then I should see "Create Event"
	When I press "Create Event"
	Then I should be on the create event page
	When I fill in ...
	And I press "Add Event"
	Then I should be on the main page
	And I should see ...