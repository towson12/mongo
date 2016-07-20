class Place
  include Mongoid::Document
  attr_accessor :id, :formatted_address, :location, :address_components

  def initialize(params)
  	@id = params[:_id]
  	@formatted_address = params[:formatted_address]
  	@location = params[:geometry[:geolocation]
  	@address_components = params[:address_components]
  end


  def mongo_client
  	Mongoid::Clients.default
  end

  def self.load_all(f)
  	hashData = JSON.parse(f.read)
  	self.collection.insert_many(hashData)
  end

end
