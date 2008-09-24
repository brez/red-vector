
#
# Serves as a collection wrapper for the token / it's counts
class TokenCollection
  attr_accessor :token
  attr_accessor :original
  attr_accessor :count
  def initialize(t)
    @token = t
    @count = 1
  end
  def +(x)
    @count += x
  end
end

#
# Serves as a collection wrapper for the simularity results
class ResultTokenCollection < TokenCollection
  attr_accessor :tf_x_idf
  def intialize(t)
    super(t)
    @tf_x_idf = 0.0
  end
end

#
# Full Simularity report 
class SimularityReport 
  attr_accessor :query
  attr_accessor :query_length
  attr_accessor :reports
  attr_accessor :results
  def intialize()
    @query = Array.new
    @query_length = 0.0
    @reports = Hash.new
    @results = Hash.new
  end
end

#
# Token report for article getting comparison   
class TokenReport 
  attr_accessor :results
  attr_accessor :postings
  attr_accessor :original
  def initialize(t, original)
    @original = original
    @token = t
    @postings = Hash.new
    @results = Hash.new
  end
  def add_posting_detail(id, tf_idf)
    @postings[id] = tf_idf
  end
end