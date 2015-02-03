class StreetLeg
  include Mongoid::Document
  field :mode, type: String
	field :start_time, type: Time
	field :end_time, type: Time
	embeds_many :turns
end
