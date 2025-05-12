import serial
import time

# Global shift register (SR[2], SR[1], SR[0])
shift_register = [0, 0, 0]

def viterbi_byte_encode(byte):
    global shift_register
    x1_byte = 0
    x2_byte = 0

    for i in range(8):
        bit = (byte >> i) & 1

        x1 = bit ^ shift_register[2] ^ shift_register[0]  # G1 = 101
        x2 = bit ^ shift_register[1] ^ shift_register[0]  # G2 = 011

        x1_byte |= (x1 << i)
        x2_byte |= (x2 << i)

        # Update shift register
        shift_register[0], shift_register[1], shift_register[2] = shift_register[1], shift_register[2], bit

    return x1_byte, x2_byte


# === Config ===
PORT = 'COM4'
BAUDRATE = 921600
TEST_BYTES = [0b11110000, 0b01010101, 0b00001111]  # Add more bytes here

# === Send test bytes and receive encoded responses ===
with serial.Serial(PORT, BAUDRATE, timeout=1) as ser:
    time.sleep(1)
    ser.reset_input_buffer()
    ser.reset_output_buffer()

    print(f"Sending bytes: {[f'{b:08b}' for b in TEST_BYTES]}")
    ser.write(bytes(TEST_BYTES))

    time.sleep(0.05)  # Wait for FPGA to respond

    response = ser.read(len(TEST_BYTES))  # Read same number of bytes back

    if len(response) != len(TEST_BYTES):
        raise Exception(f"⚠️ Expected {len(TEST_BYTES)} bytes, got {len(response)}")

    print(f"Received bytes: {[f'{b:08b}' for b in response]}")

    # === Comparison ===
    for i, test_byte in enumerate(TEST_BYTES):
        expected_x1, expected_x2 = viterbi_byte_encode(test_byte)
        received_byte = response[i]

        print(f"\nByte {i+1}: {test_byte:08b}")
        print(f"  Expected x1: {expected_x1:08b}")
        print(f"  Expected x2: {expected_x2:08b}")
        print(f"  Received   : {received_byte:08b}")

        if received_byte == expected_x1:
            print("  ✅ Match with x1")
        elif received_byte == expected_x2:
            print("  ✅ Match with x2")
        else:
            print("  ❌ No match with x1 or x2")
