require "colorize"

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

  def initialize()
    @data = Array(Array(String)).new(21) do
      Array(String).new(21) { "" }
    end
  end

  def fill
    (0..20).each do |row|
      (0..20).each do |col|
        value = OFF

        case
        # outer guides
        when [0,6].includes?(row) && col >= 14
          value = ALIGNMENT
        when [14,20].includes?(row) && (col >= 14 || col <= 6)
          value = ALIGNMENT
        when [14,20].includes?(col) && (row >= 14 || row <= 6)
          value = ALIGNMENT
        when row >= 14 && [6,0].includes? col
          value = ALIGNMENT

        # inner guides
        when 16 <= col <= 18 && (2 <= row <= 4 || 16 <= row <= 18)
          value = ALIGNMENT
        when 2 <= col <= 4 && 16 <= row <= 18
          value = ALIGNMENT

        # timing
        when row == 14 && 8 <= col <= 12
          if col % 2 == 1
            value = OFF
          else
            value = TIMING
          end
        when col == 14 && 8 <= row <= 12
          if row % 2 == 1
            value = OFF
          else
            value = TIMING
          end
        when col == 12 && row == 7
          value = TIMING

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

        @data[row][col] = value
      end
    end
  end

  private def stream(position : Int) : String
    data = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-"
    data[position % data.size].to_s
  end

  def print
    data.each_with_index do |row, i|
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
c.print

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
