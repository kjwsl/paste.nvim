import platform
import subprocess
from PIL import Image, ImageGrab
from io import BytesIO
import os
import sys


def save_image(image_data, file_path):
    # Create the output directory if it doesn't exist
    output_dir = os.path.dirname(file_path)
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    img = Image.open(BytesIO(image_data))
    img.save(file_path, "PNG")
    print(f"Image saved as {file_path}")


def get_image_from_clipboard():
    system = platform.system()

    if system == 'Windows' or system == 'Darwin':  # macOS
        img = ImageGrab.grabclipboard()
        if isinstance(img, Image.Image):
            buffer = BytesIO()
            img.save(buffer, format="PNG")
            return buffer.getvalue()
        else:
            print("No image found in clipboard.")
            return None

    elif system == 'Linux':
        try:
            # Try grabbing the clipboard image using xclip (for X11-based Linux)
            result = subprocess.run(
                ['xclip', '-selection', 'clipboard', '-t', 'image/png', '-o'],
                stdout=subprocess.PIPE, stderr=subprocess.PIPE
            )

            if result.returncode == 0:
                return result.stdout
            else:
                print("No image found in clipboard or xclip not installed.")
                return None
        except FileNotFoundError:
            print("xclip is not installed. Please install it via your package manager.")
            return None

    else:
        print(f"Unsupported system: {system}")
        return None


def main(output_path):
    image_data = get_image_from_clipboard()

    if image_data:
        save_image(image_data, output_path)


if __name__ == '__main__':
    # Check if an output path is provided as an argument
    if len(sys.argv) > 1:
        # output_path = sys.argv[1]
        # Resolve the path to an absolute path
        output_path = os.path.abspath(sys.argv[1])
    else:
        output_path = os.path.join(os.getcwd(), "output.png")  # Default path

    main(output_path)
