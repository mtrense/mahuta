
require 'mahuta'

schema = Mahuta::Schema.define do
  
  type :namespace do
    
    def namespace!(*names, &block)
      add_child :namespace, name: names, &block
    end
    
    def type!(name, &block)
      add_child :type, name: name, &block
    end
    
  end
  
  type :root, self[:namespace]
  
  type :type do
    
    def property!(name, type, &block)
      add_child :property, name: name, type: type
    end
    
  end 
  
  type :property do
    
  end
  
end

#########################################################

tree = Mahuta.build schema do
  namespace! :com, :example do
    type! :Person do
      property! :given_name, :string
      property! :family_name, :string
      property! :date_of_birth, :date
    end
  end
end

#########################################################

class JavaPrinter
  include Mahuta::Visitor
  
  def initialize
    @files = {}
  end
  
  def enter_namespace(node, depth)
    puts "package #{node[:name].join('.')};"
  end
  
  def enter_type(node, depth)
    puts
    puts "public class #{node[:name]} {"
    puts
  end
  
  def enter_property(node, depth)
    puts "\tprotected #{node[:type]} #{node[:name]};"
  end
  
  def leave_type(node, depth)
    puts
    puts "}"
    puts
  end
  
end

tree.traverse JavaPrinter.new

# binding.pry
