module Harvest
  # A Harvest time entry.
  class TimeEntry
    include JSON::Serializable

    property id : Int64
    @[JSON::Field(converter: Time::Format.new("%Y-%m-%d"))]
    property spent_date : Time
    property hours : Float64
    property rounded_hours : Float64
    # Sometimes Harvest returns null rather than an empty string.
    property notes : String = ""
    property is_closed : Bool
    property is_billed : Bool
    property timer_started_at : Time?
    property created_at : Time
    property updated_at : Time
    property user : UserRef
    property client : ClientRef
    property project : ProjectRef
    property task : TaskRef
  end
end
