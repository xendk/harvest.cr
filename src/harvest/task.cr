module Harvest
  # A Harvest task.
  class Task
    include JSON::Serializable

    property id : Int32
    property name : String
    property billable_by_default : Bool
    property created_at : Time
    property updated_at : Time
  end
end
