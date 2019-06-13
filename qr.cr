require "colorize"

class Matrix(T)
  def initialize(*, rows : Int32, cols : Int32, &block : (Int32, Int32) -> T)
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

  def [](*ranges)
    positions = [] of Int32

    ranges.each do |range|
      case range
      when Int
        positions << range
      when Range
        range.each do |position|
          positions << position
        end
      end
    end

    rows = Array(Array(T)).new(positions.size) do |i|
      @data[ positions[i] ]
    end

    MatrixSubSelector(T).new rows
  end

  def render
    print "  "
    puts (0...@data[0].size).map { |n| n % 10 }.join

    @data.each_with_index do |row, i|
      print "#{i % 10} "
      row.each_with_index do |cell, j|
        print cell
      end
      puts
    end
  end
end

class MatrixSubSelector(T)
  def initialize(@rows : Array(Array(T)))
  end

  def [](*ranges)
    positions = [] of Int32

    ranges.each do |range|
      case range
      when Int
        positions << range
      when Range
        range.each do |position|
          positions << position
        end
      end
    end

    Matrix(T).new(rows: @rows.size, cols: positions.size) do |row, col|
      @rows[row][ positions[col] ]
    end
  end
end

m = Matrix(String).new size: 8 do |row, col|
  (row * col % 10).to_s
end

m.render
puts
m[2..3, 5, 6..7][1..3].render

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
