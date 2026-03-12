#!/usr/bin/env python3
import subprocess
import sys

# Upload using scp with SSH key
source = "client/build/flutter_web.tar.gz"
dest = "root@144.31.234.69:/tmp/flutter_web.tar.gz"

print(f"Uploading {source} to {dest}...")
result = subprocess.run(["scp", source, dest], capture_output=True, text=True)

if result.returncode != 0:
    print(f"Error: {result.stderr}")
    sys.exit(1)

print("Upload successful!")

# Extract on server
print("Extracting on server...")
extract_cmd = """
cd /root/OutFitStyle/client/build
rm -rf web.old
mv web web.old
mkdir web
cd web
tar -xzf /tmp/flutter_web.tar.gz
rm /tmp/flutter_web.tar.gz
"""

result = subprocess.run(["ssh", "root@144.31.234.69", extract_cmd], capture_output=True, text=True)

if result.returncode != 0:
    print(f"Error: {result.stderr}")
    sys.exit(1)

print("Extraction successful!")
print("Flutter web deployed!")
