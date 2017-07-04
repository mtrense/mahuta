# encoding: UTF-8
# Copyright 2017 Max Trense
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#   http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module Mahuta
  require 'mahuta/version'
  require 'mahuta/common'
  require 'mahuta/schema'
  require 'mahuta/node'
  require 'mahuta/visitor'
  require 'mahuta/utils'
  
  def self.build(schema, attributes = {}, &block)
    Node.new(nil, schema, :root, attributes, &block)
  end
  
  def self.import(node, file)
    loc = caller_locations.reject {|l| %r'lib/mahuta' === l.path }.first
    dir = Pathname(loc.path).parent
    file = file + '.rb' unless file.include?('.')
    path = (dir + file).to_s
    node.instance_eval(File.read(path), path)
    node
  end
  
end
