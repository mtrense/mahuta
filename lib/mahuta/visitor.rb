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
  
  module Visitor
    
    def initialize(options = {})
      @options = options
    end
    
    def traverse(tree, depth = 0)
      __traverse_subtree(tree, depth)
      self
    end
    
    private def __traverse_subtree(node, depth)
      enter(node, depth)
      node.children.each do |child|
        __traverse_subtree(child, depth + 1)
      end
      leave(node, depth)
    end
    
    def enter(node, depth)
      if respond_to?("enter_#{node.node_type}")
        send "enter_#{node.node_type}", *[node, depth][0...method("enter_#{node.node_type}").arity]
      end
    end
    
    def leave(node, depth)
      if respond_to?("leave_#{node.node_type}")
        send "leave_#{node.node_type}", *[node, depth][0...method("leave_#{node.node_type}").arity] # TODO Write a test for that!!!
      end
    end
    
  end
  
end
