require 'spec_helper'
require_relative '../bin'

describe Bin do
  it "should initialize without error" do
    expect { described_class.new }.to_not raise_error
  end
end
