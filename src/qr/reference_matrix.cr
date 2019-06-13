module QR
  class ReferenceMatrix(T)
    include RangeUtils

    def initialize(
      @matrix : Matrix(T),
      * ,
      rows @row_indices : Array(Int32) = [] of Int32,
      cols @col_indices : Array(Int32) = [] of Int32
    )
      @row_indices = (0...@matrix.rows).to_a if @row_indices.empty?
      @col_indices = (0...@matrix.cols).to_a if @col_indices.empty?
    end

    def [](*ranges)
      self.class.new(
        @matrix,
        rows: @row_indices,
        cols: flatten_ranges(ranges.to_a)
      )
    end

    def []=(*ranges)
      value = ranges.last
      cols = flatten_ranges ranges.to_a[0...-1]

      @row_indices.each do |row|
        cols.each do |col|
          @matrix.raw[row][col] = value
        end
      end
    end

    def each(direction : Symbol, &block : T, Int32, Int32, Int32 -> Nil)
      iterable_rows = @row_indices
      iterable_rows.reverse! if [:bt_lr, :bt_rl].includes? direction

      iterable_cols = @col_indices
      iterable_cols.reverse! if [:tb_rl, :bt_rl].includes? direction

      counter = 0

      iterable_rows.each do |row|
        iterable_cols.each do |col|
          yield @matrix.raw[row][col], counter, row, col
          counter += 1
        end
      end
    end

    def map(direction : Symbol, &block : T, Int32, Int32, Int32 -> T)
      each direction do |value, counter, row, col|
        @matrix.raw[row][col] = yield value, counter, row, col
      end
    end

    def render
      print "  "
      print (0...@col_indices.size).map { |n| n % 10 }.join

      each :tb_lr do |val, _, row, col|
        print "\n#{row % 10} " if col == 0
        print val
      end
    end
  end
end
