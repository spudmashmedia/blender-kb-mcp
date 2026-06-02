---
search_priority: high
document_type: code-example
blender_version: 5.1
tags: [images, numpy, pixel-manipulation, python-api]
related_files: [02_object_properties.py.md, 08_error_handling_patterns/01_safe_operations.py.md]
difficulty: intermediate
categories: [image-processing, data-structures, numpy-integration, bpy-types]
last_updated: 2026-04-29
search_keywords: [image processing, pixel manipulation, bpy.data.images, foreach_get, foreach_set, numpy array, image pixels, color inversion, gamma correction, floatvectorproperty, register, unregister]
---

# Template - Image Processing

```python
# This sample shows an efficient way of doing image processing
# over Blender's images using Python.

import bpy
import numpy as np


input_image_name = "Image"
output_image_name = "NewImage"

# Retrieve input image.
input_image = bpy.data.images[input_image_name]
w, h = input_image.size

# Allocate a numpy array to manipulate pixel data.
pixel_data = np.zeros((w, h, 4), 'f')

# Fast copy of pixel data from bpy.data to numpy array.
input_image.pixels.foreach_get(pixel_data.ravel())

# Do whatever image processing you want using numpy here:
# Example 1: Invert red green and blue channels.
pixel_data[:, :, :3] = 1.0 - pixel_data[:, :, :3]
# Example 2: Change gamma on the red channel.
pixel_data[:, :, 0] = np.power(pixel_data[:, :, 0], 1.5)

# Create output image.
if output_image_name in bpy.data.images:
    output_image = bpy.data.images[output_image_name]
else:
    output_image = bpy.data.images.new(output_image_name, width=w, height=h)

# Copy of pixel data from numpy array back to the output image.
output_image.pixels.foreach_set(pixel_data.ravel())
output_image.update()

```
