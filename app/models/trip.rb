require 'httparty'
require 'location'

class Trip
  def geocode(address)
    results = HTTParty.get(geocode_url(address))['results']
		coords = results[0]['geometry']['location']
		Location.new(coords['lat'], coords['lng'])
  end

	private
		def geocode_url(address)
			"https://maps.googleapis.com/maps/api/geocode/json?address=#{address.gsub(' ', '+')}"
		end
end
