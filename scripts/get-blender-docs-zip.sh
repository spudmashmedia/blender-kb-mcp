#!/usr/bin/env bash
set -o pipefail

# Configuration
TARGET_URL="https://docs.blender.org/api/current/blender_python_reference_5_1.zip"
BUILD_DIR_NAME="${BUILD_DIR_NAME:-build}"  # Default to 'build', can be overridden
DEST_BASE="${PWD}/${BUILD_DIR_NAME}/kb"    # Relative to current directory
# DEST_DIR="${DEST_BASE}/blender_python_reference_5_1"
DEST_DIR="${DEST_BASE}"
TEMP_ZIP="/tmp/blender_docs_temp.zip"
CLEAN_MODE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --clean|-c)
            CLEAN_MODE=true
            shift
            ;;
        --build-dir|-b)
            BUILD_DIR_NAME="$2"
            DEST_BASE="${PWD}/${BUILD_DIR_NAME}/kb"
            # DEST_DIR="${DEST_BASE}/blender_python_reference_5_1"
            DEST_DIR="${DEST_BASE}"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [--clean|-c] [--build-dir|-b <path>]"
            echo ""
            echo "Options:"
            echo "  --clean, -c           Clean the destination folder before downloading"
            echo "  --build-dir, -b       Specify custom build directory (default: ./build)"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information." >&2
            exit 1
            ;;
    esac
done

echo "Starting Blender Docs Download..."
echo "Current directory: $(pwd)"
echo "Destination: $DEST_DIR"

# Step 1: Clean destination directory if requested
if [ "$CLEAN_MODE" = true ]; then
    echo "Cleaning destination folder: $DEST_DIR"
    rm -rf "$DEST_DIR"
fi

# Step 2: Create destination directory (requires write permission)
echo "Creating destination directory: $DEST_DIR"
mkdir -p "$DEST_DIR"

# Step 3: Download the zip file
echo "Downloading from: $TARGET_URL"
if ! curl -fL -o "$TEMP_ZIP" "$TARGET_URL"; then
    echo "Error: Failed to download the zip file." >&2
    exit 1
fi

# Step 4: Extract the contents into the destination folder
echo "Extracting files..."
if ! unzip -q -o "$TEMP_ZIP" -d "$DEST_DIR"; then
    echo "Error: Failed to extract the zip file." >&2
    rm -f "$TEMP_ZIP"
    exit 1
fi

# Step 5: Cleanup temporary file
rm -f "$TEMP_ZIP"

echo "Done! Files extracted to $DEST_DIR"
