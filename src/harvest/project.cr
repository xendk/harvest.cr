module Harvest
  # A Harvest project.
  class Project
    include JSON::Serializable

    property id : Int64
    property name : String
    property is_active : Bool
    property is_billable : Bool
    property created_at : Time
    property updated_at : Time
  end
end
