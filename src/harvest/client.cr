module Harvest
  # A Harvest client.
  class Client
    BASE_URI = URI.parse("https://api.harvestapp.com/v2/")

    def initialize(account_id : String, token : String)
      @headers = HTTP::Headers{
        "Authorization" => "Bearer #{token}",
        "Harvest-Account-Id" => account_id,
        "User-Agent" => "Harvest.cr (xen@xen.dk)",
      }
    end

    # Get time entries.
    #
    # Get the entries *from* *to*.
    def time_entries(*, from : Time? = nil, to : Time? = nil)
      params = URI::Params.new
      params["from"] = from.to_s("%Y-%m-%d") if from
      params["to"] = to.to_s("%Y-%m-%d") if to

      uri = BASE_URI.resolve("time_entries")

      uri.query_params = params unless params.empty?

      res = HTTP::Client.get(
        uri,
        headers: @headers
      )

      raise Error.new(res.body.to_s) unless res.success?

      (TimeEntriesResponse.from_json res.body).time_entries
    end
  end

  class TimeEntriesResponse
    include JSON::Serializable

    property time_entries : Array(TimeEntry)
  end
end
