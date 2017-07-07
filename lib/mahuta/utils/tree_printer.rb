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

require 'pastel'

module Mahuta::Utils
  
  class TreePrinter
    include Mahuta::Visitor
    
    P = Pastel.new
    
    SIMPLE_FORMAT = proc do |node, depth|
      attrs = node.attributes.collect {|n, v| "#{n}=#{v.inspect}" }
      '  '*depth + (node.leaf? ? '-' : '+') + " [#{node.node_type}] #{attrs.join(' ')}"
    end
    
    EXTENDED_COLORIZED_FORMAT = proc do |node, depth|
      attrs = node.attributes.collect {|n, v| "#{P.underline(n)}=#{P.bright_blue(v.inspect)}" }
      '  '*depth + P.bold(node.leaf? ? '-' : '+') + " [#{P.bold.yellow(node.node_type.to_s)}] " + attrs.join(' ')
    end
    
    def initialize(options = {})
      @out = options[:out] || $stdout
      @format = options[:format] || EXTENDED_COLORIZED_FORMAT
    end
    
    def enter(node, depth)
      @out.puts @format.call(node, depth)
    end
    
  end
  
end
