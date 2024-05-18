require "../spec_helper"

expected_headers = {
  "Authorization" => "Bearer token",
  "Harvest-Account-Id" => "123",
  "User-Agent" => "Harvest.cr (xen@xen.dk)",
}

describe Harvest::Client do
  it "fetches time entries" do
    WebMock.stub(:get, "https://api.harvestapp.com/v2/time_entries")
      .with(headers: expected_headers)
      .to_return(body: "{\"time_entries\":[{\"id\":123456,\"spent_date\":\"2024-05-18\",\"hours\":1.1,\"rounded_hours\":1.25,\"notes\":\"Doing something\",\"is_closed\":false,\"is_billed\":false,\"timer_started_at\":null,\"created_at\":\"2024-05-18T16:51:35Z\",\"updated_at\":\"2024-05-18T16:51:44Z\",\"user\":{\"id\":456,\"name\":\"The Tester\"},\"client\":{\"id\":789,\"name\":\"The Client\",\"currency\":\"DKK\"},\"project\":{\"id\":147,\"name\":\"The Project\",\"code\":\"PROJ\"},\"task\":{\"id\":258,\"name\":\"The task\"}}]}")

    result = Harvest.new("123", "token").time_entries

    result.size.should eq 1
    result[0].id.should eq 123456
    result[0].spent_date.should eq Time.utc(2024, 5, 18, 0, 0, 0)
    result[0].hours.should eq 1.1
    result[0].rounded_hours.should eq 1.25
    result[0].notes.should eq "Doing something"
    result[0].is_closed.should eq false
    result[0].is_billed.should eq false
    result[0].timer_started_at.should be_nil
    result[0].created_at.should eq Time.utc(2024, 5, 18, 16, 51, 35)
    result[0].updated_at.should eq Time.utc(2024, 5, 18, 16, 51, 44)
    result[0].user.id.should eq 456
    result[0].user.name.should eq "The Tester"
    result[0].client.id.should eq 789
    result[0].client.name.should eq "The Client"
    result[0].client.currency.should eq "DKK"
    result[0].project.id.should eq 147
    result[0].project.name.should eq "The Project"
    result[0].project.code.should eq "PROJ"
    result[0].task.id.should eq 258
    result[0].task.name.should eq "The task"
  end

  it "supports from and to arguments" do
    WebMock.stub(:get, "https://api.harvestapp.com/v2/time_entries?from=2024-05-18&to=2024-05-19")
      .with(headers: expected_headers)
      .to_return(body: "{\"time_entries\":[]}")

    Harvest.new("123", "token").time_entries(
      from: Time.utc(2024, 5, 18),
      to: Time.utc(2024, 5, 19),
    )
  end
end