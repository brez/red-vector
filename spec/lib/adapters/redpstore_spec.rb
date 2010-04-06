require 'spec/spec_helper'

describe Redpstore do
  before(:each) do
    @adapter = Redadapter.new
    @doc = Document.make(:one)
    @token = {:token => 'noise'} 
    @posting = {:token => 'noise', :document_id_with_frequency => {@doc.document_id => 1 }} 
  end
  after(:each) do
    @adapter.destruct
  end
  it "should put and get a document payload based on supplied id" do
    @adapter.put_document(@doc.document_id, {})
    @adapter.get_document(@doc.document_id).should == {}
  end
  it "should check to see if a document exists based on its document_id" do
    @adapter.put_document(@doc.document_id, {})
    @adapter.document_exists?(@doc.document_id).should be(true)
  end
  it "should return false if a document doesn't exists based on its document_id" do
    @adapter.document_exists?(@doc.document_id).should be(false)
  end
  it "should throw a RedVectorDocumentIdMissing exception is the document_id is not found" do
    @adapter.put_document(@doc.document_id, {})
    lambda{@adapter.get_document(999).should be(true)}.should raise_error(Redexception::DocumentIdMissing)
  end
  it "should put a posting payload based on supplied token and posting hash" do
    @adapter.put_document(@posting[:document_id], {})
    @adapter.put_token(@posting[:token], @token)
    @adapter.put_posting(@token[:token], @posting[:document_id], @posting)
    @adapter.get_posting(@token[:token]).should == @posting
  end
  it "should get a posting payload based on supplied token" do
    @adapter.put_document(@posting[:document_id], {})
    @adapter.put_token(@posting[:token], @token)
    @adapter.put_posting(@token[:token], @posting[:document_id], @posting)
    @adapter.get_posting(@token[:token])[:token].should == @token[:token]
    @adapter.get_posting(@token[:token])[:document_id_with_frequency].should == { @doc.document_id => 1 }
  end
  it "should throw a DocumentIdMissing exception is the Document Id isn't present in the store" do
    @adapter.put_token(@posting[:token], @token)
    lambda{@adapter.put_posting(@token[:token], @posting[:document_id], @posting)}.should raise_error(Redexception::DocumentIdMissing)
  end
  it "should throw a TokenMissing exception is the token isn't present in the store" do
    @adapter.put_document(@posting[:document_id], {})
    lambda{@adapter.put_posting(@token[:token], @posting[:document_id], @posting)}.should raise_error(Redexception::TokenMissing)
  end
  it "should put and get a token payload based on supplied token" do
    @adapter.put_token(@token[:token], @token)
    @adapter.get_token(@token[:token]).should == @token
  end
  it "should throw a Token Missing exeception if the token is missing from the store" do
    lambda{@adapter.get_token(@token[:token])}.should raise_error(Redexception::TokenMissing)
  end
  it "should check to see if a token exists based on its token value" do
    @adapter.put_token(@token[:token], @token)
    @adapter.token_exists?(@token[:token]).should be(true)
  end
  it "should return false if a token doesn't exists based on its token value" do
    @adapter.token_exists?(@token[:token]).should be(false)
  end
  it "should retrieve all the tokens in the entire store" do
    @adapter.put_token(@token[:token], @token)
    @adapter.get_all_tokens.size.should == 1
  end
  it "should retrieve all postings for a given token" do
    @adapter.put_document(@posting[:document_id], {})
    @adapter.put_token(@posting[:token], @token)
    @adapter.put_posting(@token[:token], @posting[:document_id], @posting)
    @adapter.get_postings_for(@token[:token]).size.should == 1
  end
  it "should check to see if a posting exists based on its token value" do
    @adapter.put_document(@posting[:document_id], {})
    @adapter.put_token(@token[:token], @token)
    @adapter.put_posting(@token[:token], @posting[:document_id], @posting)
    @adapter.posting_exists?(@token[:token]).should be(true)
  end
  it "should return false if a posting doesn't exists based on its token value" do
    @adapter.posting_exists?(@token[:token]).should be(false)
  end
end
