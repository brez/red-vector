require 'pstore'

module Redpstore
  DB_DOCUMENTFILE = 'db_document.pstore'
  DB_POSTINGFILE  = 'db_posting.pstore'
  DB_TOKENFILE    = 'db_token.pstore'
  DB_DIR          = 'redvectordb/' #this should be configurable
  DB_PATH         = "#{File.dirname(__FILE__)}/#{DB_DIR}"
  def connect
    Dir::mkdir(DB_PATH) unless File.exists?(DB_PATH)
    @db_document = PStore.new(DB_PATH+DB_DOCUMENTFILE)
    @db_posting = PStore.new(DB_PATH+DB_POSTINGFILE)
    @db_token = PStore.new(DB_PATH+DB_TOKENFILE)
  end
  def destruct #use with caution - exists primarily for specs
    File.delete(DB_PATH+DB_DOCUMENTFILE) if File.exists?(DB_PATH+DB_DOCUMENTFILE)
    File.delete(DB_PATH+DB_POSTINGFILE) if File.exists?(DB_PATH+DB_POSTINGFILE)
    File.delete(DB_PATH+DB_TOKENFILE) if File.exists?(DB_PATH+DB_TOKENFILE)
    Dir::rmdir(DB_PATH)
  end
  def put_document(id, payload)
    @db_document.transaction do
      @db_document[id] = payload
    end
  end
  def get_document(id)
    @db_document.transaction do
      raise Redexception::DocumentIdMissing if @db_document[id].nil?
      @db_document[id]
    end
  end
  def document_exists?(id)
    @db_document.transaction do
      !@db_document[id].nil?
    end
  end
  def put_posting(token, posting)
    @db_token.transaction do
      raise Redexception::TokenMissing if @db_token[posting[:token]].nil?
    end
    @db_document.transaction do
      raise Redexception::DocumentIdMissing if @db_document[posting[:document_id]].nil?
    end
    @db_posting.transaction do
      @db_posting[token] = posting
    end
  end
  def get_posting(token)
    @db_posting.transaction do
      raise Redexception::PostingMissing if @db_posting[token].nil?
      @db_posting[token]
    end
  end
  def get_token(token)
    @db_token.transaction do
      raise Redexception::TokenMissing if @db_token[token].nil?
      @db_token[token]
    end
  end
  def put_token(token, payload)
    @db_token.transaction do
      @db_token[token] = payload 
    end
  end
  def token_exists?(token)
    @db_token.transaction do
      !@db_token[token].nil?
    end
  end
end
