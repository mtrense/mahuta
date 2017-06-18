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

RSpec.describe Mahuta::Node do
  
  let :schema do
    Mahuta::Schema.new do
      type :root do
        def test_node!(&block)
          add_child(:test_node, &block)
        end
      end
      type :test_node do
        def test_node!(&block)
          add_child(:test_node, &block)
        end
      end
    end
  end
  
  context 'A single node' do
    subject do
      Mahuta::Node.new nil, schema, :root
    end
    
    it('should have no parent') { expect(subject.parent).to be_nil }
    it('should have no children') { expect(subject.children).to be_empty }
    it('should be leaf') { expect(subject.leaf?).to be_truthy }
    it('should be root') { expect(subject.root?).to be_truthy }
    
  end
  
  context 'A root node with one child node' do
    subject do
      puts " >> #{schema.inspect} <<"
      schema.new do
        test_node!
      end
    end
    
    it { expect(subject.children).not_to be_empty }
    
  end
  
end
