import bpy
import os
from dotenv import load_dotenv
import sys

def load_environment():
    env_file = ".env"
    if os.path.exists(env_file):
        load_dotenv(env_file)
        return True
    return False

def get_render_sizes():
    sizes = []
    if os.getenv("sit_global_render_32") == "true":
        sizes.append(32)
    if os.getenv("sit_global_render_64") == "true":
        sizes.append(64)
    if os.getenv("sit_global_render_128") == "true":
        sizes.append(128)
    if os.getenv("sit_global_render_256") == "true":
        sizes.append(256)
    if os.getenv("sit_global_render_512") == "true":
        sizes.append(512)
    return sizes

def render_icon(blend_file, output_dir, size):
    # Set render resolution
    bpy.context.scene.render.resolution_x = size
    bpy.context.scene.render.resolution_y = size

    # Get filename without extension
    icon_name = os.path.splitext(os.path.basename(bpy.data.filepath))[0]

    # Create size-specific output directory
    size_dir = os.path.join(output_dir, str(size))
    os.makedirs(size_dir, exist_ok=True)

    # Set output path with correct name
    output_path = os.path.join(size_dir, f"{icon_name}.png")
    bpy.context.scene.render.filepath = output_path

    # Set render format to PNG
    bpy.context.scene.render.image_settings.file_format = 'PNG'

    # Render
    bpy.ops.render.render(write_still=True)
    print(f"Rendered {icon_name}.png at {size}x{size}")

def main():
    # Get output directory from command line arguments
    # In Blender, args after -- are at position 5 onwards
    output_dir = sys.argv[sys.argv.index("--") + 1]

    if not load_environment():
        print("Error: .env file not found")
        sys.exit(1)

    # Get render sizes from environment
    sizes = get_render_sizes()
    if not sizes:
        print("Error: No render sizes enabled in .env")
        sys.exit(1)

    # Render for each size
    for size in sizes:
        render_icon(bpy.data.filepath, output_dir, size)

if __name__ == "__main__":
    main()
