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
  
  class Node
    
    def initialize(parent, schema, type, attributes = {}, &block)
      @parent = parent
      @schema = schema
      @attributes = attributes
      @node_type = type
      [*self.schema[@node_type]].each do |type|
        case type
        when Module
          extend type
        end
      end
      @children = []
      instance_exec &block if block
    end
    
    attr_reader :parent, :node_type, :children, :attributes
    alias :a :attributes
    alias :c :children
    
    def children(*of_type, &block)
      __filter_node_list(@children, *of_type, &block)
    end
    
    def root
      root? ? self : parent.root
    end
    
    def ascendant(*of_type, &block)
      ascendants(*of_type, &block).first
    end
    
    ##
    # Gathers all ascendants that match the given criteria.
    # Criteria can be given as array of types (of which one must match) or as 
    # block which is executed with the ascendant as argument.
    def ascendants(*of_type, &block)
      if root?
        []
      else
        __filter_node_list([parent] + parent.ascendants, *of_type, &block)
      end
    end

    def descendant(*of_type, &block)
      descendants(*of_type, &block).first
    end

    ##
    # Gathers all descendants that match the given criteria, works like the ascendants method in all other aspects.
    def descendants(*of_type, &block)
      if leaf?
        []
      else
        __filter_node_list(children + children.collect_concat {|child| child.descendants}, *of_type, &block)
      end
    end
    
    def has_schema?
      !! @schema
    end
    
    def schema
      @schema || (parent ? parent.schema : {})
    end
    
    def [](name)
      case name
      when Symbol
        attributes[name]
      when String
        
      when Integer, Range
        children[name]
      end
    end
    
    def root?
      parent.nil?
    end
    
    def leaf?
      children.empty?
    end
    
    def method_missing(name, *args, &block)
      if attributes.include?(name) and args.empty? and block.nil?
        attributes[name]
      else
        super(name, *args, &block)
      end
    end

    def respond_to?(what) 
      super || attributes.include?(what)
    end
    
    def add_child(node_type, attributes = {}, &block)
      location_hash = if location = __defining_location
        { path: location.path, lineno: location.lineno }
      end
      Node.new(self, nil, node_type, { __location: location_hash }.merge(attributes), &block).tap do |node|
        children << node
      end
    end
    
    def deep_freeze!
      freeze!
      children.each(&:freeze!)
      self
    end
    
    def freeze!
      @node_type.freeze
      @attributes.freeze
      @attributes.each {|k, v| k.freeze; v.freeze }
      @children.freeze
      freeze
      self
    end
    
    def |(visitor)
      visitor.traverse(self)
      visitor
    end
    
    def inspect
      "[Node:#{node_type}#{self[:name] ? " name=#{self[:name]}" : ''}]"
    end
    
    private def __defining_location
      if loc = Thread.current[:mahuta_locations]&.last
        caller_locations.select {|l| l.absolute_path == loc }.first
      end
    end
    
    private def __filter_node_list(nodes, *of_type, &block)
      if not block and of_type.empty?
        nodes
      else
        nodes.select do |n|
          (of_type.empty? or of_type.include?(n.node_type)) and (not block or block.call(n))
        end
      end
    end

    def is_last_child? 
      parent.children.last == self
    end

    def is_first_child? 
      parent.children.first == self
    end
    
  end
  
end
