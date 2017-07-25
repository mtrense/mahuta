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
        warn 'TreeProducer needs features from Mahuta::Visitor, be sure to include it before'
      end
    end
    
    def initialize(options = {})
      @result = options.delete(:result)
      @stack = [ *@result ]
      super
    end
    
    attr_reader :result
    
    def top
      @stack.last
    end
    
    def child(node_type, attributes = {})
      raise 'Cannot add a new child without descending, when no parent is available' unless top
      top.add_child(node_type, attributes)
    end
    
    def child!(node_type, attributes = {})
      new_child = unless @stack.empty?
        child(node_type, attributes)
      else
        Mahuta::Node.new(nil, nil, :node_type, attributes)
      end
      @result ||= new_child
      @stack.push new_child
      new_child
    end
    
    def |(visitor)
      result.deep_freeze! | visitor
    end
    
    def ascend(steps = 1)
      @stack.pop(steps)
    end
    
  end
  
end
