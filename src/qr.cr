require "./qr/code"
require "./qr/matrix"

matrix = QR::Matrix(String).new size: 8 do |row, col|
  (row * col % 10).to_s
end

matrix.render
matrix[0..2][3] = "Y".colorize(:white).back(:dark_gray).to_s
matrix[0..2, 4..6][0..2, 4..6] = "B".colorize(:black).back(:light_gray).to_s
matrix.render

c = QR::Code.new
c.fill
