# == Schema Information
#
# Table name: events
#
#  id               :integer          not null, primary key
#  name             :string
#  description      :string
#  max_participants :integer
#  active           :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'rails_helper'

describe Event do

  let(:event) { FactoryGirl.create :event, :with_two_date_ranges }

  it "is created by event factory" do
    expect(event).to be_valid
  end

  it "is either a camp or a workshop" do
    expect { FactoryGirl.build(:event, kind: :smth_invalid) }.to raise_error(ArgumentError)

    event = FactoryGirl.build(:event, kind: :camp)
    expect(event).to be_valid

    event = FactoryGirl.build(:event, kind: :workshop)
    expect(event).to be_valid
  end

  
  it "has as many participants as accepted applications" do
    event = FactoryGirl.create(:event_with_accepted_applications, accepted_application_letters_count: 10, rejected_application_letters_count: 7)
    expect(event.participants.length).to eq 10
  end

  it "sorts participants in the expected order" do
    @event = FactoryGirl.create(:event)
    @user1 = FactoryGirl.create(:user, name: 'ghk')
    @profile1 = FactoryGirl.create(:profile, user: @user1, birth_date: 15.years.ago)
    @application1 = FactoryGirl.create(:accepted_application_letter, user: @user1, event: @event)
    @agreement1 = FactoryGirl.create(:agreement_letter, user: @user1, event: @event)
    
    @user2 = FactoryGirl.create(:user, name: 'bba')
    @profile2 = FactoryGirl.create(:profile, user: @user2, birth_date: 16.years.ago)
    @application2 = FactoryGirl.create(:accepted_application_letter, user: @user2, event: @event)
    
    @user3 = FactoryGirl.create(:user, name: 'eee')
    @profile3 = FactoryGirl.create(:profile, user: @user3, birth_date: 19.years.ago)
    @application3 = FactoryGirl.create(:accepted_application_letter, user: @user3, event: @event)
    @agreement3 = FactoryGirl.create(:agreement_letter, user: @user3, event: @event)
    
    @user4 = FactoryGirl.create(:user, name: 'ddd')
    @profile4 = FactoryGirl.create(:profile, user: @user4, birth_date: 16.years.ago)
    @application4 = FactoryGirl.create(:accepted_application_letter, user: @user4, event: @event)
    
    @user5 = FactoryGirl.create(:user, name: 'bbb')
    @profile5 = FactoryGirl.create(:profile, user: @user5, birth_date: 20.years.ago)
    @application5 = FactoryGirl.create(:accepted_application_letter, user: @user5, event: @event)
    
    @user6 = FactoryGirl.create(:user, name: 'abc')
    @profile6 = FactoryGirl.create(:profile, user: @user6, birth_date: 16.years.ago)
    @application6 = FactoryGirl.create(:accepted_application_letter, user: @user6, event: @event)
    @agreement6 = FactoryGirl.create(:agreement_letter, user: @user6, event: @event)
    #2,4,6,1,5,3
	expect(@event.participants_by_agreement_letter).to eq([@user2, @user4, @user6, @user1, @user5, @user3])
  end
  
  it "should have one or more date-ranges" do

    #checking if the event model can handle date_ranges
    expect(event.date_ranges.size).to eq 2
    expect(event.date_ranges.first.start_date).to eq(Date.tomorrow)
    expect(event.date_ranges.first.end_date).to eq(Date.tomorrow.next_day(5))
    expect(event.date_ranges.second.start_date).to eq(Date.tomorrow)
    expect(event.date_ranges.second.end_date).to eq(Date.tomorrow.next_day(10))
    expect(event.date_ranges.second).to eq(event.date_ranges.last)

    #making sure that every event has at least one date range
    event1 = FactoryGirl.build(:event, :without_date_ranges)
    expect(event1).to_not be_valid
  end

  describe "#start_date" do
    it "should return return its minimum over all date ranges" do
      event = FactoryGirl.create :event, :with_multiple_date_ranges
      expect(event.start_date).to eq(Date.today)
    end
  end

  describe "#end_date" do
    it "should return return its maximum over all date ranges" do
      event = FactoryGirl.create :event, :with_multiple_date_ranges
      expect(event.end_date).to eq(Date.today.next_day(16))
    end
  end

  describe "#unreasonably_long" do
    it "should be true if the event is longer than defined" do
      event = FactoryGirl.create :event, :with_unreasonably_long_range
      expect(event.unreasonably_long).to be true
    end
  end
end
