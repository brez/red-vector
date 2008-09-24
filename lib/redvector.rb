require 'stemmer'
require 'redvector_utils'

module RedVector
  STOP_WORDS = ['a','cannot','into','our','thus','about','co','is','ours','to','above','could','it','ourselves','together','across','down','its','out','too','after','during','itself','over','toward','afterwards','each','last','own','towards','again','eg','latter','per','under','against','either','latterly','perhaps','until','all','else','least','rather','up','almost','elsewhere','less','same','upon','alone','enough','ltd','seem','us','along','etc','many','seemed','very','already','even','may','seeming','via','also','ever','me','seems','was','although','every','meanwhile','several','we','always','everyone','might','she','well','among','everything','more','should','were','amongst','everywhere','moreover','since','what','an','except','most','so','whatever','and','few','mostly','some','when','another','first','much','somehow','whence','any','for','must','someone','whenever','anyhow','former','my','something','where','anyone','formerly','myself','sometime','whereafter','anything','from','namely','sometimes','whereas','anywhere','further','neither','somewhere','whereby','are','had','never','still','wherein','around','has','nevertheless','such','whereupon','as','have','next','than','wherever','at','he','no','that','whether','be','hence','nobody','the','whither','became','her','none','their','which','because','here','noone','them','while','become','hereafter','nor','themselves','who','becomes','hereby','not','then','whoever','becoming','herein','nothing','thence','whole','been','hereupon','now','there','whom','before','hers','nowhere','thereafter','whose','beforehand','herself','of','thereby','why','behind','him','off','therefore','will','being','himself','often','therein','with','below','his','on','thereupon','within','beside','how','once','these','without','besides','however','one','they','would','between','i','only','this','yet','beyond','ie','onto','those','you','both','if','or','though','your','but','in','other','through','yours','by','inc','others','throughout','yourself','can','indeed','otherwise','thru','yourselves']      
  TOKEN_REGEXP = /^[a-z]+$|^\w+\-\w+|^[a-z]+[0-9]+[a-z]+$|^[0-9]+[a-z]+|^[a-z]+[0-9]+$/ 
  SANITIZE_REGEXP = /('|\"|‘|’)/
  
  def index(document, text)
    active_tokens = Hash.new
    tokens = Simularity::generate_token_collections(text)
    tokens.values.each do |token_collection|
      token = Token.find_or_create_by_token(token_collection.token) 
      token.total_frequency ? token.total_frequency += token_collection.count : token.total_frequency = token_collection.count
      token.number_of_postings ? token.number_of_postings += 1 : token.number_of_postings = 1
      #calculate the idf [inverse document frequency] --which is log of total # of documents / # of documents that t occurs in
      token.idf = Math::log(document.class.count.to_f / token.number_of_postings.to_f) 	  
      token.save; token.reload
      #create a posting for document
      Posting.create(document.id, token.id, token_collection.count)
      active_tokens[token] = token_collection
    end
    #need to recalculate all the IDFs since early calculations will be wrong
    Token.find(:all).each do |t|
      t.idf = Math::log(document.class.count.to_f / t.number_of_postings.to_f) 
    end
    sum_of_squares = 0.0; weight = 0.0
    #preprocess for calculating the document length
    active_tokens.each do |token, token_collection|
      weight = token_collection.count.to_f * token.idf 
      sum_of_squares += weight * weight
    end
    #return the calculated length of the document --which is the square-root of the sum of the squares of the weights of its tokens
    document.document_length = Math::sqrt(sum_of_squares)
    document.save
  end
  
  # Retrieve
  # Uses a standard vector space model with tf x idf 
  # Uses an 'Accumulator' approach to avoid having to literally compare vectors (a very bad O(n^2) algorithm). 
  # @sorted_records => actual records sorted by score
  # @simularity_results => hash of matchs with score as key, records as value (not sorted)
  # @query_report => a few status abt the query options are: query_length, tokens
  # @simularity_report => specifics by token value
  def retrieve(document, text)
    #assortment of needed data structures
    @simularity_report = Hash.new; @simularity_results = Hash.new; @query_report = Hash.new
    query_tokens = Hash.new; results = Hash.new
    
    tokens = Simularity::generate_token_list(text)
    @query_report['tokens'] = tokens
	  tokens.each do |t| 
	    active_t = Token.find_by_token(t.downcase.stem)
      query_tokens.key?(t) ? query_tokens[t].count + 1 : query_tokens[active_t.token] = ResultTokenCollection.new(active_t) unless active_t == nil
      @simularity_report[active_t.token] = TokenReport.new(active_t, t) unless active_t == nil
	  end
	  
	  #calculate tf x idf weights for query tokens and accumulate postings
	  sum_of_squares = 0.0
	  documents = Hash.new   
	  query_tokens.values.each do |qt| 
	    qt.tf_x_idf = qt.count.to_f * qt.token.idf.to_f
	    postings = qt.token.postings 
	    postings.each do |posting| 
	      results[posting.document_id] = 0.0 unless results.key? posting.document_id
	      #sort out a document hash for later normalization / results
	      documents[posting.document_id] = Document.find(posting.document_id)
	      q = qt.tf_x_idf.to_f
	      d = qt.token.idf.to_f * posting.frequency.to_f
	      #accumulate for later calculation of length
        sum_of_squares += (qt.tf_x_idf.to_f)*(qt.tf_x_idf.to_f)
        #the accumulated score is the dot product of the query and the document
        results[posting.document_id] +=  q * d
        @simularity_report[qt.token.token].add_posting_detail(posting.document_id, results[posting.document_id].to_f)
      end
	  end
	  
	  query_length = Math::sqrt(sum_of_squares)
	  @query_report['query_length'] = query_length
    #normalize accordingly - dotproduct / (length of doc * length of query) 
    normalized_results = Hash.new
    results.each {|id, score| normalized_results[id] = score / (query_length * documents[id].document_length) }
    @simularity_results = normalized_results  
    weights = normalized_results.sort {|a,b| b[1] <=> a[1]}      
    sorted_ids = Array.new
    weights.each{|w| sorted_ids << w[0]}
    @sorted_records = Array.new
    #TODO - leverage exsting documents hash ? instead of getting the same things twice        
    sorted_ids.each {|a| @sorted_records << Document.find(a)}   
  end
  
  # Generate Token Collections
  # Returns a Hash of token / token reports with the stemmed word for a key and TokenReport
  # as a value  
  def generate_token_collections(text)
    text.downcase!
    tokens = Hash.new    
    text.split.each do |token| #TODO - if its an array
      token = sanitize(token)
      if token =~ TOKEN_REGEXP and !STOP_WORDS.member?(token)  
        stemmed = token.stem
        tokens[stemmed] ||= TokenCollection.new(stemmed)
        tokens[stemmed].original = token
        tokens[stemmed] + 1
      end
    end
    tokens
  end
  
  # Generate Token List
  # Prepares a potentially redundant Array of tokens
  def generate_token_list(text)
    text.downcase!
    tokens = Array.new
    text.split.each  do |token| 
      token = sanitize(token)
      tokens << token if token =~ TOKEN_REGEXP and !STOP_WORDS.member?(token)  
    end
    tokens
  end
  
  # Generate Unique Token List
  # Creates a unique test of tokens as a list
  def generate_unique_token_list(text)
    generate_token_list(text).uniq
  end  
  
  private
  def sanitize(text)
    text.downcase.gsub(SANITIZE_REGEXP, '')
  end
  
end


