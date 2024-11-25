require 'rubyserial'


radio1 = Serial.new('/dev/cu.usbmodem1101', 9600, 8, :none) # TH-D75
radio2 = Serial.new('/dev/cu.VR-N76', 9600, 8, :none)
#radio1 = Serial.new('/dev/cu.UV-PRO', 9600, 8, :none)

puts "Start receiving data from radio"
# Start receiving thread
Thread.new do
    while true
        begin
        data = radio2.getbyte
        unless data.nil?
            if data == 0xC0
                print "\n"
            end
            # display hex representation of data formatted as 0x00
            print "0x%02X," % data        
        end
        rescue Exception => e
        break
        end
    end
end

puts "Sending data to radio"
1..6.times do |i|
    payload = [0xC0, 0x00] + [i+1] * 16  + [0xC0]
    print "Sending payload number #{i+1}, written bytes: "
    puts radio1.write(payload.pack('C*'))
end

sleep(10)

puts "Closing serial ports"
radio1.close
radio2.close