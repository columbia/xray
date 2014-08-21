class Advertisement
  include Mongoid::Document     
  include Mongoid::Timestamps   
  
  validates :title, presence: true,       
                    length: { minimum: 5 }

  field :title, type: String
  field :text, type: String
  field :link, type: String
end
