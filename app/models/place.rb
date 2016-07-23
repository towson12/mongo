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

  def self.all(offset=0, limit=0)
  	searchResults = self.collection.find().skip(offset).limit(limit).to_a
    placesObjects = Array.new
    searchResults.each do |result|
      placesObjects.push(Place.new(result))
    end
    return placesObjects
  end

  def self.get_address_components(sort={}, offset=0, limit=0)
    stdParams = [ {:$unwind=>'$address_components'},
                  {:$project=>{:_id=>1,:address_components=>1,:formatted_address=>1,:geometry=>{:geolocation=>1} } } ]
    
    optParams = Array.new
    optParams.push({:$sort=>sort}) if sort.any?
    optParams.push({:$skip=>offset}) if offset > 0
    optParams.push({:$limit=>limit}) if limit > 0
  
    params = stdParams + optParams
    self.collection.aggregate(params)
  end

  def self.get_country_names
      params = [{:$project=>{:address_components=>1}},
                {:$unwind=>"$address_components"}, 
                {:$unwind=>"$address_components.types"},
                {:$match=>{"address_components.types": "country"}},
                {:$group=>{_id: "$address_components.long_name"}}]

      docs = self.collection.aggregate(params)
      docs.to_a.map{|h| h[:_id]}
  end

  def destroy 
    self.collection.find_one_and_delete(_id: BSON::ObjectId.from_string(@id))
  end



end
