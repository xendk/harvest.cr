require "./spec_helper"

describe Harvest do
  it "#new should return a client" do
    Harvest.new("456", "token").should be_a(Harvest::Client)
  end
end
