require 'uri'
require 'cgi'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "selectors"))

module WithinHelpers
  def with_scope(locator)
    locator ? within(*selector_for(locator)) { yield } : yield
  end
end
World(WithinHelpers)

Given /I sign up as "([^"]*)" "([^"]*)" with username "([^"]*)" and password "([^"]*)" using "([^"]*)"/ do |first_name, last_name, username, password, email|
	steps %Q{
		Given I am on the home page
		Then I should see the Sign up form
		When I fill in the following inside "Sign up form":
		  | First name       | #{first_name}     |
		  | Last name        | #{last_name}      |
		  | E-mail           | #{email}          |
		  | Username         | #{username}       |
		  | Password         | #{password}       |
		  | Confirm Password | #{password}       |
		And I press "Sign up"
		Then I should be on the home page
		And I should see "Sign up successful!"
	}
end

Given /I login as "([^"]*)" with password "([^"]*)"/ do |username, password|
	steps %Q{
		Given I sign up as "fn" "ln" with username "#{username}" and password "#{password}" using "dummy@yahoo.com"
		And I am on the home page
		Then I should see "Username" and "Password" inside the "Log-in form"
		When I fill in "Username" and "Password" with "#{username}" and "#{password}" inside the "Log-in form"
		And I press "Log in"
		Then I should be on the main page
		And I should see "You have logged in"
	}
end