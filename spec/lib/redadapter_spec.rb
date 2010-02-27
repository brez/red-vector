require 'spec/spec_helper'

describe Redadapter do
  it "should throw an excpetion if the adapter is not intialized" do
    pending
  end
  context "#token_frequency" do
    it "should store a token frequency for the specified token" do
      pending
    end
  end
  context "#token" do
    it "should get a token based on it's token value" do
      pending
    end
    it "should create a new token if the token is not found" do
      pending
    end
  end
  context "#idf" do
    it "should get a token based on it's token value" do
      pending
    end
    it "should create a new token if the token is not found" do
      pending
    end
  end
  
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