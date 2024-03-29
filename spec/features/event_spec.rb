require "rails_helper"

describe "Event", type: :feature do
  describe "create page" do
    it "should allow picking the event kind camp" do
      visit new_event_path
      fill_in 'Max participants', :with => 25
      choose('Camp')
      click_button "Event erstellen"
      expect(page).to have_text('Camp')
    end

    it "should allow picking the event kind workshop" do
      visit new_event_path
      fill_in 'Max participants', :with => 25
      choose('Workshop')
      click_button "Event erstellen"
      expect(page).to have_text('Workshop')
    end
    it "should not allow dates in the past" do
      visit new_event_path
      select_date_within_selector(Date.yesterday.prev_day, '.event-date-picker-start')
      select_date_within_selector(Date.yesterday, '.event-date-picker-end')
      find("input[name='commit']").click
      expect(page).to have_text("Anfangs-Datum darf nicht in der Vergangenheit liegen.")
    end

    it "should warn about unreasonably long time spans" do
      visit new_event_path
      fill_in 'Maximale Teilnehmerzahl', :with => 25
      select_date_within_selector(Date.today, '.event-date-picker-start')
      select_date_within_selector(Date.today.next_year(3), '.event-date-picker-end')
      find("input[name='commit']").click
      expect(page).to have_text("End-Datum liegt ungewöhnlich weit vom Start-Datum entfernt.")
    end

    # we currently don't have js support
    it "should allow entering multiple time spans", js: true do
      visit new_event_path

      first_from = Date.today
      first_to = Date.today.next_day(2)

      second_from = Date.today.next_day(6)
      second_to = Date.today.next_day(8)

      fill_in 'Maximale Teilnehmerzahl', :with => 25
      select_date_within_selector(first_from, '.event-date-picker-start')
      select_date_within_selector(first_to, '.event-date-picker-end')
      click_link "Zeitspanne hinzufügen"

    #  start = page.all('.event-date-picker')[1].find('.event-date-picker-start')
    #  select_date_within_selector(second_from, start)
    #  select_date_within_selector(second_to, '.event-date-picker:nth-child(2) .event-date-picker-end')
    #  click_button "Veranstaltung erstellen"

      select_date_within_selector(second_from, '.event-date-picker:nth-child(2) .event-date-picker-start')
      select_date_within_selector(second_to, '.event-date-picker:nth-child(2) .event-date-picker-end')
      click_button "Event erstellen"

      expect(page).to have_text(first_from.to_s + ' bis ' + first_to.to_s)
      expect(page).to have_text(second_from.to_s + ' bis ' + second_to.to_s)
    end

    it "should not allow an end date before a start date" do
      visit new_event_path
      select_date_within_selector(Date.today, '.event-date-picker-start')
      select_date_within_selector(Date.today.prev_day(2), '.event-date-picker-end')
      find("input[name='commit']").click
      expect(page).to have_text("End-Datum kann nicht vor Start-Datum liegen")
    end
  end

  describe "show page" do

    it "should display the event kind" do
      event = FactoryGirl.create(:event, kind: :workshop)
      visit event_path(event)
      expect(page).to have_text('Workshop')

      event = FactoryGirl.create(:event, kind: :camp)
      visit event_path(event)
      expect(page).to have_text('Camp')
    end

    it "should display all date ranges" do
      event = FactoryGirl.create(:event, :with_two_date_ranges)
      visit event_path(event.id)

      expect(page).to have_text(event.date_ranges.first.start_date.to_s +
                                ' bis ' + event.date_ranges.first.end_date.to_s)
      expect(page).to have_text(event.date_ranges.second.start_date.to_s +
                                ' bis ' + event.date_ranges.second.end_date.to_s)
    end
  end

  describe "edit page" do
    it "should preselect the event kind" do
      event = FactoryGirl.create(:event, kind: :camp)
      visit edit_event_path(event)
      expect(find_field('Camp')[:checked]).to_not be_nil
    end
    it "should display all existing date ranges" do
      event = FactoryGirl.create(:event, :with_two_date_ranges)
      visit edit_event_path(event.id)

      expect(page.all('.event-date-picker').size).to eq(2)
    end

    it "should save edits to the date ranges" do
      event = FactoryGirl.create(:event, :with_two_date_ranges)
      dateStart = Date.today.next_year
      dateEnd = Date.tomorrow.next_year

      visit edit_event_path(event.id)

      picker = page.all('.event-date-picker')[0]
      startPicker = picker.find('.event-date-picker-start')
      endPicker = picker.find('.event-date-picker-end')

      select_date_within_selector(dateStart, startPicker)
      select_date_within_selector(dateEnd, endPicker)

      find("input[name='commit']").click

      expect(page).to have_text(dateStart.to_s + ' bis ' + dateEnd.to_s)
    end
  end
  #it "should save application deadline" do
  #        visit new_event_path
  #        
  #        deadline = Date.today.next_day(1)
  #        fill_in "event_name", :with => "Event Name"
  #        select_date_within_selector(deadline, '.event_application_deadline')

  #        click_button "Event erstellen"

  #        event = Event.find_by_name('Event Name')
  #        expect(event.application_deadline).to eq(deadline)
  #end
end
RSpec.feature "Draft events", :type => :feature do
  before(:each) do
    @event = FactoryGirl.create(:event, draft: nil)

    visit new_event_path
    fill_in "event_name", :with => @event.name
    fill_in "event_description", :with => @event.description
    fill_in "event_max_participants", :with => @event.max_participants
    fill_in "event_active", :with => @event.active
  end

  scenario "User saves a draft event, but doesn't publish it" do
    draft_button.click()

    # Show success alert
    expect(page).to have_css(".alert-success")

    # The event should not be visible in the events list
    visit events_path
    expect(page).to_not have_text(@event.name)
  end

  scenario "User revisits a saved draft event and publishes it" do
    draft_button.click()

    visit edit_event_path(@event)
    publish_button.click()

    expect(page).to have_css(".alert-success")

    # The event should now be visible in the events list
    visit events_path
    expect(page).to have_text(@event.name)
  end
end

def draft_button
  find(:xpath, "//input[contains(@name, 'draft')]")
end

def publish_button
  find(:xpath, "//input[contains(@name, 'publish')]")
end
