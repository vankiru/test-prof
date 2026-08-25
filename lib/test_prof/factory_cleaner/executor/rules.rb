# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Planner
      class Rule
        def initialize(type)
          @type = type
        end
      end

      # change create to create_default
      class CreateDefaultRule < Rule
        def initialize(location)
          @location = location
        end
      end

      # change let to let_it_be
      class LetItBeRule < Rule
        def initialize(location)
          @location = location
        end
      end

      # copy definition and delete it
      class ExtractDefinitionRule < Rule
        def initialize(location)
          @location = location
        end
      end

      # copy definition
      class CopyDefinitionRule < Rule
        def initialize(location)
          @location = location
        end
      end

      # delete definition
      class DeleteDefinitionRule < Rule
        def initialize(location)
          @location = location
        end
      end

      class BuildDefinitionRule < Rule
        def initialize(factory)
          @factory = factory
        end
      end

      class InsertDefinitionsRule < Rule
        def initialize(rules)
          @rules = ruls
        end
      end

      class JoinDefinitionsRule < GroupRule
      end

      class GroupRule < Rule
        def initialize(rules)
          @rules = ruls
        end
      end
    end
  end
end
