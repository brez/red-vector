require 'spec/spec_helper'

describe Redpstore do
  before(:each) do
    @adapter = Redadapter.new
    @doc = Document.make(:one)
    @token = {:token => 'noise'} 
    @posting = {:token => 'noise', :document_id => @doc.document_id} 
  end
  after(:each) do
    @adapter.destruct
  end
  describe '#put_document' do
    it "should put a document payload based on supplied id" do
      @adapter.put_document(@doc.document_id, {}).should be(true)
    end
  end
  describe '#get_document' do
    it "should get a document payload based on supplied id" do
      @adapter.put_document(@doc.document_id, {})
      @adapter.get_document(@doc.document_id).should be(true)
    end
    it "should throw a RedVectorDocumentIdMissing exception is the document_id is not found" do
      @adapter.put_document(@doc.document_id, {})
      lambda{@adapter.get_document(999).should be(true)}.should raise_error(Redexception::DocumentIdMissing)
    end
  end
  describe '#add_posting' do
    it "should add a posting payload based on supplied token and posting hash" do
      @adapter.put_document(@posting[:document_id], {})
      @adapter.put_token(@posting[:token], @token)
      @adapter.add_posting(@token[:token], @posting).should be(true) 
    end
    it "should throw a DocumentIdMissing exception is the Document Id isn't present in the store" do
      @adapter.put_token(@posting[:token], @token)
      lambda{@adapter.add_posting(@token[:token], @posting)}.should raise_error(Redexception::DocumentIdMissing)
    end
    it "should throw a TokenMissing exception is the token isn't present in the store" do
      @adapter.put_document(@posting[:document_id], {})
      lambda{@adapter.add_posting(@token[:token], @posting)}.should raise_error(Redexception::TokenMissing)
    end
  end
  describe '#get_token' do
    it "should get a token payload based on supplied token" do
      @adapter.put_token(@token[:token], @token)
      @adapter.get_token(@token[:token]).should be(true)
    end
    it "should throw a Token Missing exeception if the token is missing from the store" do
      lambda{@adapter.get_token(@token[:token])}.should raise_error(Redexception::TokenMissing)
    end
  end
  describe '#put_token' do
    it "should put a token payload based on supplied token" do
      @adapter.put_token(@token[:token], @token).should be(true)
    end
  end
end
