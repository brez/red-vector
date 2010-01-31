require 'lib/redmajik'
require 'lib/redadapter'

class Redvector
  include Redmajik
  REPORTING = true #TODO make these configurable
  CLASSIC_NORMALIZATION = true
  def initialize()
    @store = Redadapter.new
  end
end


