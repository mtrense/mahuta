require 'pastel'

module Mahuta::Utils
  
  class DupeChecker
    include Mahuta::Visitor
    
    P = Pastel.new
    
    def initialize(options = {}, &filter_block)
      @out = options[:out] || $stdout
      @filter = filter_block || Proc.new { true }
      @dupe_found = false
    end

    def dupe_found
      @dupe_found
    end

    def find_dupes(node) 
      return [] if node.node_type == :root
      node.parent.children.select do |sibling|
        sibling != node && sibling[:name] == node[:name] && sibling.node_type == node.node_type
      end
    end

    def node_path(node)
      [*node.ascendants.reverse.collect(&method(:format_node_meta)), format_node_meta(node)].join(' -> ')
    end

    def format_node_meta(node)
      P.underline(node[:name]) + ':' + P.cyan(node.node_type.to_s)
    end

    def format_node_attrs(node, indent = '')
      node.attributes.collect {|key, value|
        P.magenta(key) + ' = ' + P.white.bold(value) 
      }.join("\n" + indent)
    end
    
    def enter(node, depth)
      dupes = find_dupes(node)
      if !dupes.empty? && @filter.call(node)
        @dupe_found = true
        @out.puts "Found duplicate definitions of" + P.bold(node_path(node))
        dupes.each do |dupe|
          @out.puts '    ' + format_node_meta(node)
          @out.puts '    '*2 + format_node_attrs(node, '    '*2)
        end
      end
    end
    
  end
  
end
