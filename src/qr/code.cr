require "colorize"

require "./matrix"

module QR
  class Code

    WHITE = " ".colorize.back(:white).to_s
    YELLOW = " ".colorize.back(:yellow).to_s

    OFF = " "
    ALIGNMENT = WHITE
    FORMAT = " ".colorize.back(:red).to_s
    TIMING = " ".colorize.back(:magenta).to_s
    DATA = " ".colorize.back(:green).to_s

    getter data : Matrix(String)
    # row, col

    def initialize()
      @data = Matrix.new size: 21, default_value: OFF
    end

    def guide(x col, y row, size)
      max_col = col + size - 1
      max_row = row + size - 1

      @data[row..max_row][col, max_col] = ALIGNMENT
      @data[row, max_row][col..max_col] = ALIGNMENT

      col += 2
      row += 2
      size -= 4
      max_col = col + size - 1
      max_row = row + size - 1
      @data[row..max_row][col..max_col] = ALIGNMENT
    end

    def timing
      @data[7][12] = TIMING
      @data[8,10,12][14] = TIMING
      @data[14][8,10,12] = TIMING
    end

    def format
      @data[12][0..7, 12..13, 15..20] = FORMAT
      @data[0..6, 12..13, 15..20][12] = FORMAT
    end

    def fill_data(&block : Int32 -> String)
      @data[0..11][0..1].map(:tb_lr) do |value, offset, row, col|
        yield offset
      end

      @data[0..11][2..3].map(:bt_lr) do |value, offset, row, col|
        yield offset + 24
      end

      @data[0..11][4..5].map(:tb_lr) do |value, offset, row, col|
        yield offset + 48
      end

      @data[0..11][6..7].map(:bt_lr) do |value, offset, row, col|
        yield offset + 72
      end

      @data[0..13, 15..20][8..9].map(:tb_lr) do |value, offset, row, col|
        yield offset + 96
      end

      @data[0..13, 15..20][10..11].map(:bt_lr) do |value, offset, row, col|
        yield offset + 136
      end

      @data[8..11][12..13].map(:tb_lr) do |value, offset, row, col|
        yield offset + 176
      end

      @data[8..11][15..16].map(:bt_lr) do |value, offset, row, col|
        yield offset + 184
      end

      @data[8..11][17..18].map(:tb_lr) do |value, offset, row, col|
        yield offset + 192
      end

      @data[8..11][19..20].map(:bt_lr) do |value, offset, row, col|
        yield offset + 200
      end
    end

    def fill(&block : Int32 -> String)
      guide(x: 14, y: 0, size: 7)
      guide(x: 14, y: 14, size: 7)
      guide(x: 0, y: 14, size: 7)

      format
      timing

      fill_data do |offset|
        yield offset
      end
    end

    def print
      data.render
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
end
