# encoding: utf-8

require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))
require 'data_objects/spec/result_spec'

describe DataObjects::Mysql::Result do
  it_should_behave_like 'a Result'
  it_should_behave_like 'a Result which returns inserted keys'
end
