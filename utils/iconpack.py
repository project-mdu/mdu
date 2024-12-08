# mdunew/utils/iconpack.py

import os
from PIL import Image

def create_icon():
    # Input and output paths
    input_path = os.path.join('resources', 'image', 'app.png')
    output_dir = os.path.join('resources', 'icons')
    output_path = os.path.join(output_dir, 'app.ico')

    # Create the output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)

    try:
        # Open the image
        img = Image.open(input_path)

        # Convert and save as ICO
        # ICO format typically includes multiple sizes
        # Common sizes are 16x16, 32x32, 48x48, and 256x256
        icon_sizes = [(16, 16), (32, 32), (48, 48), (256, 256)]

        # Create resized versions of the image
        img_list = []
        for size in icon_sizes:
            resized_img = img.resize(size, Image.Resampling.LANCZOS)
            img_list.append(resized_img)

        # Save as ICO
        img_list[0].save(
            output_path,
            format='ICO',
            sizes=[(img.width, img.height) for img in img_list],
            append_images=img_list[1:]
        )

        print(f"Icon successfully created at: {output_path}")
        return True

    except Exception as e:
        print(f"Error creating icon: {str(e)}")
        return False

if __name__ == "__main__":
    create_icon()
