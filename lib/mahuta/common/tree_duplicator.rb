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
  
  module TreeDuplicator
    
    def self.included(type)
      unless [ TreeProducer, Mahuta::Visitor ].all? {|mod| type.ancestors.include?(mod) }
        warn 'TreeDuplicator needs features from Mahuta::Visitor and TreeProducer, be sure to include it'
      end
    end
    
    def enter(node, depth)
      return :stop if super == :stop
      apply(node, current)
    end
    
    def leave(node, depth)
      apply_after(node, current)
    end
    
    def transform(source)
      method_name = "transform_#{source.node_type}"
      if respond_to?(method_name)
        send method_name, source
      else
        copy_node!(source)
      end
    end
    
    def apply(source, target)
      method_name = "apply_#{source.node_type}"
      if respond_to?(method_name)
        # Refactor that to one line
        case method(method_name).arity
        when 0
          send method_name
        when 1
          send method_name, source
        when 2
          send method_name, source, target
        end
      end
    end
    
    def apply_after(source, target)
      method_name = "apply_after_#{source.node_type}"
      if respond_to?(method_name)
        # Refactor that to one line
        case method(method_name).arity
        when 0
          send method_name
        when 1
          send method_name, source
        when 2
          send method_name, source, target
        end
      end
    end
    
  end
  
end
