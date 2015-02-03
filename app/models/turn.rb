class Turn
  include Mongoid::Document
  field :street, type: String
  field :abs_direction, type: String
  field :rel_direction, type: String
  field :distance, type: Float
	embedded_in :street_leg
end
