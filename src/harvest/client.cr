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

    protected def uri(path : String, params : URI::Params? = nil)
      uri = BASE_URI.resolve(path)

      uri.query_params = params unless !params || params.empty?
      uri
    end

    protected def get(path : String, params : URI::Params? = nil)
      res = HTTP::Client.get(
        uri(path, params),
        headers: @headers
      )

      raise Error.new(res.body.to_s) unless res.success?

      res
    end

    # Get time entries.
    #
    # Entries can be limited by *from*, *to* and *user*.
    def time_entries(*, from : Time? = nil, to : Time? = nil, user : String | User | UserRef | Nil = nil)
      params = URI::Params.new
      params["from"] = from.to_s("%Y-%m-%d") if from
      params["to"] = to.to_s("%Y-%m-%d") if to
      if user
        case user
        when String
          params["user_id"] = user
        else
          params["user_id"] = user.id.to_s
        end
      end
      res = get("time_entries", params)

      (TimeEntriesResponse.from_json res.body).time_entries
    end

    # Get users.
    def users(*, is_active : Bool = false)
      params = URI::Params.new
      params["is_active"] = "true" if is_active

      res = get("users", params)

      (UsersResponse.from_json res.body).users
    end
  end

  class TimeEntriesResponse
    include JSON::Serializable

    property time_entries : Array(TimeEntry)
  end

  class UsersResponse
    include JSON::Serializable

    property users : Array(User)
  end
end
