require "./qr/code"
require "./qr/matrix"

c = QR::Code.new
c.fill
c.print
