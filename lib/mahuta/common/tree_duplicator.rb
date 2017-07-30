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
      if transform?(node)
        transform(node)
        apply(node, top)
      end
    end
    
    def transform?(source)
      true
    end
    
    def transform(source)
      if respond_to?("transform_#{source.node_type}")
        send "transform_#{source.node_type}", source
      else
        copy_node(source)
      end
    end
    
    def copy_node(source)
      child! source.node_type, source.attributes.merge({ __location: source })
      if source.has_schema?
        top.instance_variable_set(:@schema, source.instance_variable_get(:@schema))
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
    
    def leave(node, depth)
      super
      ascend
    end
    
  end
  
end
