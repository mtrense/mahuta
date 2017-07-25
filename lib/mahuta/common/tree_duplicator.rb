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
        warn 'TreeDuplicator needs features from Mahuta::Visitor and TreeProducer, be sure to include it before'
      end
    end
    
    def enter(node, depth)
      child! node.node_type, node.attributes
      if node.has_schema?
        top.instance_variable_set(:@schema, node.instance_variable_get(:@schema))
      end
    end
    
    def leave(node, depth)
      descend
    end
    
  end
  
end
