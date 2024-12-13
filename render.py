import bpy
import os
from dotenv import load_dotenv

env_file = ".env"

# Check if enviroment file exists
if os.path.exists(env_file):
    load_dotenv(env_file)
    print("Environment variables loaded from .env")
else:
    print(f"{env_file} does not exist.")

# Example of accessing an environment variable
some_variable = os.getenv("SOME_VARIABLE")
if some_variable:
    print(f"SOME_VARIABLE: {some_variable}")
else:
    print("SOME_VARIABLE not found in the environment.")

# List of resolutions to render
resolutions = [(64, 64), (128, 128), (512, 512)]

# Path to save the rendered images
output_path = "./render_output"

# Iterate through resolutions and render
for width, height in resolutions:
    bpy.context.scene.render.resolution_x = width
    bpy.context.scene.render.resolution_y = height
    bpy.context.scene.render.filepath = f"{output_path}_{width}x{height}.png"
    bpy.ops.render.render(write_still=True)
