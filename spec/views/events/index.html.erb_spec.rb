require 'rails_helper'

RSpec.describe "events/index", type: :view do
  before(:each) do
    @ws = FactoryGirl.create(:event)
    assign(:events, [@ws, @ws])
  end

  it "renders a list of events" do
    render
    assert_select "td", :text => @ws.name, :count => 2
    assert_select "td", :text => @ws.description, :count => 2
  end

  it "should show the name of the event" do
    render
    assert_select "td", :text => "Workshop-Name"
  end

  it "should show the eventkind" do
    #Workshop or Camp
    render
    assert_select "td", :text => "Workshop"
  end

  it "should show the timespan of the event" do
    render
    assert_select "td", :text => "01.01.2001 - 02.02.2002"
    #To Check: ist das das richtige Daten-Format
  end

  it "should show the status of the event" do
    #saved or published
    render
    assert_select "td", :text => "saved"
  end
end
