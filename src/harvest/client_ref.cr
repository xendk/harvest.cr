module Harvest
  # A client reference.
  class ClientRef
    include JSON::Serializable

    property id : Int32
    property name : String
    property currency : String
  end
end
