module Harvest
  # A Harvest user.
  class User
    include JSON::Serializable

    property id : Int32
    property first_name : String
    property last_name : String
    property email : String
    property is_contractor : Bool
    property is_active : Bool
    property created_at : Time
    property updated_at : Time
  end
end