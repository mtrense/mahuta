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
    
    def self.included(type)
      type.extend ClassMethods
    end
    
    def initialize(options = {})
      @options = options
    end
    
    def traverse(tree, depth = 0)
      __traverse_subtree(tree, depth)
      self
    end
    
    ##
    # Calls enter(node, depth) for the given node. If the enter method does not 
    # return :stop, this method recursively traverses the subtree under the 
    # current node. Calls leave(node, depth) after processing enter() and 
    # possibly the subtree.
    private def __traverse_subtree(node, depth)
      unless enter(node, depth) == :stop
        node.children.each do |child|
          __traverse_subtree(child, depth + 1)
        end
      end
      leave(node, depth)
    end
    
    ##
    # Tries to call a method "enter_<node_type>" with arguments of 
    # [node, [depth]] if that exists. This method might return :stop, in which 
    # case the visitor will not traverse the subtree of this node.
    def enter(node, depth)
      method_name = "enter_#{node.node_type}"
      if respond_to?(method_name)
        send method_name, *[node, depth][0...method(method_name).arity]
      end
    end
    
    ##
    # Tries to call a method "leave_<node_type>" with arguments of 
    # [node, [depth]] if that exists.
    def leave(node, depth)
      method_name = "leave_#{node.node_type}"
      if respond_to?(method_name)
        send method_name, *[node, depth][0...method(method_name).arity] # TODO Write a test for that!!!
      end
    end
    
    module ClassMethods
      
      def traverse(tree, depth = 0)
        new.traverse(tree, depth)
      end
      
    end
    
  end
  
end
