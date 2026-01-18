from PIL import Image
import os

def zoom_icon(input_path, output_path, zoom_factor=1.3):
    try:
        img = Image.open(input_path)
        width, height = img.size
        
        # Calculate new dimensions (cropping from center)
        # To "zoom in", we crop the image and resize back to original
        
        # new_width = original_width / zoom_factor
        crop_width = width / zoom_factor
        crop_height = height / zoom_factor
        
        left = (width - crop_width) / 2
        top = (height - crop_height) / 2
        right = (width + crop_width) / 2
        bottom = (height + crop_height) / 2
        
        img_cropped = img.crop((left, top, right, bottom))
        # Force resize to 512x512
        img_resized = img_cropped.resize((512, 512), Image.Resampling.LANCZOS)
        
        img_resized.save(output_path)
        print(f"Successfully zoomed icon saved to {output_path} with size {img_resized.size}")
        
    except Exception as e:
        print(f"Error processing image: {e}")

if __name__ == "__main__":
    input_file = r"C:\Users\moi\.gemini\antigravity\brain\739bcf6a-f32d-426b-977e-0f952f3256fe\say_task_icon_purple_bg_1768770486891.png"
    output_file = r"C:\Users\moi\.gemini\antigravity\brain\739bcf6a-f32d-426b-977e-0f952f3256fe\say_task_icon_512.png"
    
    # Zoom factor 1.5 for slightly more expansion
    zoom_icon(input_file, output_file, zoom_factor=1.5)
