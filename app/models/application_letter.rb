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
#  status      :integer          not null
#
class ApplicationLetter < ActiveRecord::Base
  belongs_to :user
  belongs_to :event

  has_many :application_notes

  validates :user, :event, :experience, :motivation, :coding_skills, :emergency_number, presence: true
  validates :grade, presence: true, numericality: { only_integer: true }
  validates :vegeterian, :vegan, :allergic, inclusion: { in: [true, false] }
  validates :vegeterian, :vegan, :allergic, exclusion: { in: [nil] }

  enum status: {accepted: 1, rejected: 0, pending: 2}

  # Checks if the deadline is over
  #
  # @param none
  # @return [Boolean] true if deadline is over
  def after_deadline?

    # hardcode deadline until
    # event model is ready in #18 - US_1.4: Application deadline
    deadline = DateTime.new(2016,9,1,17)

    now = Time.now.utc.to_datetime
    now > deadline
  end

end
