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

    # Perform a GET request on the given *path*.
    #
    # Handles pagination and yields the *klass* to the block for each
    # page.
    protected def get(path : String, klass : HarvestResponse.class, params : URI::Params? = nil)
      page = 1
      loop do
        res = HTTP::Client.get(
          uri(path, params),
          headers: @headers
        )

        raise Error.new(res.body.to_s) unless res.success?

        response = klass.from_json(res.body)
        yield response

        if response.total_pages <= page
          break
        end

        page += 1
        params["page"] = page.to_s
      end
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
      time_entries = [] of TimeEntry
      res = get("time_entries", TimeEntriesResponse, params) do |response|
        time_entries.concat response.time_entries
      end

      time_entries
    end

    # Get users.
    #
    # Users can be limited to active users.
    def users(*, is_active : Bool = false)
      params = URI::Params.new
      params["is_active"] = "true" if is_active

      users = [] of User
      res = get("users", UsersResponse, params) do |response|
        users.concat response.users
      end

      users
    end
  end

  class HarvestResponse
    include JSON::Serializable

    property total_pages : Int64
  end

  class TimeEntriesResponse < HarvestResponse
    property time_entries : Array(TimeEntry)
  end

  class UsersResponse < HarvestResponse
    property users : Array(User)
  end
end
