class PostingDecorator
  attr_accessor :posting, :location

  def initialize(posting)
    @posting = posting
    @location = posting.location
  end

  def save
    posting.already_geolocated = !self.only_lat_and_long?
    posting.save
  end

  def only_lat_and_long?
    @only_lat_and_long ||= location && location['lat'] && location['long'] && !location['country'] && !location['state'] && !location['metro'] && !location['region'] && !location['county'] && !location['city'] && !location['locality'] && !location['zipcode']
  end

  #def method_missing(meth, *args, &block)
  #  if posting.respond_to? meth
  #    posting.send(meth)
  #  else
  #    super
  #  end
  #end
end
