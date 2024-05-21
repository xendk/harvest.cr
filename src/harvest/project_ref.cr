module Harvest
  # A project reference.
  class ProjectRef
    include JSON::Serializable

    property id : Int32
    property name : String
    property code : String?
  end
end
