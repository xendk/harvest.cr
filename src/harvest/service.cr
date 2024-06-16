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
      time_entries = [] of TimeEntry

      time_entries(from: from, to: to, user: user, updated_since: updated_since) do |time_entry|
        time_entries << time_entry
      end

      time_entries
    end

    # :ditto:
    def time_entries(*, from : Time? = nil, to : Time? = nil, user : Int | String | User | UserRef | Nil = nil, updated_since : Time? = nil, &)
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
        response.time_entries.each do |time_entry|
          yield time_entry
        end
      end
    end

    # Get users.
    #
    # Users can be limited to active users.
    def users(*, is_active : Bool = false, updated_since : Time? = nil)
      users = [] of User

      users(is_active: is_active, updated_since: updated_since) do |user|
        users << user
      end

      users
    end

    # :ditto:
    def users(*, is_active : Bool = false, updated_since : Time? = nil, &)
      params = URI::Params.new
      params["updated_since"] = updated_since.to_rfc3339 if updated_since
      params["is_active"] = "true" if is_active

      get("users", UsersResponse, params) do |response|
        response.users.each do |user|
          yield user
        end
      end
    end

    # Get tasks.
    def tasks(updated_since : Time? = nil)
      tasks = [] of Task

      tasks(updated_since: updated_since) do |task|
        tasks << task
      end

      tasks
    end

    # :ditto:
    def tasks(updated_since : Time? = nil, &)
      params = URI::Params.new
      params["updated_since"] = updated_since.to_rfc3339 if updated_since

      get("tasks", TasksResponse, params) do |response|
        response.tasks.each do |task|
          yield task
        end
      end
    end

    # Get projects.
    def projects(updated_since : Time? = nil)
      projects = [] of Project

      projects(updated_since: updated_since) do |project|
        projects << project
      end

      projects
    end

    # :ditto:
    def projects(updated_since : Time? = nil, &)
      params = URI::Params.new
      params["updated_since"] = updated_since.to_rfc3339 if updated_since

      get("projects", ProjectsResponse, params) do |response|
        response.projects.each do |project|
          yield project
        end
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
