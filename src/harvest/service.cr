module Harvest
  # A Harvest client.
  class Service
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
    def get(path : String, klass : HarvestResponse.class, params : URI::Params? = nil)
      uri = uri(path, params)
      loop do
        res = HTTP::Client.get(
          uri,
          headers: @headers
        )

        raise Error.new(res.body.to_s) unless res.success?

        response = klass.from_json(res.body)
        yield response

        next_page = response.links.next
        if !next_page
          break
        end

        uri = next_page
      end
    end

    # Get time entries.
    #
    # Entries can be limited by *from*, *to* and *user*.
    def time_entries(*, from : Time? = nil, to : Time? = nil, user : Int | String | User | UserRef | Nil = nil, updated_since : Time? = nil)
      params = URI::Params.new
      params["updated_since"] = updated_since.to_rfc3339 if updated_since
      params["from"] = from.to_s("%Y-%m-%d") if from
      params["to"] = to.to_s("%Y-%m-%d") if to
      if user
        case user
        when String
          params["user_id"] = user
        when Int
          params["user_id"] = user.to_s
        else
          params["user_id"] = user.id.to_s
        end
      end
      time_entries = [] of TimeEntry
      get("time_entries", TimeEntriesResponse, params) do |response|
        time_entries.concat response.time_entries
      end

      time_entries
    end

    # :ditto:
    def time_entries(*, from : Time? = nil, to : Time? = nil, user : Int | String | User | UserRef | Nil = nil, updated_since : Time? = nil, &)
      time_entries(from: from, to: to, user: user, updated_since: updated_since).each do |time_entry|
        yield time_entry
      end
    end

    # Get users.
    #
    # Users can be limited to active users.
    def users(*, is_active : Bool = false, updated_since : Time? = nil)
      params = URI::Params.new
      params["updated_since"] = updated_since.to_rfc3339 if updated_since
      params["is_active"] = "true" if is_active

      users = [] of User
      get("users", UsersResponse, params) do |response|
        users.concat response.users
      end

      users
    end

    # :ditto:
    def users(*, is_active : Bool = false, updated_since : Time? = nil, &)
      users(is_active: is_active, updated_since: updated_since).each do |user|
        yield user
      end
    end

    # Get tasks.
    def tasks(updated_since : Time? = nil)
      params = URI::Params.new
      params["updated_since"] = updated_since.to_rfc3339 if updated_since

      tasks = [] of Task
      get("tasks", TasksResponse, params) do |response|
        tasks.concat response.tasks
      end

      tasks
    end

    # :ditto:
    def tasks(updated_since : Time? = nil, &)
      tasks(updated_since: updated_since).each do |task|
        yield task
      end
    end

    # Get projects.
    def projects(updated_since : Time? = nil)
      params = URI::Params.new
      params["updated_since"] = updated_since.to_rfc3339 if updated_since

      projects = [] of Project
      get("projects", ProjectsResponse, params) do |response|
        projects.concat response.projects
      end

      projects
    end

    # :ditto:
    def projects(updated_since : Time? = nil, &)
      projets(updated_since: updated_since).each do |project|
        yield project
      end
    end
  end

  class HarvestResponse
    include JSON::Serializable

    property links : PaginationLinks
  end

  class TimeEntriesResponse < HarvestResponse
    property time_entries : Array(TimeEntry)
  end

  class UsersResponse < HarvestResponse
    property users : Array(User)
  end

  class TasksResponse < HarvestResponse
    property tasks : Array(Task)
  end

  class ProjectsResponse < HarvestResponse
    property projects : Array(Project)
  end

  class PaginationLinks
    include JSON::Serializable

    property next : String?
  end
end
