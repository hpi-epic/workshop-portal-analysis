require "rails_helper"

RSpec.describe "Application Deadline", type: :feature do
	it "should save application deadline" do
		visit new_event_path
		
		deadline = Date.today.next_day(1)
		fill_in "event_name", :with => "Event Name"
		select_date_within_selector(deadline, '.event_application_deadline')

		click_button "Event erstellen"

		event = Event.find_by_name('Event Name')
		expect(event.application_deadline).to eq(deadline)
	end
end
