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

RSpec.describe Mahuta::Visitor do
  
  #
  # No spies here, they always create methods with arity -1, which is tested 
  # against in Visitor. But using varargs is not the common use case here...
  # 
  subject do
    Class.new.tap do |cl|
      cl.class_exec do
        include Mahuta::Visitor
        def enter_root(node, depth)
          @captured_enter = [node, depth]
        end
        def leave_root(node, depth)
          @captured_leave = [node]
        end
        attr_reader :captured_enter, :captured_leave
      end
    end.new
  end
  
  it do
    node = Object.new
    def node.node_type
      :root
    end
    subject.enter(node, 0)
    subject.leave(node, 0)
    expect(subject.captured_enter).to contain_exactly(node, 0)
    expect(subject.captured_leave).to contain_exactly(node)
  end
  
end
