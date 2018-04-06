Feature: Log-in

Background:
	Given I sign up as "Keanu" "Go" with username "keanu" and password "123" using "keanu_go@yahoo.com"
Scenario:
	And I am on the home page
	Then I should see "Username" and "Password" inside the "Log-in form"
	When I fill in "Username" and "Password" with "keanu" and "123" inside the "Log-in form"
	And I press "Log in"
	Then I should be on the main page
	And I should see "You have logged in"