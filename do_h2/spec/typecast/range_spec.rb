# encoding: utf-8

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))
require 'data_objects/spec/typecast/range_spec'

describe 'DataObjects::H2 with Range' do
  it_should_behave_like 'supporting Range'
end
