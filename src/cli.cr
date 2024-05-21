require "./harvest"

require "option_parser"

account_id : String? = nil
token : String? = nil
command = :none

# time_entries
from_date = nil
to_date = nil

# users
active = false
def die!(message)
  puts message
  exit 1
end

parser = OptionParser.parse(ARGV) do |parser|
  parser.banner = "Usage: #{PROGRAM_NAME} [options] [subcommand] [arguments]"

  parser.separator
  parser.on("-h", "--help", "Display help") do
    puts parser
    exit
  end

  parser.on("-a ID", "--account=ID", "Account ID") { |_account_id| account_id = _account_id }
  parser.on("-t TOKEN", "--token=TOKEN", "Personal access token") { |_token| token = _token }

  parser.on("time_entries", "Get time entries") do
    command = :time_entries

    parser.on("-f DATE", "--from DATE", "From date") do |date_string|
      from_date = Time.parse(date_string, "%Y-%m-%d", Time::Location::UTC)
    end

    parser.on("-o DATE", "--to DATE", "To date") do |date_string|
      to_date = Time.parse(date_string, "%Y-%m-%d", Time::Location::UTC)
    end
  end

  parser.on("users", "Get users") do
    command = :users

    parser.on("-a", "--active", "Get active users") do |date_string|
      from_date = Time.parse(date_string, "%Y-%m-%d", Time::Location::UTC)
    end
  end
end

puts parser if command == :none

die! "No account" unless account_id
die! "No token" unless token

harvest = Harvest.new(account_id.not_nil!, token.not_nil!)
case command
when :time_entries
  pp harvest.time_entries(from: from_date, to: to_date)
when :users
  pp harvest.users(is_active: active)
end
