require 'lib/redindex'
require 'lib/adapters/redpstore' #TODO make configurable
require 'lib/redadapter'
require 'lib/redexception'

class Redvector
  include Redindex
  REPORTING = true #TODO make configurable
  CLASSIC_NORMALIZATION = true
  def initialize()
    @store = Redadapter.new
  end
end


