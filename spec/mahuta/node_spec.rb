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
  
  context 'A single node with attributes' do
    let(:root) do
      Mahuta::Node.new nil, SPEC_SAMPLE_SCHEMA, :root, test1: true, test2: 123, test3: [:a, :b, :c]
    end
    subject { root }
    
    it('should have no parent') { expect(subject.parent).to be_nil }
    it('should have no children') { expect(subject.children).to be_empty }
    it('should be leaf') { expect(subject).to be_leaf }
    it('should be root') { expect(subject).to be_root }
    it('should be its own root') { expect(subject.root).to equal(subject) }
    it('should have no ascendants') { expect(subject.ascendants).to be_empty }
    it('should have no ascendants') { expect(subject.ascendant).to be_nil }
    it('should have no descendants') { expect(subject.descendants).to be_empty }
    it('should have no descendants') { expect(subject.descendant).to be_nil }
    
    it { expect(subject[:test1]).to equal(true) }
    it { expect(subject[:test2]).to equal(123) }
    it { expect(subject[:test3]).to contain_exactly(:a, :b, :c) }
    it { expect(subject.test1).to equal(true) }
    it { expect(subject.test2).to equal(123) }
    it { expect(subject.test3).to contain_exactly(:a, :b, :c) }
    
  end
  
  context 'A root node with one child node' do
    let(:root) do
      SPEC_SAMPLE_SCHEMA.new do
        one!
      end
    end
    let(:one) { root[0] }
    subject { root }
    
    it { expect(subject.children).not_to be_empty }
    it { expect(subject).to be_root }
    it { expect(subject).not_to be_leaf }
    
    it { expect(subject).to have_schema }
    it { expect(one).not_to have_schema }
    
    it('should have exactly one descendant') do
      expect(subject.descendants.length).to equal(1) 
      expect(subject.descendants.first).to equal(subject.descendant)
    end

    it('should have its child node as only descendant') { expect(subject.descendants).to contain_exactly(one) }
    
    it { expect(subject[0]).to equal(subject.children.first) }
    
    context 'Freezing' do
      before(:each) { root.freeze! }
      
      it { expect(root).to be_frozen }
      it { expect(root.attributes).to be_frozen }
      it { expect(root.children).to be_frozen }
      it { expect(one).not_to be_frozen }
      it { expect(one.attributes).not_to be_frozen }
      it { expect(one.children).not_to be_frozen }
      
    end
    
  end
  
  context 'A node with one parent' do
    let(:root) do
      SPEC_SAMPLE_SCHEMA.new do
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

    it('should have no descendants') { expect(subject.descendants).to be_empty }
    
  end
  
  context 'A hierarchy of three nodes' do
    let(:root) do
      SPEC_SAMPLE_SCHEMA.new do
        one! do
          two! do
            three!
          end
          one! do
            two!
          end
        end
      end
    end
    let(:one) { root[0] }
    let(:one_two) { one[0] }
    let(:one_two_three) { one_two[0] }
    let(:one_one) { one[1] }
    let(:one_one_two) { one_one[0] }
    
    it('#children filters children by node type') do
      expect(one.children(:two)).to contain_exactly(one_two)
    end
    it('#children filters children by multiple node types') do
      expect(one.children(:two, :one)).to contain_exactly(one_two, one_one)
    end
    it('#children filters children by result of the block') do
      expect(one.children {|n| n.node_type == :two }).to contain_exactly(one_two)
    end
    it('#children filters children by node type and result of the block') do
      expect(one.children(:one) {|n| n.node_type == :two }).to be_empty
    end
    
    it('#ascendants filters parent chain by node type') do
      expect(one_one_two.ascendants(:one)).to contain_exactly(one_one, one)
    end
    it('#ascendants filters parent chain by multiple node types') do
      expect(one_two_three.ascendants(:one, :two)).to contain_exactly(one, one_two)
    end
    it('#ascendant filters parent chain by node type') do
      expect(one_one_two.ascendant(:one)).to equal(one_one)
    end

    it('#descendants filters children tree by node type') do
      expect(root.descendants(:one)).to contain_exactly(one, one_one)
    end
    it('#descendants filters children tree by multiple node types') do
      expect(root.descendants(:one, :two)).to contain_exactly(one, one_two, one_one, one_one_two)
    end
    it('#descendant filters children_tree by node type') do
      expect(root.descendant(:one)).to equal(one)
      expect(root.descendant(:two)).to equal(one_two)
    end

    it('#is_first_child? is true for first child') do
      expect(one_two.is_first_child?).to equal(true)
    end

    it('#is_first_child? is false for other children') do
      expect(one_one.is_first_child?).to equal(false)
    end

    it('#is_last_child? is true for last child') do
      expect(one_one.is_last_child?).to equal(true)
    end

    it('#is_last_child? is false for other children') do
      expect(one_two.is_last_child?).to equal(false)
    end
    
    context 'Deep freezing' do
      before(:each) { one_two.deep_freeze! }
      
      it { expect(root).not_to be_frozen }
      it { expect(one).not_to be_frozen }
      it { expect(one_two).to be_frozen }
      it { expect(one_two_three).to be_frozen }
      it { expect(one_one).not_to be_frozen }
      it { expect(one_one_two).not_to be_frozen }
      
    end
    
    # context 'Traversing' do
    #   let(:traversal_order) do
    #     [
    #       [root, :enter, 0], 
    #       [one, :enter, 1], 
    #       [one_two, :enter, 2], 
    #       [one_two_three, :enter, 3], 
    #       [one_two_three, :leave, 3], 
    #       [one_two, :leave, 2], 
    #       [one_one, :enter, 2], 
    #       [one_one_two, :enter, 3], 
    #       [one_one_two, :leave, 3], 
    #       [one_one, :leave, 2], 
    #       [one, :leave, 1], 
    #       [root, :leave, 0]
    #     ]
    #   end
    #   
    #   it('traverse calls its block in the right order') do
    #     nodes = []
    #     root.traverse do |node, operation, depth|
    #       nodes << [node, operation, depth]
    #     end
    #     expect(nodes).to contain_exactly(*traversal_order)
    #   end
    #   
    #   it('traverse calls visitor in the right order') do
    #     nodes = []
    #     visitor = Object.new
    #     visitor.define_singleton_method :enter do |node, depth|
    #       nodes << [node, :enter, depth]
    #     end
    #     visitor.define_singleton_method :leave do |node, depth|
    #       nodes << [node, :leave, depth]
    #     end
    #     root.traverse visitor
    #     expect(nodes).to contain_exactly(*traversal_order)
    #   end
    #   
    # end
    
  end
  
end
