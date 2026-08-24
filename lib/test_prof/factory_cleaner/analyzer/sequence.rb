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
          @options = params[:options] || {}
          @associations = {}
        end

        def association(params)
          params[:definition] = nil if params[:definition] == @definition
          @associations[params[:name]] = Factory.new(parent: self, **params)
        end

        def eql?(factory)
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

        def location
          @definition&.location
        end

        def inspect
          location = @definition&.location
          associations = @associations.map { |n, a| "#{n} => #{a.type}:#{a.location || 'n'}"  }.join(", ")
          options = @options.map { |n, o| "#{n} => #{o.type}:#{o.location}" }.join(", ")

          "factory (#{@name}, #{location}, #{associations}, #{options})"
        end

        def type
          "f"
        end
      end

      class Definition
        attr_reader :parent, :name

        def initialize(params)
          @name = params[:name]
          @file_path, @line_number = params[:location]
          @parent = params[:parent]

          @dependencies = {}
        end

        def dependency(params)
          @dependencies[params[:name]] = Definition.new(parent: self, **params)
        end

        def location
          "#{@file_path}:#{@line_number}"
        end

        def eql?(definition)
          definition.is_a?(Definition) && definition.location == location
        end

        def ==(definition)
          eql?(definition)
        end

        def hash
          @name.hash
        end

        def inspect
          "definition (#{@name}, #{location})"
        end

        def type
          "d"
        end
      end

      class Set
        include Enumerable

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
