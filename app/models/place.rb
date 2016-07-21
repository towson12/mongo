class Place
  include Mongoid::Document
  attr_accessor :id, :formatted_address, :location, :address_components

  def initialize(params)
  	@id = params[:_id].to_s
  	@formatted_address = params[:formatted_address]
  	@location = Point.new(params[:geometry][:geolocation])
  	@address_components = Array.new
  	params[:address_components].each do |component|
  		@address_components.push(AddressComponent.new(component))
  	end
  end

  def mongo_client?
  	Mongoid::Clients.default
  end

  def self.load_all(f)
  	hashData = JSON.parse(f.read)
  	self.collection.insert_many(hashData)
  end

end
