# encoding: utf-8

require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))
require 'data_objects/spec/command_spec'

describe DataObjects::H2::Command do
  it_should_behave_like 'a Command'
end
