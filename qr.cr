require "colorize"

module RangeUtils
  private def flatten_ranges(ranges : Array)
    flattened = [] of Int32

    ranges.each do |range|
      case range
      when Int
        flattened << range
      when Range
        range.each do |position|
          flattened << position
        end
      end
    end

    flattened
  end
end

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

m = Matrix(String).new size: 8 do |row, col|
  (row * col % 10).to_s
end

m.render
m[2..3, 5, 6..7].render
m[2].render
m[0..2].render
m[0..2][2..4].render
m[0..2][2] = "\e[37;47mY\e[0m"
m.render

class Code
  include Enumerable(Bool)

  WHITE = " ".colorize.back(:white).to_s
  YELLOW = " ".colorize.back(:yellow).to_s

  OFF = " "
  ALIGNMENT = WHITE
  FORMAT = " ".colorize.back(:red).to_s
  TIMING = " ".colorize.back(:magenta).to_s
  DATA = " ".colorize.back(:green).to_s

  getter data : Array(Array(String))
  # row, col

  def initialize()
    @data = Array(Array(String)).new(21) do
      Array(String).new(21) { OFF }
    end
  end

  def guide(x col, y row, size)
    max_col = col + size - 1
    max_row = row + size - 1

    (col..max_col).each do |i|
      @data[row][i] = ALIGNMENT
      @data[max_row][i] = ALIGNMENT
    end

    (row..max_row).each do |i|
      @data[i][col] = ALIGNMENT
      @data[i][max_col] = ALIGNMENT
    end

    col += 2
    row += 2
    size -= 4
    max_col = col + size - 1
    max_row = row + size - 1

    (row..max_row).each do |i|
      (col..max_col).each do |j|
        @data[i][j] = ALIGNMENT
      end
    end
  end

  def timing
    @data[7][12] = TIMING

    @data[ 8][14] = TIMING
    @data[10][14] = TIMING
    @data[12][14] = TIMING

    @data[14][ 8] = TIMING
    @data[14][10] = TIMING
    @data[14][12] = TIMING
  end

  def format
    @data[12][0..7, 12..20].map do
      next_value
    end

    @data[0..6, 12..13, 15..20][12]
  end

  def fill
    guide(x: 14, y: 0, size: 7)
    guide(x: 14, y: 14, size: 7)
    guide(x: 0, y: 14, size: 7)

    timing

    (0..20).each do |row|
      (0..20).each do |col|
        value = OFF

        case
        # format
        when col == 12 && (row <= 6 || row == 13 || row >= 15)
          value = FORMAT
        when row == 12 && (col <= 7 || 12 <= col <= 13 || col >= 15)
          value = FORMAT

        # data
        when 0 <= row <= 11 && [0,1,4,5].includes? col
          offset = col / 2 * 24
          offset += row * 2 + (col % 2)

          value = stream(offset).colorize(:green).to_s

        when 0 <= row <= 11 && [2,3,6,7].includes? col
          offset = col / 2 * 24 - 2
          offset += (12 - row) * 2 + (col % 2)

          value = stream(offset).colorize(:cyan).to_s

        when (0 <= row <= 13 || row >= 15) && [8,9].includes? col
          offset = 96
          offset += row * 2 + (col % 2)
          offset -= 2 if row >= 15

          value = stream(offset).colorize(:green).to_s

        when (0 <= row <= 13 || row >= 15) && [10,11].includes? col
          offset = 134
          offset += (21 - row) * 2 + (col % 2)
          offset -= 2 if row <= 13

          value = stream(offset).colorize(:cyan).to_s

        when 8 <= row <= 12 && 12 <= col <= 13
          offset = 176
          offset += (row - 8) * 2 + (col % 2)

          value = stream(offset).colorize(:green).to_s

        when 8 <= row <= 12 && [15,16,19,20].includes? col
          offset = 182
          offset += 16 if col >= 19
          offset += (12 - row) * 2 + ((col + 1) % 2)

          value = stream(offset).colorize(:cyan).to_s

        when 8 <= row <= 12 && [17,18].includes? col
          offset = 192
          offset += (row - 8) * 2 + ((col + 1) % 2)

          value = stream(offset).colorize(:green).to_s

        end

        @data[row][col] = value unless value == OFF
      end
    end
  end

  private def stream(position : Int) : String
    data = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-"
    data = "aabbccddeeffgghhiijjkkllmmnnooppqqrrssttuuvvwwxxyyzz"
    data[position % data.size].to_s
  end

  def print
    puts "  012345678901234567890"
    data.each_with_index do |row, i|
      print "#{i % 10} "
      row.each_with_index do |cell, j|
        print cell
      end
      puts
    end
  end

  def print_upright
    puts "012345678901234567890"
    data.reverse.each_with_index do |row, i|
      row.reverse.each_with_index do |cell, j|
        print cell
      end
      puts
    end
  end
end

c = Code.new
c.fill

# data = [[] of Int32]
# data[0] << 1
# 
# 
# data.each do |row|
#   row.each do |character|
#     if character == 1
#       print ON
#     else
#       print OFF
#     end
#     # print " "
#   end
#   print "\n"
# end
