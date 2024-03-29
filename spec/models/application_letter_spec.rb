# == Schema Information
#
# Table name: application_letters
#
#  id          :integer          not null, primary key
#  motivation  :string
#  user_id     :integer          not null
#  event_id    :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'rails_helper'

describe ApplicationLetter do

  it "is created by application_letter factory" do
    application = FactoryGirl.build(:application_letter)
    expect(application).to be_valid
  end
  it "can't be created without mandatory fields" do
  	[:grade, :experience, :motivation, :coding_skills, :emergency_number, :vegeterian, :vegan, :allergic].each do |attr|
 	    application = FactoryGirl.build(:application_letter, attr => nil)
 	    expect(application).to_not be_valid
 	  end
  end
	it "can't be created with non integer grade" do
 	    application = FactoryGirl.build(:application_letter, :grade => "erste")
 	    expect(application).to_not be_valid
 	end
  it "has application_notes" do
    application = FactoryGirl.build(:application_letter)
    expect(application).to respond_to(:application_notes)
  end
end
