require 'json'

# avobject is base object
class AVObject
  def initialize data
    @src_data = data
    @data = JSON.parse @src_data
  end

  def dump_data
    @src_data    
  end
  
  def error_code
    code = @data["code"]
    code ||= 0
  end
  def error?
    error_code() != 0
  end
  
  def data_id
    @data["objectId"]
  end

  def error_msg
    return @data["error"]
  end

  def get name
    @data[name]
  end
end

# avuser is user class
class AVUser < AVObject
  def session_token
    @data["sessionToken"]
  end

  def username
    @data["username"]
  end

end

# avresult is request result of object
class AVResult < AVObject
  def initialize data
    super
    @results = []
    @data["results"].each do |item|
      object = AVObject.new(item.to_json)
      @results << object
    end
  end
  
  def results
    @results
  end

  def count
    @results.count
  end

  def get_item index
    raise "index out of count" if index >= count
    @results[index]
  end
end
