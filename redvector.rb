require 'lib/redmajik'
require 'lib/adapters/redpstore' #TODO make configurable
require 'lib/redadapter'

class Redvector
  include Redmajik
  REPORTING = true #TODO make configurable
  CLASSIC_NORMALIZATION = true
  def initialize()
    @store = Redadapter.new
  end
end


