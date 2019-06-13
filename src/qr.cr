require "./qr/code"
require "./qr/matrix"

c = QR::Code.new

c.fill do |offset|
  data = "aabbccddeeffgghhiijjkkllmmnnooppqqrrssttuuvvwwxxyyzz"
  data = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-"
  data[offset % data.size].to_s
end

c.print
