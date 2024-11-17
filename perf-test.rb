require 'rubyserial'

radio2 = Serial.new('/dev/cu.usbmodem101', 9600, 8, :none) # TH-D75
#radio2 = Serial.new('/dev/cu.VR-N76', 9600, 8, :none)
radio1 = Serial.new('/dev/cu.UV-PRO', 9600, 8, :none)

puts "Start receiving data from radio"
# Start receiving thread
Thread.new do
    while true
        begin
        data = radio2.getbyte
        unless data.nil?
            # display hex representation of data formatted as 0x00
            puts "0x%02X" % data        
        end
        rescue Exception => e
        break
        end
    end
end

puts "Sending data to radio"
radio1.write("\xC0\x00\x01\x01\x01\x01\x01\x01\x01\x01\xC0")
radio1.write("\xC0\x00\x02\x02\x02\x02\x02\x02\x02\x02\xC0")
radio1.write("\xC0\x00\x03\x03\x03\x03\x03\x03\x03\x03\xC0")
radio1.write("\xC0\x00\x04\x04\x04\x04\x04\x04\x04\x04\xC0")

sleep(5)

puts "Closing serial ports"
radio1.close
radio2.close