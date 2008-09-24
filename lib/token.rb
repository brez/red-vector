class Token < ActiveRecord::Base
  has_many :postings
end
