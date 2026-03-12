#!/usr/bin/env python3
import subprocess
import sys

# Upload using scp with SSH key
source = "landing/landing_dist.tar.gz"
dest = "root@144.31.234.69:/tmp/landing_dist.tar.gz"

print(f"Uploading {source} to {dest}...")
result = subprocess.run(["scp", source, dest], capture_output=True, text=True)

if result.returncode != 0:
    print(f"Error: {result.stderr}")
    sys.exit(1)

print("Upload successful!")

# Extract on server
print("Extracting on server...")
extract_cmd = """
cd /root/OutFitStyle/landing
rm -rf dist.old
mv dist dist.old 2>/dev/null || true
mkdir -p dist
cd dist
tar -xzf /tmp/landing_dist.tar.gz
rm /tmp/landing_dist.tar.gz
"""

result = subprocess.run(["ssh", "root@144.31.234.69", extract_cmd], capture_output=True, text=True)

if result.returncode != 0:
    print(f"Error: {result.stderr}")
    sys.exit(1)

print("Extraction successful!")
print("Landing page deployed!")
