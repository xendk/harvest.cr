require "./harvest"

require "option_parser"

account_id : String? = nil
token : String? = nil
command = :none
from_date = nil
to_date = nil

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
end

puts parser if command == :none

die! "No account" unless account_id
die! "No token" unless token

case command
when :time_entries
  pp Harvest.new(account_id.not_nil!, token.not_nil!).time_entries(from: from_date, to: to_date)
end
