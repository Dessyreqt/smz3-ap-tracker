import subprocess
from buildfunctions import build_pack_content, compress_pack, stop_process, wait_for_process_to_close
from pack_constants import pack_name
from pathlib import Path

def main():
    poptracker_path = Path("./test/poptracker.exe")
    if not poptracker_path.exists():
        print(f"Error: {poptracker_path} not found. Ensure poptracker.exe is in the correct location.")
        return

    # Stop running poptracker if it's active
    stop_process("poptracker.exe")

    # Wait for poptracker to fully close
    wait_for_process_to_close("poptracker.exe")

    print("Building poptracker pack...")
    build_pack_content()

    # Ensure the test packs directory exists
    test_packs_path = Path("./test/packs")
    test_packs_path.mkdir(parents=True, exist_ok=True)

    # Remove existing zip file if it exists
    zip_path = test_packs_path / f"{pack_name}.zip"
    if zip_path.exists():
        zip_path.unlink()

    # Create the new zip file
    compress_pack(zip_path, "./bin/build")

    # Run poptracker
    print("Starting poptracker...")
    subprocess.Popen([str(poptracker_path)], shell=True)

if __name__ == "__main__":
    main()
