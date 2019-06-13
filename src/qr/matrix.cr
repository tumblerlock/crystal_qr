require "./matrix/range_utils"
require "./reference_matrix"

module QR
  class Matrix(T)
    include RangeUtils

    getter rows, cols

    def initialize(*, @rows : Int32, @cols : Int32, &block : (Int32, Int32) -> T)
      @data = Array(Array(T)).new(rows) do |row|
        Array(T).new(cols) do |col|
          yield row, col
        end
      end
    end

    def initialize(*, size : Int32, default_value : T)
      initialize rows: size, cols: size do |row, col|
        default_value
      end
    end

    def initialize(*, size : Int32, &block : (Int32, Int32) -> T)
      initialize(rows: size, cols: size, &block)
    end

    def raw
      @data
    end

    def [](*ranges)
      positions = flatten_ranges ranges.to_a
      ReferenceMatrix(T).new self, rows: positions
    end

    def []=(*val)
      {% raise "Cannot implicitly assign a value to all columns for a rowset" %}
    end

    def render
      ReferenceMatrix(T).new(self).render
    end
  end
end
