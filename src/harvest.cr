require "json"
require "uri"
require "http/client"
require "./harvest/**"

# This is a minimal client for the Harvest time tracking service.
module Harvest
  VERSION = {{ `shards version "#{__DIR__}"`.chomp.stringify }}

  class Error < Exception end

  # Get a client instance.
  def self.new(account_id : String, token : String)
    Client.new(account_id, token)
  end
end
