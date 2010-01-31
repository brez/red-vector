require 'spec/spec_helper'

describe Redvector do
  describe '#index' do
    it "should index a set of documents" do
      vector = Redvector.new
      vector.index().should be(true)
    end
  end
end