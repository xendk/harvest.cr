module Harvest
  # A user reference.
  class UserRef
    include JSON::Serializable

    property id : Int64
    property name : String
  end
end
