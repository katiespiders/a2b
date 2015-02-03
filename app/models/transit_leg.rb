class TransitLeg
  include Mongoid::Document
	field :mode, type: String
  field :route, type: String
  field :headsign, type: String
  field :continuation?, type: Mongoid::Boolean
  field :express?, type: Mongoid::Boolean
	embeds_many :stops
end
