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

FactoryGirl.define do
  factory :application_letter do
    grade 10
    experience "None"
    motivation "None"
    coding_skills "None"
    emergency_number "01234567891"
    vegeterian false
    vegan false
    allergic true
    allergies "Many"
    association :user, factory: :user_with_profile
	event
	status nil
  end

  factory :application_letter_accepted, class: :application_letter do
		grade 10
    experience "None"
    motivation "None"
    coding_skills "None"
    emergency_number "01234567891"
    vegeterian false
    vegan false
    allergic true
    allergies "Many"
    user
    event
    status true
  end

  factory :accepted_application_letter, parent: :application_letter do
    status true
  end

  factory :application_letter_rejected, parent: :application_letter do
    status false
  end

  factory :application_letter_accepted, class: :application_letter do
    motivation "MyString"
    user
    event
    status true
  end
end
