require 'spec_helper'

describe GGApi::GGObject do

  it 'initialize' do
    GGApi::GGObject.new
    GGApi::GGObject.new({})

    @params = {
      :default => 'abc',
      :limit => 'a',
      :b => 'b'
    }
    
    gg_object = GGApi::GGObject.new(@params)
    @params.each do |k, v|
      gg_object.send(k).should == v
    end
  end
end
