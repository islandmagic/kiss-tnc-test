# KISS TNC Test

This simple program assists in testing the sending and receiving of arbitrary data via a KISS TNC interface. It was created to help isolate potential performance problems encountered with the UV-PRO and VR-N76 radios as they begin exposing their internal TNC via a KISS Bluetooth interface. Both radios behave similarly, likely due to sharing similar firmware.

The firmware for both radios was updated to the latest beta version, 0.7.10-32.

The setup uses a TH-D75 as one of the radios, considering its internal TNC as a reference.

Here are the various scenarios and results observed:

## VR-N76 or UV-PRO -> TH-D75

### Test 1
Sending 4 frames, receiving only 3 frames, number 1,3,4. Frame 2 is missing.

### Test 2
Sending 4 frames, receiving only 3 frames, number 1,2,4. Frame 3 is missing.

In both attempts, when listening to the over-the-air transmission, the radio appears to send data in three bursts. It's assumed that the internal buffer management of the received KISS frames is missing a frame for some reason.

Additionally, even though these frames are sent consecutively, the radio toggles the PTT after each frame and resends a lengthy HDLC synchronization prelude. This is problematic. The modulator should detect if there is more data to send and keep the PTT active.

## TH-D75 -> VR-N76 or UV-PRO

### Test 3
When attempting to receive 4 frames back to back, the radio does not seem to be able to decode any of them.

### Test 4
When attempting to receive 4 frames back to back with a 1s delay, the radio only seems to decode 2 out of the 4 frame received.

Note that on macOS, it seems that trying to read the /dev/cu.UV-PRO or /dev/cu.VR-N76 never yield any data. I resorted to use a modified version of B.B. Link adapter to read the serial data coming out of the radio. This might be a macOS problem.

### Observations

There seems to be issues with the modulator/demodulator code not keeping up with back-to-back frames. This likely stems from the fact that the radio previously only dealt with APRS, which handles single-frame transmissions only. However, for a TNC to properly manage the connection oriented portion of the AX.25 protocol, the HDLC framing, modulator, and demodulator should decode consecutive frames effectively.

Furthermore, when the radio sends consecutive frames, it doesn't maintain proper PTT, causing the HDLC sync preamble to be unnecessarily repeated with each frame. This results in lower throughput and may cause the receiving station's DCD mechanism to mistakenly assume the transmission is finished if there's a carrier interruption.