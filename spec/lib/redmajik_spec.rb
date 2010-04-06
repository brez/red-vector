require 'spec/spec_helper'

describe Redmajik do
  before(:each) do
    @adapter = Redadapter.new
    @class = Class.new
    @class.extend(Redmajik)
    @class.instance_variable_set(:@store, @adapter)
  end
  after(:each) do
    @adapter.destruct
  end
  it "should index a set of documents" do
    docs = Array.new
    [:one, :two, :three].each do |doc|
      docs << Document.make(doc)
    end
    docs.each do |doc|
      @class.index(doc.document_id, doc.body)
      @adapter.document_exists?(doc.document_id).should be(true)
    end
  end
  it "should index a document and create a series of stemmed/stopworded tokens" do
    doc = Document.make(:simple)
    @class.index(doc.document_id, doc.body)
    @adapter.all_tokens.size.should == 3
  end
  it "should index more than one document and create a series of postings for the appropriate token" do
    doc = Document.make(:simple)
    @class.index(doc.document_id, doc.body)
    another = Document.make(:simple)
    another.document_id = another.document_id + 1
    @class.index(another.document_id, another.body)
    @adapter.postings_for('simpl').size.should == 2
  end
end
