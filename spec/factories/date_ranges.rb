# == Schema Information
#
# Table name: dateRange
#
# id							:integer
# startDate				:date
# endDate 				:date
# event_id 				:integer
#


FactoryGirl.define do
	factory :dateRange  do
		start_date Date.new(2016, 1, 1)
    end_date Date.new(2016, 2, 2)

    trait :with_negative_range do
      start_date Date.tomorrow
      end_date Date.today
    end

    trait :with_past_dates do
      start_date Date.today.prev_day(3)
      end_date Date.yesterday
    end
	end 
end



