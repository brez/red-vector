require 'stemmer'
require 'stopwords'

class String
  TOKEN_REGEXP = /^[a-z]+$|^\w+\-\w+|^[a-z]+[0-9]+[a-z]+$|^[0-9]+[a-z]+|^[a-z]+[0-9]+$/
  SANITIZE_REGEXP = /('|\"|‘|’|\/|\\)/
  def tokenize
    tokens = Array.new
    self.split.each  do |token|
      token.sanitize!
      tokens << token if token =~ TOKEN_REGEXP and Stopwords.valid?(token)
    end
    tokens
  end
  def sanitize
    self.downcase.gsub(SANITIZE_REGEXP, '')
  end
  def sanitize!
    self.replace(self.sanitize)
  end
end

class TokenCollection
  attr_accessor :token
  attr_accessor :original
  attr_accessor :count
  attr_accessor :tf_x_idf
  def initialize(token)
    @token, @count, @tf_x_idf = token, 1, 0.0
  end
  def +(x)
    @count += x
  end
  def self.generate(text)
    tokens = Hash.new
    text.tokenize.each do |token|
      stemmed = token.stem
      tokens[stemmed] ||= self.new(stemmed)
      tokens[stemmed].original = token
      tokens[stemmed] + 1
    end
    tokens
  end
end


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