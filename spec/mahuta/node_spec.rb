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
        def one!(attributes = {}, &block)
          add_child(:one, attributes, &block)
        end
      end
      type :one do
        def one!(attributes = {}, &block)
          add_child(:one, attributes, &block)
        end
        def two!(attributes = {}, &block)
          add_child(:two, attributes, &block)
        end
      end
      type :two do
        def three!(attributes = {}, &block)
          add_child(:three, attributes, &block)
        end
      end
    end
  end
  
  context 'A single node with attributes' do
    subject do
      Mahuta::Node.new nil, schema, :root, test1: true, test2: 123, test3: [:a, :b, :c]
    end
    
    it('should have no parent') { expect(subject.parent).to be_nil }
    it('should have no children') { expect(subject.children).to be_empty }
    it('should be leaf') { expect(subject).to be_leaf }
    it('should be root') { expect(subject).to be_root }
    it('should be its own root') { expect(subject.root).to equal(subject) }
    it('should have no ascendants') { expect(subject.ascendants).to be_empty }
    it('should have no ascendants') { expect(subject.ascendant).to be_nil }
    
    it { expect(subject[:test1]).to equal(true) }
    it { expect(subject[:test2]).to equal(123) }
    it { expect(subject[:test3]).to contain_exactly(:a, :b, :c) }
    it { expect(subject.test1).to equal(true) }
    it { expect(subject.test2).to equal(123) }
    it { expect(subject.test3).to contain_exactly(:a, :b, :c) }
    
  end
  
  context 'A root node with one child node' do
    let(:root) do
      schema.new do
        one!
      end
    end
    let(:one) { root[0] }
    subject { root }
    
    it { expect(subject.children).not_to be_empty }
    it { expect(subject).to be_root }
    it { expect(subject).not_to be_leaf }
    
    it { expect(subject[0]).to equal(subject.children.first) }
    
  end
  
  context 'A node with one parent' do
    let(:root) do
      schema.new do
        one!
      end
    end
    let(:one) { root[0] }
    subject { one }
    
    it { expect(subject.children).to be_empty }
    it { expect(subject).not_to be_root }
    it { expect(subject).to be_leaf }
    
    it('should have one ascendant') { expect(subject.ascendants).to contain_exactly(root) }
    it('should have one ascendant') { expect(subject.ascendant).to equal(root) }
    
  end
  
  context 'A hierarchy of three nodes' do
    let(:root) do
      schema.new do
        one! do
          two!
          one! do
            two!
          end
        end
      end
    end
    let(:one) { root[0] }
    let(:one_two) { one[0] }
    let(:one_one) { one[1] }
    let(:one_one_two) { one[1][0] }
    
    it { expect(one.children(:two)).to contain_exactly(one_two) }
    it { expect(one.children {|n| n.node_type == :two }).to contain_exactly(one_two) }
    it { expect(one.children(:one) {|n| n.node_type == :two }).to be_empty }
    
    it { expect(one_one_two.ascendants(:one)).to contain_exactly(one_one, one) }
    it { expect(one_one_two.ascendant(:one)).to equal(one_one) }
    
    context 'Traversing' do
      
      
    end
    
  end
  
end
