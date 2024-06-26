require "../spec_helper"

expected_headers = {
  "Authorization" => "Bearer token",
  "Harvest-Account-Id" => "123",
  "User-Agent" => "Harvest.cr (xen@xen.dk)",
}


describe Harvest::Service do
  context "#get" do
    it "supports pagination" do
      WebMock.stub(:get, "https://api.harvestapp.com/v2/time_entries?from=2024-05-17")
        .with(headers: expected_headers)
        .to_return(body: %({"time_entries":[{"id":123456,"spent_date":"2024-05-18","hours":1.1,"rounded_hours":1.25,"notes":"Doing something","is_closed":false,"is_billed":false,"timer_started_at":null,"created_at":"2024-05-18T16:51:35Z","updated_at":"2024-05-18T16:51:44Z","user":{"id":456,"name":"The Tester"},"client":{"id":789,"name":"The Client","currency":"DKK"},"project":{"id":147,"name":"The Project","code":"PROJ"},"task":{"id":258,"name":"The task"}}],"links": {"next": "https://api.harvestapp.com/v2/time_entries?cursor=banana"}}))
      WebMock.stub(:get, "https://api.harvestapp.com/v2/time_entries?cursor=banana")
        .with(headers: expected_headers)
        .to_return(body: %({"time_entries":[{"id":654321,"spent_date":"2024-05-18","hours":1.1,"rounded_hours":1.25,"notes":"Doing something","is_closed":false,"is_billed":false,"timer_started_at":null,"created_at":"2024-05-18T16:51:35Z","updated_at":"2024-05-18T16:51:44Z","user":{"id":456,"name":"The Tester"},"client":{"id":789,"name":"The Client","currency":"DKK"},"project":{"id":147,"name":"The Project","code":"PROJ"},"task":{"id":258,"name":"The task"}}],"links": {"next": null}}))

      # Need to ensure that the URI is unique as WebMock stubs are global.
      params = URI::Params.new
      params["from"] = "2024-05-17"

      entries = [] of Harvest::TimeEntry
      Harvest.new("123", "token").get("time_entries", Harvest::TimeEntriesResponse, params) do |response|
        entries.concat response.time_entries
      end

      entries.size.should eq 2
      entries[0].id.should eq 123456
      entries[1].id.should eq 654321
    end
  end

  context "#time_entries" do
    it "fetches time entries" do
      WebMock.stub(:get, "https://api.harvestapp.com/v2/time_entries")
        .with(headers: expected_headers)
        .to_return(body: %({"time_entries":[{"id":123456,"spent_date":"2024-05-18","hours":1.1,"rounded_hours":1.25,"notes":"Doing something","is_closed":false,"is_billed":false,"timer_started_at":null,"created_at":"2024-05-18T16:51:35Z","updated_at":"2024-05-18T16:51:44Z","user":{"id":456,"name":"The Tester"},"client":{"id":789,"name":"The Client","currency":"DKK"},"project":{"id":147,"name":"The Project","code":"PROJ"},"task":{"id":258,"name":"The task"}}],"links": {"next": null}}))

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
        .to_return(body: %({"time_entries":[],"links": {"next": null}}))

      Harvest.new("123", "token").time_entries(
        from: Time.utc(2024, 5, 18),
        to: Time.utc(2024, 5, 19),
      )
    end

    it "supports fetching by user" do
      WebMock.stub(:get, "https://api.harvestapp.com/v2/time_entries?user_id=123")
        .with(headers: expected_headers)
        .to_return(body: %({"time_entries":[],"links": {"next": null}}))
      WebMock.stub(:get, "https://api.harvestapp.com/v2/time_entries?user_id=951")
        .with(headers: expected_headers)
        .to_return(body: %({"time_entries":[],"links": {"next": null}}))
      WebMock.stub(:get, "https://api.harvestapp.com/v2/time_entries?user_id=456")
        .with(headers: expected_headers)
        .to_return(body: %({"time_entries":[],"links": {"next": null}}))

      user = Harvest::User.from_json(%({"id":951,"first_name":"John","last_name":"Doe","email":"jd@example.dk","is_contractor":false,"is_active":true,"created_at":"2024-04-17T12:23:10Z","updated_at":"2024-05-06T14:03:38Z","access_roles":["member"]}))
      user_ref = Harvest::UserRef.from_json(%({"id":456,"name":"The Tester"}))

      Harvest.new("123", "token").time_entries(user: "123")
      Harvest.new("123", "token").time_entries(user: user)
      Harvest.new("123", "token").time_entries(user: user_ref)
    end

    it "supports updated_since argument" do
      WebMock.stub(:get, "https://api.harvestapp.com/v2/time_entries?updated_since=2024-05-24T08%3A39%3A36Z")
        .with(headers: expected_headers)
        .to_return(body: %({"time_entries":[],"links": {"next": null}}))

      Harvest.new("123", "token").time_entries(
        updated_since: Time.utc(2024, 5, 24, 8, 39, 36),
      )
    end
  end

  context "#users" do
    it "fetches users" do
      WebMock.stub(:get, "https://api.harvestapp.com/v2/users")
        .with(headers: expected_headers)
        .to_return(body: %({"users":[{"id":951,"first_name":"John","last_name":"Doe","email":"jd@example.dk","is_contractor":false,"is_active":true,"created_at":"2024-04-17T12:23:10Z","updated_at":"2024-05-06T14:03:38Z","access_roles":["member"]}],"links": {"next": null}}))

      result = Harvest.new("123", "token").users

      result.size.should eq 1
      result[0].id.should eq 951
      result[0].first_name.should eq "John"
      result[0].last_name.should eq "Doe"
      result[0].email.should eq "jd@example.dk"
      result[0].is_contractor.should eq false
      result[0].is_active.should eq true
      result[0].created_at.should eq Time.utc(2024, 4, 17, 12, 23, 10)
      result[0].updated_at.should eq Time.utc(2024, 5, 6, 14, 3, 38)
    end

    it "supports is_active argument" do
      WebMock.stub(:get, "https://api.harvestapp.com/v2/users?is_active=true")
        .with(headers: expected_headers)
        .to_return(body: %({"users":[],"links": {"next": null}}))

      Harvest.new("123", "token").users(is_active: true)
    end

    it "supports updated_since argument" do
      WebMock.stub(:get, "https://api.harvestapp.com/v2/users?updated_since=2024-05-24T08%3A39%3A36Z")
        .with(headers: expected_headers)
        .to_return(body: %({"users":[],"links": {"next": null}}))

      Harvest.new("123", "token").users(updated_since: Time.utc(2024, 5, 24, 8, 39, 36))
    end
  end

  context "#tasks" do
    it "fetches tasks" do
      WebMock.stub(:get, "https://api.harvestapp.com/v2/tasks")
        .with(headers: expected_headers)
        .to_return(body: %({"tasks":[{"id":753,"name":"Some important task","billable_by_default":true,"created_at":"2024-05-22T09:16:26Z","updated_at":"2024-05-22T09:17:26Z"}],"links": {"next": null}}))

      result = Harvest.new("123", "token").tasks

      result.size.should eq 1
      result[0].id.should eq 753
      result[0].name.should eq "Some important task"
      result[0].billable_by_default.should eq true
      result[0].created_at.should eq Time.utc(2024, 5, 22, 9, 16, 26)
      result[0].updated_at.should eq Time.utc(2024, 5, 22, 9, 17, 26)
    end

    it "supports updated_since argument" do
      WebMock.stub(:get, "https://api.harvestapp.com/v2/tasks?updated_since=2024-05-24T08%3A39%3A36Z")
        .with(headers: expected_headers)
        .to_return(body: %({"tasks":[],"links": {"next": null}}))

      Harvest.new("123", "token").tasks(updated_since: Time.utc(2024, 5, 24, 8, 39, 36))
    end
  end

  context "#projects" do
    it "fetches projects" do
      WebMock.stub(:get, "https://api.harvestapp.com/v2/projects")
        .with(headers: expected_headers)
        .to_return(body: %({"projects":[{"id":153,"name":"Some project","is_active":true,"is_billable":false,"created_at":"2024-04-23T08:26:56Z","updated_at":"2024-04-24T08:26:56Z"}],"links": {"next": null}}))

      result = Harvest.new("123", "token").projects

      result.size.should eq 1
      result[0].id.should eq 153
      result[0].name.should eq "Some project"
      result[0].is_active.should eq true
      result[0].is_billable.should eq false
      result[0].created_at.should eq Time.utc(2024, 4, 23, 8, 26, 56)
      result[0].updated_at.should eq Time.utc(2024, 4, 24, 8, 26, 56)
    end

    it "supports updated_since argument" do
      WebMock.stub(:get, "https://api.harvestapp.com/v2/projects?updated_since=2024-05-24T08%3A39%3A36Z")
        .with(headers: expected_headers)
        .to_return(body: %({"projects":[],"links": {"next": null}}))

      Harvest.new("123", "token").projects(updated_since: Time.utc(2024, 5, 24, 8, 39, 36))
    end
  end
end
