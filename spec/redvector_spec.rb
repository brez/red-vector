require 'spec/spec_helper'

describe Redvector do
  before(:each) do
    @docs = Array.new
    [:one, :two, :three].each do |doc|
      @docs << Document.make(doc)
    end
  end
  describe '#index' do
    it "should index a set of documents" do
      vector = Redvector.new
      @docs.each do |doc|
        vector.index(doc.document_id, doc.body).should be(true)
      end
    end
  end
end
