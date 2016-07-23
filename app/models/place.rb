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

  def self.mongo_client?
  	Mongoid::Clients.default
  end

  def self.collection
  	mongo_client["places"]
  end

  def self.load_all(f)
  	hashData = JSON.parse(f.read)
  	self.collection.insert_many(hashData)
  end

  def self.find_by_short_name(param)
  	self.collection.find("address_components.short_name": param)
  end

  def self.to_places(params)
  	createdPlaces = Array.new
  	params.each do |place|
  		createdPlaces.push(Place.new(place))
  	end
  	return createdPlaces
  end

  def self.find(id)
  	id = BSON::ObjectId.from_string(id)
  	doc = self.collection.find(_id: id).first
  	if doc
  		Place.new(doc)
  	else
  		nil
  	end 
  end


end
