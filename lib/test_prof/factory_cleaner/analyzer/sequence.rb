# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Analyzer
      class Group
        attr_reader :parent

        def initialize(group, parent, level)
          @name = group&.fetch(:name)
          @location = group&.fetch(:location)
          @parent = parent
          @level = level
        end

        def inspect
          "group (#{name}, #{level})"
        end
      end

      class Example
        attr_reader :group

        def initialize(example, group, level)
          @name = example&.fetch(:name)
          @location = example&.fetch(:location)
          @group = group
          @level = level
        end

        def inspect
          "example (#{name}, #{level})"
        end
      end

      class Factory
        attr_reader :name, :parent, :definition, :options, :associations

        def initialize(params)
          @name = params[:name]
          @definition = params[:definition]
          @parent = params[:parent]
          @example = params[:example]

          @associations = {}
          @options = {}
        end

        def association(params)
          params[:definition] = nil if params[:definition] == @definition
          @associations[params[:name]] = Factory.new(parent: self, **params)
        end

        def option(name, definition)
          @options[name] = definition
        end

        def eql?(factory)
          if @name == factory.name
             ta = @associations.map { |n, a| "#{n} => #{a&.definition&.location&.join(':') || 'n'}"  }.join(", ")
             to = @options.map { |n, o| "#{n} => #{o.location.join(':')}"  }.join(", ")

             fa = factory.associations.map { |n, a| "#{n} => #{a&.definition&.location&.join(':') || 'n'}"  }.join(", ")
             fo = factory.options.map { |n, o| "#{n} => #{o.location.join(':')}"  }.join(", ")

             #puts "=== #{@name} ==="
             #puts "associations = #{ta} - #{fa}"
             #puts "options = #{to} - #{fo}"
          end

          factory.is_a?(Factory) &&
            @name == factory.name &&
            @definition.eql?(factory.definition) &&
            @associations.size == factory.associations.size &&
            @options.size == factory.options.size &&
            @associations.all? { |key, association| association.eql?(factory.associations[key]) } &&
            @options.all? { |key, option| option.eql?(factory.options[key]) }
        end

        def hash
          @name.hash
        end

        def inspect
          location = @definition&.location&.join(':')
          associations = @associations.map { |n, a| "#{n} => #{a&.definition&.location&.join(':') || 'n'}"  }.join(", ")
          options = @options.map { |n, o| "#{n} => #{o.location.join(':')}"  }.join(", ")

          "factory (#{@name}, #{location}, #{associations}, #{options})"
        end
      end

      class Let
        attr_reader :parent, :name, :location

        def initialize(params)
          @name = params[:name]
          @location = params[:location]
          @parent = params[:parent]

          @dependencies = {}
        end

        def dependency(params)
          @dependencies[params[:name]] = Let.new(parent: self, **params)
        end

        def eql?(let)
          let.is_a?(Let) && let.location == @location
        end

        def hash
          @name.hash
        end

        def inspect
          "let (#{@name}, #{@location.join(':')})"
        end
      end

      class Set
        def initialize
          @data = {}
        end

        def <<(item)
          @data[item] ||= 0
          @data[item] += 1
        end

        def each(&block)
          @data.each(&block)
        end

        def inspect
          @data
        end
      end
    end
  end
end
