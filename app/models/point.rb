class Point
	attr_accessor :longitude, :latitude

	def initialize(params)
		@longitude=params[:lng] ||= params[:coordinates][0]
		@latitude=params[:lat] ||= params[:coordinates][1] 
	end

	def to_hash
		return {"type": "Point", "coordinates": [@longitude, @latitude]}
	end



end
