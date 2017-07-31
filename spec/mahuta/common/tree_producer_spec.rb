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

RSpec.describe Mahuta::Common::TreeProducer do
  
  context 'A simple TreeProducer' do
    let(:producer) do
      Class.new.tap do |cl|
        cl.class_exec do
          include Mahuta::Visitor
          include Mahuta::Common::TreeProducer
          
          def enter(node, depth)
            child! :depth_counter, depth: depth
          end
          
        end
      end.new
    end
    let(:root) do
      SPEC_SAMPLE_SCHEMA.new do
        one! do
          two! do
            three!
          end
        end
        one! do
          two! do
            three!
          end
        end
      end
    end
    
    let(:result) do
      producer.traverse(root)
      producer.result
    end
    let(:one1) { result[0] }
    let(:one1_two) { one1[0] }
    let(:one1_two_three) { one1_two[0] }
    let(:one2) { result[1] }
    let(:one2_two) { one2[0] }
    let(:one2_two_three) { one2_two[1] }
    
    it { expect(result[:depth]).to be(0) }
    it { expect(one1[:depth]).to be(1) }
    it { expect(one1_two[:depth]).to be(2) }
    it { expect(one1_two_three[:depth]).to be(3) }
    it { expect(one1[:depth]).to be(1) }
    
  end
  
end
