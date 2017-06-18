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
  
  context do
    let(:mod1) { Module.new { def test1 ; end } }
    let(:mod2) { Module.new { def test2 ; end } }
    subject { Mahuta::Schema.new(root: mod1) }
    
    it { expect(subject[:root]).to include(mod1) }
    
    context do
      
      it { expect(subject.new {}).to respond_to(:test1) }
    end
    
  end
  
end
