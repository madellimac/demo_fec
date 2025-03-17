import cv2
import numpy as np
import serial
import time
import os

# OLED Display Resolution
WIDTH, HEIGHT = 96, 64  
BAUDRATE = 921600  # UART Baud Rate

def convert_image_to_rgb565_bytes(image_path):
    """ Convert an image to RGB565 format (two bytes per pixel). """
    img = cv2.imread(image_path)  # Load image
    if img is None:
        raise ValueError("Error loading image. Check file path.")
    
    img = cv2.resize(img, (WIDTH, HEIGHT))  # Resize to OLED display size
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)  # Convert to RGB (OpenCV uses BGR)

    pixel_bytes = []
    for row in img:
        for pixel in row:
            r, g, b = pixel
            r_5 = (r >> 3) & 0x1F  # 5 bits for red
            g_6 = (g >> 2) & 0x3F  # 6 bits for green
            b_5 = (b >> 3) & 0x1F  # 5 bits for blue

            # Correct RGB565 packing
            rgb565 = (r_5 << 11) | (g_6 << 5) | b_5  
            high_byte = (rgb565 >> 8) & 0xFF  # Extract high byte (0-255)
            low_byte = rgb565 & 0xFF          # Extract low byte (0-255)

            # Ensure values are within byte range
            assert 0 <= high_byte <= 255, f"Invalid high_byte: {high_byte}"
            assert 0 <= low_byte <= 255, f"Invalid low_byte: {low_byte}"

            pixel_bytes.append((high_byte, low_byte))

    return pixel_bytes

def write_rgb565_to_file(pixel_bytes, output_file):
    """ Save RGB565 image data to a text file for debugging. """
    with open(output_file, 'w') as file:
        file.write("BEGIN_IMAGE\n")
        for i, (high_byte, low_byte) in enumerate(pixel_bytes):
            file.write(f"{high_byte} {low_byte} ")
            if (i + 1) % WIDTH == 0:
                file.write("\n")  
        file.write("END_IMAGE\n")

def send_rgb565_over_uart(pixel_bytes, serial_port):
    """ Send RGB565 image data to FPGA via UART. """
    try:
        with serial.Serial(serial_port, BAUDRATE, timeout=1) as ser:
            time.sleep(2)  # Wait for the serial connection
            print(f"Connected to {serial_port} at {BAUDRATE} baud")

            for high_byte, low_byte in pixel_bytes:
                ser.write(bytes([high_byte, low_byte]))  

            print("Image successfully sent to FPGA.")

    except serial.SerialException as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    # Ask for the image file from user
    IMAGE_FILE = input("Enter the image file path (e.g., 'image.png'): ").strip()

    if not os.path.isfile(IMAGE_FILE):
        print(f"Error: File '{IMAGE_FILE}' not found. Please check the file path.")
        exit(1)

    # Ask for the serial port (default to COM4)
    SERIAL_PORT = input("Enter the serial port (default is COM4): ").strip() or "COM4"
    OUTPUT_FILE = "converted_image.txt"  # Default output filename

    print(f"Processing image: {IMAGE_FILE}")
    
    # Convert the image to RGB565 format
    pixel_bytes = convert_image_to_rgb565_bytes(IMAGE_FILE)

    # Save the RGB565 data to a text file (for debugging)
    write_rgb565_to_file(pixel_bytes, OUTPUT_FILE)

    print(f"Converted image data saved to {OUTPUT_FILE}")

    # Send the RGB565 data over UART to FPGA
    send_rgb565_over_uart(pixel_bytes, SERIAL_PORT)

    print("Done! 🚀")
