
require 'active_support'
require 'active_support/core_ext'
require 'mahuta'

module Namespace
  
  def namespace!(*names, &block)
    add_child :namespace, name: names, &block
  end
  
  def type!(name, &block)
    add_child :type, name: name, &block
  end
  
end

module Type
  
  def namespace
   parent[:name]
  end
  
  def property!(name, type, &block)
    add_child :property, name: name, type: type
  end
  
end

module Property
  
end

schema = Mahuta::Schema.new(
  root: Namespace, 
  namespace: Namespace,
  type: Type,
  property: Property
)

#########################################################

tree = Mahuta.build schema do
  namespace! :com, :example do
    namespace! :test do
      type! :Person do
        property! :given_name, :string
        property! :family_name, :string
        property! :date_of_birth, :date
      end
    end
  end
end

#########################################################

class JavaPrinter
  include Mahuta::Visitor
  
  def initialize
    @files = {}
  end
  
  def to_java_variable(name)
    name.to_s.camelize(:lower)
  end
  
  def java_type(type)
    case type
    when :string
      'String'
    when :date
      'Date'
    end
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
    puts "\tprotected #{java_type(node[:type])} #{to_java_variable(node[:name])};"
  end
  
  def leave_type(node, depth)
    puts
    puts "}"
    puts
  end
  
end

tree.traverse JavaPrinter.new

binding.pry
