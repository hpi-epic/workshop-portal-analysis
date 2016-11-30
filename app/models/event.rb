# == Schema Information
#
# Table name: events
#
#  id               :integer          not null, primary key
#  name             :string
#  description      :string
#  max_participants :integer
#  date_ranges      :Collection
#  active           :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Event < ActiveRecord::Base
  UNREASONABLY_LONG_DATE_SPAN = 300

  has_many :application_letters
  has_many :agreement_letters

  validates :max_participants, numericality: { only_integer: true, greater_than: 0 }

  enum kind: [ :workshop, :camp ]
  
  # Returns all users that applied to this event and were accepted.
  def participants
	@accepted_applications = self.application_letters.select { |application_letter| application_letter.status == true }
	@participants = []
	for application in @accepted_applications do
		@participants.push(application.user)
	end
	@participants
  end
  
  # Returns all participants for this event in following order:
  # 1. All participants that have to submit an letter of agreement but did not yet do so, ordered by name.
  # 2. All participants that have to submit an letter of agreement and did do so, ordered by name.
  # 3. All participants that do not have to submit an letter of agreement, ordered by name.
  def participants_by_agreement_letter
    @participants = self.participants
	@participants.sort { |x, y| self.compare_participants_by_agreement(x,y) }
  end
  
  has_many :date_ranges

  # Returns the agreement letter a user submitted for this event
  #
  # @param user [User] the user whose agreement letter we want
  # @return [AgreementLetter, nil] the user's agreement letter or nil
  def agreement_letter_for(user)
    self.agreement_letters.where(user: user).take
  end

  validates :max_participants, numericality: { only_integer: true, greater_than: 0 }
  validate :has_date_ranges


  # @return the minimum start_date over all date ranges
  def start_date
    (date_ranges.min { |a,b| a.start_date <=> b.start_date }).start_date
  end

  # @return the minimum end_date over all date ranges
  def end_date
    (date_ranges.max { |a,b| a.end_date <=> b.end_date }).end_date
  end

  # @return whether this event appears unreasonably long as defined by
  #         the corresponding constant
  def unreasonably_long
    end_date - start_date > UNREASONABLY_LONG_DATE_SPAN
  end

  # validation function on whether we have at least one date range
  def has_date_ranges
    errors.add(:base, 'Bitte mindestens eine Zeitspanne auswählen!') if date_ranges.blank?
  end

  def self.human_attribute_name(*args)
    if args[0].to_s == "max_participants"
      return "Maximale Teilnehmerzahl"
    elsif args[0].to_s == "date_ranges"
      return "Zeitspannen"
    end

    super
  end
  
  protected
  def compare_participants_by_agreement(participant1, participant2)
    if participant1.older_than_18_at_start_date_of_event?(self)
	  if participant2.older_than_18_at_start_date_of_event?(self)
	    return participant1.name <=> participant2.name
      end
	  return 1
	end
	if participant2.older_than_18_at_start_date_of_event?(self)
	  return -1
	end
	if participant1.agreement_letter_for_event?(self)
	  if participant2.agreement_letter_for_event?(self)
	    return participant1.name <=> participant2.name
	  end
	  return 1
	end
	if participant2.agreement_letter_for_event?(self)
	  return -1
	end
	return participant1.name <=> participant2.name
  end
  

  def applicationsClassified?
    application_letters.all? { |application_letter| !application_letter.status.nil? }
  end

  def compute_rejected_applications_emails
    rejected_applications = application_letters.select { |application_letter| !application_letter.status }
    rejected_applications.map{ |applications_letter| applications_letter.user.email }.join(',')
  end

  def compute_accepted_applications_emails
    accepted_applications = application_letters.select { |application_letter| application_letter.status }
    accepted_applications.map{ |application_letter| application_letter.user.email }.join(',')
  end

  # Returns the number of free places of the event, this value may be negative
  #
  # @param none
  # @return [Int] for number of free places available
  def compute_free_places
    max_participants - compute_occupied_places
  end

  # Returns the number of already occupied places of the event
  #
  # @param none
  # @return [Int] for number of occupied places
  def compute_occupied_places
    application_letters.where(status: ApplicationLetter.statuses[:accepted]).count
  end

  scope :draft_is, ->(draft) { where("draft = ?", draft) }

  # Returns an semicolon-separated-list of email addresses of all accepted participants.
  #
  # @param none
  # @return [String] for list of email-addresses
  def get_email_list
    application_letters.where(status: true).reduce('') {|list, letter| list << letter.user.email << ';'}
  end
end
