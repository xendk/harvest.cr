module Harvest
  # A project reference.
  class ProjectRef
    include JSON::Serializable

    property id : Int64
    property name : String
    property code : String?
  end
end
