class Stop
  include Mongoid::Document
  field :name, type: String
  field :stop_id, type: Integer
  field :scheduled, type: Time
  field :actual, type: Time
	embedded_in :transit_leg
end
