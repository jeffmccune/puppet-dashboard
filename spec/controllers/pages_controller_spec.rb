require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PagesController do
  describe "#home" do
    before :each do
      SETTINGS.stubs(:no_longer_reporting_cutoff).returns(3600)

      @currently_failing_node          = Node.generate!(:name => "currently_failing")
      @unreported_node                 = Node.generate!(:name => "unreported")
      @no_longer_reporting_node        = Node.generate!(:name => "no_longer_reporting")
      @hidden_node                     = Node.generate!(:name => "hidden", :hidden => true)
      @unreported_hidden_node          = Node.generate!(:name => "unreported_hidden", :hidden => true)
      @no_longer_reporting_hidden_node = Node.generate!(:name => "no_longer_reporting_hidden", :hidden => true)
      Report.generate_for(@currently_failing_node, 5.minutes.ago, "failed")
      Report.generate_for(@no_longer_reporting_node, 2.hours.ago, "unchanged")
      Report.generate_for(@hidden_node, 5.minutes.ago, "failed")
      Report.generate_for(@no_longer_reporting_hidden_node, 2.hours.ago, "failed")
    end

    it "should properly categorize nodes" do
      get :home

      assigns[:currently_failing_nodes].map(&:name).should =~ ["currently_failing"]
      assigns[:unreported_nodes].map(&:name).should =~ ["unreported"]
      assigns[:no_longer_reporting_nodes].map(&:name).should =~ ["no_longer_reporting"]
      assigns[:recently_reported_nodes].map(&:name).should =~ ["currently_failing", "no_longer_reporting"]
      assigns[:unhidden_nodes].map(&:name).should =~ ["currently_failing", "unreported", "no_longer_reporting"]
    end
  end
end
