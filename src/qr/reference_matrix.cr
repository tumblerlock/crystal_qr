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

    def render
      print "  "
      puts (0...@col_indices.size).map { |n| n % 10 }.join

      @row_indices.each_with_index do |row, i|
        print "#{i % 10} "
        @col_indices.each do |col|
          print @matrix.raw[row][col]
        end
        puts
      end
      puts
    end
  end
end
