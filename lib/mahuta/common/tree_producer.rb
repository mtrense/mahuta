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
      @current = @result
      super
    end
    
    attr_reader :result, :current
    
    private def __traverse_subtree(node, depth)
      last = current
      begin
        enter(node, depth)
        node.children.each do |child|
          __traverse_subtree(child, depth + 1)
        end
        leave(node, depth)
      ensure
        @current = last
      end
    end

    def enter(node, depth)
      if transform?(node)
        transform(node)
      end
    end
    
    def transform?(source)
      true
    end
    
    def transform(source)
      if respond_to?("transform_#{source.node_type}")
        send "transform_#{source.node_type}", source
      end
    end
    
    def copy_node!(source)
      child! source.node_type, source.attributes.merge({ __location: source })
      if source.has_schema?
        current.instance_variable_set(:@schema, source.instance_variable_get(:@schema))
      end
    end
    
    ##
    # Adds a new child and leaves the current stack pointer on the current node
    def child(node_type, attributes = {})
      raise 'Cannot add a new child without descending, when no parent is available' unless current
      current.add_child(node_type, attributes)
    end
    
    def child_if_not_exist(node_type, attributes = {})
      (@current ? current.children(node_type) {|c| __compare_node(c, attributes) }&.first : nil) || child(node_type, attributes)
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
      @current = new_child
      new_child
    end
    
    def child_or_descend!(node_type, attributes = {})
      c = (current ? current.children(node_type) {|c| __compare_node(c, attributes) }&.first : nil) || child!(node_type, attributes)
      @current = c
    end
    
    def |(visitor)
      result.deep_freeze! | visitor
    end
    
    def ascend(steps = 1)
      steps.times { @current = @current.parent }
    end
    
    private def __compare_node(node, attributes = {})
      node.attributes.reject {|k,v| k.to_s.start_with?('__') } == attributes
    end
    
  end
  
end
