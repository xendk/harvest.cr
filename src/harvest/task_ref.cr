module Harvest
  # A task reference.
  class TaskRef
    include JSON::Serializable

    property id : Int32
    property name : String
  end
end
