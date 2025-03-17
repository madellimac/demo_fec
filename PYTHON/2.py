import numpy as np
import cv2

# File Paths
INPUT_BIN_FILE = "received_image.bin"  # Now reading from binary file
OUTPUT_PNG_FILE = "reconstructed.png"

# Expected image size
IMG_WIDTH = 96
IMG_HEIGHT = 64
EXPECTED_PIXELS = IMG_WIDTH * IMG_HEIGHT  # 6144 pixels
EXPECTED_BYTES = EXPECTED_PIXELS * 2  # 12288 bytes (each pixel is 2 bytes in RGB565)

# Read the raw binary file
try:
    with open(INPUT_BIN_FILE, "rb") as f:
        data = f.read()
except FileNotFoundError:
    print(f"Error: File {INPUT_BIN_FILE} not found.")
    exit(1)

# Ensure Correct Byte Count
if len(data) > EXPECTED_BYTES:
    print(f"Warning: Received more data than expected. Trimming excess {len(data) - EXPECTED_BYTES} bytes.")
    data = data[:EXPECTED_BYTES]
elif len(data) < EXPECTED_BYTES:
    print(f"Warning: Received fewer bytes ({len(data)}) than expected ({EXPECTED_BYTES}). Padding with zeros.")
    data += bytes(EXPECTED_BYTES - len(data))

# Convert to NumPy Array (2 bytes per pixel)
data_16bit = np.frombuffer(data, dtype=np.uint16).byteswap()  # Swap bytes


# Convert RGB565 to 8-bit RGB888
def rgb565_to_rgb888(pixel):
    b = ((pixel >> 11) & 0x1F) * 255 // 31  # Scale Red (5 bits -> 8 bits)
    g = ((pixel >> 5) & 0x3F) * 255 // 63   # Scale Green (6 bits -> 8 bits)
    r = (pixel & 0x1F) * 255 // 31          # Scale Blue (5 bits -> 8 bits)
    return (r, g, b)

# Convert entire image
rgb_image = np.array([rgb565_to_rgb888(pix) for pix in data_16bit], dtype=np.uint8)

# Reshape to 3-channel (RGB) image
rgb_image = rgb_image.reshape((IMG_HEIGHT, IMG_WIDTH, 3))

# Save the image
cv2.imwrite(OUTPUT_PNG_FILE, rgb_image)

print(f"Reconstructed image saved as {OUTPUT_PNG_FILE}")

