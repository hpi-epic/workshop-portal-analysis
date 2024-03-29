class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy, :email_list]

  # GET /events
  def index
    @events = Event.draft_is false
  end

  # GET /events/1
  def show
    @free_places = @event.compute_free_places
    @occupied_places = @event.compute_occupied_places
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  def create
    @event = Event.new(event_params)

    @event.date_ranges = date_range_params

    @event.draft = (params[:draft] != nil)

    if @event.save
      redirect_to @event, notice: 'Event wurde erstellt.'
    else
      render :new
    end
  end

  # PATCH/PUT /events/1
  def update
    attrs = event_params

    if params[:date_ranges]
      attrs[:date_ranges] = date_range_params
    end

    @event.draft = (params[:commit] == "draft")
    if @event.update(attrs)
      redirect_to @event, notice: 'Event wurde aktualisiert.'

    else
      render :edit
    end
  end

  # DELETE /events/1
  def destroy
    @event.destroy
    redirect_to events_url, notice: 'Event wurde gel�scht.'
  end

  # GET /events/1/badges
  def badges
    @event = Event.find(params[:event_id])
    @participants = @event.participants

    # TODO: undo mock
    @participants.push(create_mock_participants)
    @participants.push(create_mock_participants)
  end

  # POST /events/1/badges
  def print_badges
    @event = Event.find(params[:event_id])
    @participants = @event.participants

    # TODO: undo mock and get checked participants from view
    @participants.push(create_mock_participants)
    @participants.push(create_mock_participants)
    @participants.push(create_mock_participants)
    @participants.push(create_mock_participants)

    # pdf document initialization
    pdf = Prawn::Document.new(:page_size => 'A4')
    pdf.stroke_color "000000"

    # creates badge edges as rectangles left-upper-bound[x,y], width, height
    # TODO: create dynamically from checked participants
    @participants.each_with_index do |participant, index|
      if index % 2 == 0 # left column badges
        create_badge(pdf, 0, 750 - index / 2 * 150)
        index = index - 1
      else
        create_badge(pdf, 260, 750 - index / 2 * 150)
      end

    end

    #create_badge(pdf, 0, 750)
    #create_badge(pdf, 0, 600)
    #create_badge(pdf, 0, 450)
    #create_badge(pdf, 0, 300)
    #create_badge(pdf, 0, 150)

    #create_badge(pdf, 260, 750)
    #create_badge(pdf, 260, 600)
    #create_badge(pdf, 260, 450)
    #create_badge(pdf, 260, 300)
    #create_badge(pdf, 260, 150)

    send_data pdf.render, :filename => "x.pdf", :type => "application/pdf", disposition: "inline"
  end

  # GET /events/1/participants
  def participants
	@event = Event.find(params[:id])
	@participants = @event.participants_by_agreement_letter
  end

  # GET /events/1/email_list
  def email_list
    render :text => @event.get_email_list, :content_type => 'text/csv'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # We receive start_date/end_date pairs in a weird format because forms
    # are limited in the way they can arrange data for us. So we translate
    # pairs of { start_date: [{day, month, year}, {day, month, year}], end_date: [...] }
    # to the expected format [{start_date, end_date}, ...]
    #
    # @return array of start_date, end_date pairs
    def date_range_params
      dateRanges = params[:date_ranges] || {start_date: [], end_date: []}

      dateRanges[:start_date].zip(dateRanges[:end_date]).map do |s, e|
        DateRange.new(start_date: Date.new(s[:year].to_i, s[:month].to_i, s[:day].to_i),
                      end_date: Date.new(e[:year].to_i, e[:month].to_i, e[:day].to_i))
      end
    end

    # Only allow a trusted parameter "white list" through.
    def event_params
      params.require(:event).permit(:name, :description, :max_participants, :active, :organizer, :knowledge_level, :kind)
    end

    def create_badge(pdf, x, y)
      width = 260
      height = 150
      pdf.stroke_rectangle [x, y], width, height
      # TODO: the position is very hacky, make it better
      pdf.draw_text "Max Mustermann", :at => [x + width / 2 - 50 , y - 20]
    end

    def create_mock_participants
      participant = User.new(name: "Max Mustermann")
    end
end
