class Photo
  include Mongoid::Document
  attr_accessor :id, :location
  attr_writer :contents

  def self.mongo_client
  	Mongoid::Clients.default
  end

  def initialize(params)
  	@id = params[:_id].to_s
  	@location = Point.new(params[:metadata][:location]) 
  end


end
