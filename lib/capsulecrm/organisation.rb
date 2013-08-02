class CapsuleCRM::Organisation < CapsuleCRM::Party

  attr_accessor :about
  attr_accessor :name

  define_attribute_methods [:about, :name]

  def attributes
    attrs = {}
    arr = [:about, :first_name, :last_name, :title, :job_title]
    arr.each do |key|
      attrs[key] = self.send(key)
    end
    attrs
  end

  def about=(value)
    about_will_change! unless value = about
    @about = value
  end

  def name=(value)
    name_will_change! unless value = name
    @name = value
  end
  
  # nodoc
  def people
    return @people if @people
    path = self.class.get_path
    path = [path, '/', id, '/people'].join
    last_response = self.class.get(path)
    @people = CapsuleCRM::Person.init_many(last_response)
  end

  def save
    new_record?? create : update
  end

  private

  def create
    path = '/api/organisation/'
    options = {:root => 'person', :path => path}
    new_id = self.class.create dirty_attributes, options
    unless new_id
      errors << self.class.last_response.response.message
      return false
    end
    @errors = []
    changed_attributes.clear
    self.id = new_id
    self
  end


  def dirty_attributes
    Hash[attributes.select { |k,v| changed.include? k.to_s }]
  end

  def update
    path = '/api/organisation/' + id.to_s
    options = {:root => 'organisation', :path => path}
    success = self.class.update id, dirty_attributes, options
    changed_attributes.clear if success
    success
  end


  # nodoc
  def self.init_many(response)
    data = response['parties']['organisation']
    CapsuleCRM::Collection.new(self, data)
  end


  # nodoc
  def self.init_one(response)
    data = response['organisation']
    new(attributes_from_xml_hash(data))
  end


  # nodoc
  def self.xml_map
    map = {
      'about' => 'about',
      'name' => 'name'
    }
    super.merge map
  end


end
