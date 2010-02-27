require 'spec'
require 'redvector'

class Document
  attr_accessor :document_id
  attr_accessor :title
  attr_accessor :body
end

require 'spec/blueprints'

#Spec::Runner.configure do |config|
#  config.before(:all)    { Sham.reset(:before_all)  }
#  config.before(:each)   { Sham.reset(:before_each) }
#end
