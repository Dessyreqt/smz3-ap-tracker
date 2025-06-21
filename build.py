import os
import shutil
import hashlib
import json
import argparse
from buildfunctions import build_pack_content, calculate_sha256, compress_images, update_manifest

def main():
    parser = argparse.ArgumentParser(description="Build script for smz3-ap-tracker")
    parser.add_argument("-v", "--version", type=str, help="Version number")
    parser.add_argument("-c", "--changelog", type=str, help="Changelog text")
    parser.add_argument("--skipcompression", action="store_true", help="Skip image compression")
    args = parser.parse_args()

    if not args.skipcompression:
        print("Compressing images...")
        compress_images()
    else:
        print("Skipping image compression.")

    # Create the bin directory if it doesn't exist
    os.makedirs("./bin", exist_ok=True)

    filename = "smz3-ap-tracker.zip"
    if args.version:
        filename = f"smz3-ap-tracker-{args.version}.zip"
        update_manifest(args.version)

    print("Building poptracker pack...")
    build_pack_content()

    zip_path = os.path.join("./bin", filename)
    if os.path.exists(zip_path):
        os.remove(zip_path)

    shutil.make_archive(zip_path.replace(".zip", ""), "zip", "./bin/build")
    print(f"Build complete. Output: {zip_path}")

    if args.version:
        sha256_hash = calculate_sha256(zip_path)
        print(f"SHA256: {sha256_hash}")

        versions_path = "./versions.json"
        with open(versions_path, "r") as f:
            versions = json.load(f)

        new_version = {
            "package_version": args.version,
            "download_url": f"https://github.com/dessyreqt/smz3-ap-tracker/releases/download/{args.version}/{filename}",
            "sha256": sha256_hash,
            "changelog": [args.changelog] if args.changelog else []
        }
        versions["versions"].insert(0, new_version)

        with open(versions_path, "w") as f:
            json.dump(versions, f, indent=2)

        print("Versioning complete! Next steps:")
        print("- Commit and push all files except ./versions.json")
        print("- Create release in GitHub and attach the zip file")
        print("- Commit and push ./versions.json")

if __name__ == "__main__":
    main()
