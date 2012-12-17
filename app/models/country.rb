class Country
  include Mongoid::Document

  index({ code: 1 })

  attr_accessible :name, :code, :name_translations

  field :name, localize: true
  field :code

  scope :sorted, asc(:"name.en-US") #NOTE needed for development

  def _name
    self.name_translations['en-US'] #NOTE needed for development
  end
end
