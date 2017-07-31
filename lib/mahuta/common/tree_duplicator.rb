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
    
    def leave(node, depth)
      if transform?(node)
        apply_after(node, current)
      end
    end
    
    def enter(node, depth)
      super
      if transform?(node)
        apply(node, current)
      end
    end
    
    def transform(source)
      if respond_to?("transform_#{source.node_type}")
        send "transform_#{source.node_type}", source
      else
        copy_node!(source)
      end
    end
    
    def apply(source, target)
      if respond_to?("apply_#{source.node_type}")
        case method("apply_#{source.node_type}").arity
        when 0
          send "apply_#{source.node_type}"
        when 1
          send "apply_#{source.node_type}", source
        when 2
          send "apply_#{source.node_type}", source, target
        end
      end
    end
    
    def apply_after(source, target)
      if respond_to?("apply_after_#{source.node_type}")
        case method("apply_after_#{source.node_type}").arity
        when 0
          send "apply_after_#{source.node_type}"
        when 1
          send "apply_after_#{source.node_type}", source
        when 2
          send "apply_after_#{source.node_type}", source, target
        end
      end
    end
    
  end
  
end
