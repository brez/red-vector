require 'stemmer'
require 'stopwords'
require 'lib/redutils'

module Redmajik
  STOP_WORDS = Stopwords::STOP_WORDS
  SANITIZE_REGEXP = /('|\"|‘|’|\/|\\)/
  
  def index(document_id, text)
    tokens = Redmajik::generate_token_collections(text)
    @store.token_frequency(document_id, tokens.size)
    tokens.values.each do |token_collection|
      token = @store.token(token_collection.token) 
      token.total_frequency += token_collection.count
      token.number_of_postings += 1
      @store.posting(token_collection.token, document_id, token_collection.count)
    end
  end
  
  #TODO daemon this
  def calculate_IDFs()
    @store.all_tokens.each do |token| # TODO this needs to be an iterator
      @store.set_idf_for(token, (Math::log(@store.count.to_f / @store.number_of_postings(token).to_f))
    end
  end
  
  def calculate_document_length(document_id)
    sum_of_squares = 0.0; weight = 0.0
    #preprocess for calculating the document length
    @store.tokens_for(document_id).each |token|
      weight = @store.number_of_postings(token).to_f * @store.idf_for(token)
      sum_of_squares += weight * weight
    end
      @store.set_length_(document_id, Math::sqrt(sum_of_squares)
    end
  end
  
  # Standard vector space model with tf x idf 
  # Uses an 'Accumulator' approach to avoid having to literally compare vectors (a very bad O(n^2) algorithm). 
  #
  # Makes a few variables available to the calling class
  # @sorted_records => actual records sorted by score
  # @simularity_results => hash of matchs with score as key, records as value (not sorted)
  # @query_report => a few status abt the query options are: query_length, tokens
  # @simularity_report => specifics by token value
  def retrieve(document, text)
    @simularity_report = Hash.new; @simularity_results = Hash.new; @query_report = Hash.new #leave this in regardless of REPORTING status
    query_tokens = Hash.new; @raw_results = Hash.new
    
    tokens = Redmajik::tokenize(text)
    @query_report[:tokens] = tokens if REPORTING
	  tokens.each do |token| 
	    active_token = @store.token?(t.downcase.stem)
	    unless active_token == nil
        query_tokens.key?(token) ? query_tokens[token].count + 1 : query_tokens[active_token] = ResultTokenCollection.new(active_token)
      end
      (@simularity_report[active_token] = TokenReport.new(active_token, t) unless active_token == nil) if REPORTING
	  end
	  
	  #calculate tf x idf weights for query tokens and accumulate postings
	  sum_of_squares = 0.0; @raw_query_score = 0.0
	  documents = Hash.new   
	  query_tokens.values.each do |qt| 
	    qt.tf_x_idf = qt.count.to_f * qt.token.idf.to_f
	    postings = qt.token.postings 
	    postings.each do |posting| 
	      @raw_results[posting.document_id] = 0.0 unless @raw_results.key? posting.document_id
	      #sort out a document hash for later normalization / @raw_results
	      documents[posting.document_id] = posting.document_id
	      q = qt.tf_x_idf.to_f
	      d = qt.token.idf.to_f * posting.frequency.to_f
	      #accumulate for later calculation of length
        sum_of_squares += qt.tf_x_idf.to_f**2
        #the accumulated score is the dot product of the query and the document
        @raw_results[posting.document_id] +=  q * d  
        @simularity_report[qt.token.token].add_posting_detail(posting.document_id, @raw_results[posting.document_id].to_f)
        @raw_query_score += qt.tf_x_idf.to_f
      end
	  end
	  
	  query_length = Math::sqrt(sum_of_squares)
	  @query_report[:query_length] = query_length
    #normalize accordingly - dotproduct / (length of doc * length of query)  
    if CLASSIC_NORMALIZATION
      @raw_results.each {|id, score| @simularity_results[id] = score / (query_length * documents[id].document_length) }  
    else #instead divide raw score by query score
      @raw_results.each {|id, score| @simularity_results[id] = score / @raw_query_score }  
    end  end
  
  # Prepares a potentially redundant Array of tokens
  def self.tokenize(text)
    text.downcase!
    tokens = Array.new
    text.split.each  do |token| 
      token = sanitize(token)
      if token =~ Stopwords.valid?(token)  
        tokens << token 
      end
    end
    tokens
  end
  
  private

  def self.sanitize(text)
    text.downcase.gsub(SANITIZE_REGEXP, '')
  end

end


