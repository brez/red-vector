require 'spec/spec_helper'

describe Redadapter do
  before(:each) do
    @adapter = Redadapter.new
    @doc = Document.make(:one)
    @another = Document.make(:two)
    @token = {:token => 'noise', :number_of_postings => 5}
  end
  after(:each) do
    @adapter.destruct
  end
  it "should set the token frequency for a given document_id" do
    @adapter.put_document(@doc.document_id, {})
    @adapter.token_frequency(@doc.document_id, 100)
    @adapter.get_document(@doc.document_id)[:token_frequency].should == 100
  end
  it "should create a new document if one doesn't exist while setting the token frequency" do
    @adapter.token_frequency(@doc.document_id, 100)
    @adapter.get_document(@doc.document_id).should_not be(nil)
  end
  it "should get a token based on it's token value" do
    @adapter.put_token(@token[:token], @token)
    @adapter.token(@token[:token]).should be_an_instance_of(Hash)
  end
  it "should create a new token if the token is not found" do
    @adapter.token(@token[:token]).should be_an_instance_of(Hash)
  end
  it "should contain the token when creating a token" do
    @adapter.token(@token[:token])[:token].should == @token[:token] 
  end
  it "should intialize the token frequency to zero when creating a token" do
    @adapter.token(@token[:token])[:total_frequency].should == 0 
  end
  it "should intialize the number of postings to zero when creating a token" do
    @adapter.token(@token[:token])[:number_of_postings].should == 0 
  end
  it "should set the idf value for a given token" do
    @adapter.put_token(@token[:token], @token)
    @adapter.idf(@token[:token], 2.1009)
    @adapter.get_token(@token[:token])[:idf].should == 2.1009 
  end
  it "should throw an exception if the token if an invalid token is passed to set the idf" do
    lambda{@adapter.idf(@token[:token], 2.1009)}.should raise_error(Redexception::TokenMissing)
  end
  it "should return the number of postings for a given token" do
    @adapter.put_token(@token[:token], @token)
    @adapter.number_of_postings(@token[:token]).should == @token[:number_of_postings]
  end
  it "should throw an exception if the token if an invalid token is passed to set the number of postings" do
    lambda{@adapter.number_of_postings(@token[:token])}.should raise_error(Redexception::TokenMissing)
  end
  it "should get the total frequency for a given token" do
    @token[:total_frequency] = 21
    @adapter.put_token(@token[:token], @token)
    @adapter.total_frequency(@token[:token]).should == 21
  end
  it "should throw an exception if the token is not found" do
    lambda{@adapter.total_frequency(@token[:token])}.should raise_error(Redexception::TokenMissing)
  end
  it "should set the posting for a existing token hash and document_id with posting frequency" do
    @token[:number_of_postings] = 6
    @token[:total_frequency] = 12
    @adapter.put_document(@doc.document_id, {})
    @adapter.put_token(@token[:token], @token)
    @adapter.posting(@token, @doc.document_id, 2)
    @adapter.get_token(@token[:token])[:number_of_postings].should == 6
    @adapter.get_token(@token[:token])[:total_frequency].should == 12
    @adapter.get_posting(@token[:token])[:document_id_with_frequency].should == { @doc.document_id => 2 }
  end
  it "should set the posting for a new token hash and document_id with posting frequency" do
    @token[:number_of_postings] = 6
    @token[:total_frequency] = 12
    @adapter.put_document(@doc.document_id, {})
    @adapter.posting(@token, @doc.document_id, 2)
    @adapter.get_token(@token[:token])[:number_of_postings].should == 6
    @adapter.get_token(@token[:token])[:total_frequency].should == 12
    @adapter.get_posting(@token[:token])[:document_id_with_frequency].should == { @doc.document_id => 2 }
  end
  it "should maintain the posting details for an existing token when adding a new posting" do
    @adapter.put_document(@doc.document_id, {})
    @adapter.posting(@token, @doc.document_id, 1)
    @adapter.put_document(@another.document_id, {})
    @adapter.posting(@token, @another.document_id, 1)
    @adapter.get_posting(@token[:token])[:document_id_with_frequency].should == { @doc.document_id => 1, @another.document_id => 1 }
  end  
  it "should retrieve all the tokens in the entire store" do
    @adapter.put_token(@token[:token], @token)
    @adapter.all_tokens.size.should == 1
  end
  it "should retrieve all postings for a given token" do
    @adapter.put_document(@doc.document_id, {})
    @adapter.put_token(@token[:token], @token)
    @adapter.posting(@token, @doc.document_id, 1)
    @adapter.postings_for(@token[:token]).size.should == 1
  end
end
