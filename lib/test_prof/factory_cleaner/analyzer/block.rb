# frozen_string_literal: true

module TestProf
  module FactoryCleaner
    class Analyzer
      class Block
        attr_reader :type, :location

        def initialize(type, location)
          @type = type
          @location = Location.new(*location)
        end

        class Let << Block
          def initialize(location)
            super(:let, location)
          end
        end

        class LetItBe
          def initialize(location)
            super(:let_it_be, location)
          end
        end

        class Before
          def initialize(location)
            super(:before, location)
          end
        end

        class After
          def initialize(location)
            super(:after, location)
          end
        end

        class It
          def initialize(location)
            super(:it, location)
          end
        end
      end
    end
  end
end
