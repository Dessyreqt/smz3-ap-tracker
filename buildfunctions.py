import os
import json
import hashlib
import shutil
import re
import subprocess
from pathlib import Path
from zopflipng import png_optimize

def save_image_hashes(image_hashes, output_path):
    ordered_hashes = dict(sorted(image_hashes.items()))
    with open(output_path, "w") as f:
        json.dump(ordered_hashes, f, indent=2)

def compress_image(file_path, output_path):
    data = open(file_path, 'rb').read()
    result, code = png_optimize(data, lossy_8bit=True, lossy_transparent=True, filter_strategies='01234mepb', num_iterations=15)

    if code == 0:
        # save png file
        with open(output_path,'wb') as f:
            f.write(result)
            f.close()

def compress_images():
    image_hashes_path = "./imagehash.json"
    if os.path.exists(image_hashes_path):
        with open(image_hashes_path, "r") as f:
            image_hashes = json.load(f)
    else:
        image_hashes = {}

    src_path = Path("./src")
    for file in src_path.rglob("*.png"):
        relative_path = str(file.relative_to(src_path)).replace("\\", "/")
        current_hash = hashlib.sha256(file.read_bytes()).hexdigest()
        print(f"Current hash for {relative_path}: {current_hash}")

        if image_hashes.get(relative_path) == current_hash:
            print(f"Skipping {file}, already compressed.")
            continue

        output_file = file.with_name(f"{file.stem}-compressed.png")
        print(f"Compressing {file} to {output_file}...")
        
        compress_image(file, output_file)
        file.unlink()
        output_file.rename(file)

        new_hash = hashlib.sha256(file.read_bytes()).hexdigest()
        image_hashes[relative_path] = new_hash
        save_image_hashes(image_hashes, image_hashes_path)

def remove_jsonc_comments(file_path):
    with open(file_path, "r") as f:
        content = f.read()

    # Remove single-line comments (//)
    content = "\n".join(line for line in content.splitlines() if not line.strip().startswith("//"))

    # Remove multi-line comments (/* */)
    content = re.sub(r"/\*.*?\*/", "", content, flags=re.DOTALL)

    # Remove trailing commas
    content = re.sub(r",\s*([\]}])", r"\1", content)

    with open(file_path, "w") as f:
        f.write(content)

def minify_json(file_path):
    with open(file_path, "r") as f:
        content = json.load(f)
    with open(file_path, "w") as f:
        json.dump(content, f, separators=(",", ":"))

def build_pack_content():
    build_path = Path("./bin/build")
    if build_path.exists():
        shutil.rmtree(build_path)
    shutil.copytree("./src", build_path)

    for file in build_path.rglob("*.jsonc"):
        remove_jsonc_comments(file)
        minify_json(file)
        file.rename(file.with_suffix(".json"))

    init_lua_path = build_path / "scripts/init.lua"
    if init_lua_path.exists():
        with open(init_lua_path, "r") as f:
            content = f.read()
        content = content.replace("jsonc", "json")
        with open(init_lua_path, "w") as f:
            f.write(content)

def update_manifest(version):
    manifest_path = "./src/manifest.json"
    with open(manifest_path, "r") as f:
        manifest = json.load(f)
    manifest["package_version"] = version
    with open(manifest_path, "w") as f:
        json.dump(manifest, f, indent=2)

def calculate_sha256(file_path):
    sha256 = hashlib.sha256()
    with open(file_path, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            sha256.update(chunk)
    return sha256.hexdigest()

def stop_process(process_name):
    """Stops a running process by name."""
    try:
        result = subprocess.run(
            ["tasklist"], capture_output=True, text=True, check=True
        )
        if process_name.lower() in result.stdout.lower():
            subprocess.run(["taskkill", "/IM", process_name, "/F"], check=True)
            print(f"Stopped process: {process_name}")
    except subprocess.CalledProcessError:
        print(f"No running process found with name: {process_name}")

def wait_for_process_to_close(process_name):
    """Waits for a process to fully close."""
    while True:
        try:
            result = subprocess.run(
                ["tasklist"], capture_output=True, text=True, check=True
            )
            if process_name.lower() not in result.stdout.lower():
                break
        except subprocess.CalledProcessError:
            break
        print(f"Waiting for {process_name} to close...")
        time.sleep(1)
