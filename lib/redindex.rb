require 'lib/redutils'

module Redindex

  def index(document_id, text, finalize=false)
    tokens = TokenCollection.generate(text)
    @store.token_frequency(document_id, tokens.size)
    tokens.values.each do |token_collection|
      token = @store.token(token_collection.token)
      token[:total_frequency] += token_collection.count
      token[:number_of_postings] += 1
      @store.posting(token, document_id, token_collection.count)
    end
    #calculate_document_length(document_id)
    finalize_index if finalize
  end

  def calculate_document_length(document_id)
    sum_of_squares, weight = 0.0, 0.0
    @store.tokens_for(document_id).each do |token|
      weight = @store.number_of_postings(token).to_f * @store.idf_for(token)
      sum_of_squares += weight ** 2
    end
    @store.set_length(document_id, Math::sqrt(sum_of_squares))
  end

  def finalize_index
    @store.all_tokens.each do |token| # TODO this needs to be an iterator
      @store.set_idf_for(token, (Math::log(@store.count.to_f / @store.number_of_postings(token).to_f)))
    end
  end

end


