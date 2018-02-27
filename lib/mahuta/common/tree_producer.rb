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

module Mahuta::Common
  
  module TreeProducer
    
    def self.included(type)
      unless [ Mahuta::Visitor ].all? {|mod| type.ancestors.include?(mod) }
        warn 'TreeProducer needs features from Mahuta::Visitor, be sure to include it'
      end
    end
    
    def initialize(options = {})
      @result = options.delete(:result)
      pin! @result
      super
    end
    
    attr_reader :result, :current
    
    def pin!(node)
      @current = node
    end
    
    ##
    # Overrides the __traverse_subtree method from Visitor. Adds the notion of 
    # a current node in the resulting tree, which then acts as cursor for all 
    # further node insertions.
    private def __traverse_subtree(node, depth)
      last = current
      begin
        super
      ensure
        pin! last
      end
    end
    
    ##
    # Implementation of enter that calls transform for the traversed node.
    def enter(node, depth)
      transform(node)
    end
    
    ##
    # Called to do the actual transformation of the source node into the target 
    # node. Delegates to transform_<node_type> if possible. The default 
    # implementation does nothing.
    def transform(source)
      method_name = "transform_#{source.node_type}"
      if respond_to?(method_name)
        send method_name, source
      end
    end
    
    ##
    # Copies the given node into the resulting tree. Includes all attributes 
    # and the schema if the given node has one.
    def copy_node!(source)
      child! source.node_type, source.attributes.merge({ __location: source })
      if source.has_schema?
        current.instance_variable_set(:@schema, source.instance_variable_get(:@schema))
      end
    end
    
    ##
    # Adds a new child and leaves the current stack pointer on the current node.
    def child(node_type, attributes = {}, &block)
      raise 'Cannot add a new child without descending, when no parent is available' unless current
      current.add_child(node_type, attributes)
    end
    
    def child_if_not_exist(node_type, attributes = {})
      (current ? current.children(node_type) {|c| __compare_node(c, attributes) }&.first : nil) || child(node_type, attributes)
    end
    
    ##
    # Adds a new child and sets the current stack pointer onto the newly created child
    def child!(node_type, attributes = {})
      new_child = if current
        child(node_type, attributes)
      else
        Mahuta::Node.new(nil, nil, node_type, attributes)
      end
      @result ||= new_child
      pin! new_child
      new_child
    end
    
    def child_or_descend!(node_type, attributes = {})
      c = (current ? current.children(node_type) {|c| __compare_node(c, attributes) }&.first : nil) || child!(node_type, attributes)
      pin! c
    end
    
    def |(visitor)
      result.deep_freeze! | visitor
    end
    
    def ascend(steps = 1)
      steps.times { pin! @current.parent }
    end
    
    private def __compare_node(node, attributes = {})
      node.attributes.reject {|k,v| k.to_s.start_with?('__') } == attributes
    end
    
    class TreeBuilder
      
      def initialize(tree)
        @tree = tree
        @current_node = tree
      end
      
    end
    
  end
  
end
