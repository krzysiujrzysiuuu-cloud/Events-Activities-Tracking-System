Feature: Sign-up

Scenario: Successful Sign up
	Given I am on the home page
	Then I should see the Sign up form
	When I fill in the following inside "Sign up form":
      | First name       | Bob            |
      | Last name        | The builder    |
      | E-mail           | bob@yahoo.com  |
	  | Username         | bob_the_builder|
      | Password         | bobpassword    |
	  | Confirm Password | bobpassword    |
	And I press "Sign up"
	Then I should be on the home page
	And I should see "Sign up successful!"
	
Scenario: Signing up with existing credentials