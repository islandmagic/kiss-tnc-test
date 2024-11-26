require 'rubyserial'

names = ['TH-D75', 'VR-N76']
radio1 = Serial.new('/dev/cu.usbmodem21201', 9600, 8, :none) # TH-D75
radio2 = Serial.new('/dev/cu.VR-N76', 9600, 8, :none)
#radio1 = Serial.new('/dev/cu.UV-PRO', 9600, 8, :none)

def radio_listener(radio)
    start_frame = false
    payload_size = 0
    while true
        begin
        data = radio.getbyte
        unless data.nil?
            print "0x%02X," % data

            if data == 0xC0
                start_frame = !start_frame
                if start_frame
                    payload_size = 0
                else
                    puts " payload: #{payload_size} bytes"
                end
            elsif data == 0x00
            else                
                payload_size += 1
            end
        end
        rescue Exception => e
        break
        end
    end
end

def radio_send_payload(radio, frames, payload_size)
    (1..frames).each do |i|
        payload = [0xC0, 0x00] + [i] * payload_size  + [0xC0]
        print "  Sending payload number #{i}, written bytes: "
        puts radio.write(payload.pack('C*'))
    end
end

puts "Start receiving data from radio 1"
Thread.new do
    radio_listener(radio1)
end

puts "Start receiving data from radio 2"
Thread.new do
    radio_listener(radio2)
end

[radio1, radio2].each do |radio|
    puts "="*30
    puts "Sending payloads via radio #{radio == radio1 ? 1 : 2} (#{names[radio == radio1 ? 0 : 1]})"
    puts "="*30
    (1..7).each do |i|
        puts "-"*30
        puts "#{i} frames back to back"
        puts "-"*30
        [16,32,64,128,255].each do |payload_size|
            puts "\nFrame payload size: #{payload_size} bytes"
            radio_send_payload(radio, i, payload_size)
            approximate_transmit_time = (i * (payload_size*10 / 1200.0) + 1.0).ceil
            puts "Waiting for #{approximate_transmit_time} seconds"
            sleep(approximate_transmit_time)
        end
    end
    # wait for user input to continue
    puts "Press ENTER to reverse the test"
    gets
end

sleep(10)

puts "Closing serial ports"
radio1.close
radio2.close