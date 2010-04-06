require 'lib/redutils'

module Redretrieve

  # Standard vector space model with tf x idf
  # Uses an 'Accumulator' approach to avoid having to literally compare 
  # vectors (a very bad O(n^2) algorithm).
  #
  # Makes a few variables available if REPORTING is true
  # @sorted_records => actual records sorted by score
  # @simularity_results => hash of matchs with score as key, records as value (not sorted)
  # @query_report => a few status abt the query options are: query_length, tokens
  # @simularity_report => specifics by token value
  def retrieve(text)
    @simularity_report, @simularity_results, @query_report, query_tokens, @raw_results = {},{},{},{},{}
    @query_report[:tokens] = tokens if REPORTING
    text.tokenize.each do |token| 
      active_token = @store.token?(token.downcase.stem)
      unless active_token.nil?
        if query_tokens.key?(token)
          query_tokens[token].count + 1
        else
          query_tokens[active_token] = ResultTokenCollection.new(active_token)
        end
      end
      (@simularity_report[active_token] = TokenReport.new(active_token, t) unless active_token == nil) if REPORTING
    end

    #calculate tf x idf weights for query tokens and accumulate postings
    sum_of_squares = 0.0
    @raw_query_score = 0.0
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
    end
  end

end


