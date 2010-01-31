#strategy pattern adapter
#will support other adapters eventually
#the adapter code will likely change a lot when we introduce support for say, 
#redis which supports more complex data structures than pstore

#might be able to clean this up a lot with method missing due to simularities in operations
class Redadapter
  include Redpstore #this should be configurable  
  def initialize()
    connect
  end
  #document
  def token_frequency(id, frequency)
    payload = @db_document.get_document(id) || {}
    payload[:token_frequency] = frequency
    put_document(id, payload)
  end
  #token
  # TODO Stemmer
  def token(token)
    get_token(id)
  end
  def idf(token, idf)
    payload = get_token(token) 
    raise Redexception::NotAValidTokenException unless payload
    payload[:idf] = idf
    put_token(id, payload)
  end
  def number_of_postings(token)
    payload = get_token(token) 
    raise Redexception::NotAValidTokenException unless payload
    payload[:number_of_postings]
  end
  def total_frequency(frequency)
    payload = get_token(id) 
    raise Redexception::NotAValidTokenException unless payload
    payload[:total_frequency] = frequency
    put_token(id, payload)
  end
  #posting
  def posting(token, document, frequency)
    put_posting(token, {:document => document, :frequency => frequency})
  end
end