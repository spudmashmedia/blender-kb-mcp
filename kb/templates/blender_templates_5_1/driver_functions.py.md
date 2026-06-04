---
search_priority: high
document_type: code-example
blender_version: 5.1
tags: [drivers, expressions, bpy.app, namespace, custom-functions]
related_files: [02_object_properties.py.md, 08_error_handling_patterns/01_safe_operations.py.md]
difficulty: intermediate
categories: [driver-expressions, custom-geometry, viewport-menu, object-creation]
last_updated: 2026-04-29
search_keywords: [driver namespace, custom functions, driver expressions, bpy.app.driver_namespace, invert function, uuid_store pattern, register drivers, unregister, python script]
---

# Template - Driver Functions

```template
# This script defines functions to be used directly in driver expressions to
# extend the built-in set of python functions.
#
# This can be executed on manually or set to "Register" to
# initialize the functions on file load.


# two sample functions
def invert(f):
    """ Simple function call:

            invert(val)
    """
    return 1.0 - f


uuid_store = {}


def slow_value(value, fac, uuid):
    """ Delay the value by a factor, use a unique string to allow
        use in multiple drivers without conflict:

            slow_value(val, 0.5, "my_value")
    """
    value_prev = uuid_store.get(uuid, value)
    uuid_store[uuid] = value_new = (value_prev * fac) + (value * (1.0 - fac))
    return value_new


import bpy

# Add functions defined in this script into the drivers namespace.
bpy.app.driver_namespace["invert"] = invert
bpy.app.driver_namespace["slow_value"] = slow_value

```
