class Place
  include Mongoid::Document

  def mongo_client
  	Mongoid::Clients.default
  end

  def self.load_all(f)
  	hashData = JSON.parse(f.read)
  	self.collection.insert_many(hashData)
  end

end
