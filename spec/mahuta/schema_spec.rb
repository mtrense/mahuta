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

RSpec.describe Mahuta::Schema do
  
  let :mod1 do
    Module.new do
      def test1 ; end
      def type2! ; add_child(:type2) ; end
    end
  end
  let :mod2 do
    Module.new do
      def test2 ; end
    end
  end
  
  context 'A schema with two node types' do
    subject { Mahuta::Schema.new(root: mod1, type2: mod2) }
    
    it('should include Module 1 for type :root') { expect(subject[:root]).to include(mod1) }
    it('should include Module 2 for type :type2') { expect(subject[:type2]).to include(mod2) }
    
    context 'An instance of the schema' do
      
      it { expect(subject.new {}).to respond_to(:test1) }
      it { expect(subject.new {}).not_to respond_to(:test2) }
      
    end
    
    context 'A schema defined with a block' do
      subject do
        Mahuta::Schema.new do
          type :root
        end
      end
      
      it('should have a type defined') { expect(subject[:root]).to be }
      
    end
    
  end
  
end
