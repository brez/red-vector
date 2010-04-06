#strategy pattern adapter - needs to be delgator
#will support other adapters eventually
#the adapter code will likely change a lot when we introduce support for say, 
#redis which supports more complex data structures than pstore

class Redadapter
  include Redpstore #this should be configurable
  def initialize()
    connect
  end
  def token_frequency(document_id, frequency)
    payload = get_document(document_id) if document_exists?(document_id)
    payload ||= {}
    payload[:token_frequency] = frequency
    put_document(document_id, payload)
  end
  def token(token)
    put_token(token, {:token => token, :total_frequency => 0, :number_of_postings => 0}) unless token_exists?(token)
    get_token(token) 
  end
  def idf(token, idf)
    payload = get_token(token) 
    raise Redexception::NotAValidTokenException unless payload
    payload[:idf] = idf
    put_token(token, payload)
  end
  def number_of_postings(token)
    payload = get_token(token) 
    raise Redexception::NotAValidTokenException unless payload
    payload[:number_of_postings]
  end
  def total_frequency(token)
    payload = get_token(token) 
    raise Redexception::NotAValidTokenException unless payload
    payload[:total_frequency]
  end
  def posting(token_payload, document_id, posting_frequency)
    put_token(token_payload[:token], token_payload)
    document_id_with_frequency = {document_id => posting_frequency}
    if posting_exists?(token_payload[:token])
      document_id_with_frequency.merge!(get_postings_for(token_payload[:token]))
    end
    put_posting(token_payload[:token], document_id,
      { :token => token_payload[:token], :document_id_with_frequency => document_id_with_frequency })
  end
  def all_tokens
    get_all_tokens
  end
  def postings_for(token)
    get_postings_for(token)
  end
end
