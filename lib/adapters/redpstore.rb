require 'pstore'

#currently this is immutable i.e. you make an index and you use it
#then make another if you change anything -plan to introduce a delta strategy
module Redpstore
  def connect
    DB_DOCUMENTFILE = 'db_document.pstore'
    DB_POSTINGFILE = 'db_posting.pstore'
    DB_TOKENFILE = 'db_token.pstore'
    DB_DIR = 'redvectordb/' #this should be configurable
    DB_PATH = "#{File.dirname(__FILE__)}/#{DB_DIR}"
    Dir::mkdir(DB_PATH) unless File.exists?(DB_PATH)
    @db_document = PStore.new(DB_PATH+DB_DOCUMENTFILE) 
    @db_posting = PStore.new(DB_PATH+DB_POSTINGFILE)
    @db_token = PStore.new(DB_PATH+DB_TOKENFILE)
  end
  def put_document(id, payload)
    @db_document.transaction do
      @db_document[token] = payload 
    end
  end
  def get_document(id)
    @db_document.transaction do
      @db_document[id]
    end
  end
  def add_posting(token)
    @db_posting.transaction do
      @db_posting[token] = pass_hash 
    end
  end
  def get_token(token)
    @db_token.transaction do
      @db_token[token]
    end
  end
  def put_token(token, payload)
    @db_token.transaction do
      @db_token[token] = payload 
    end
  end
end
