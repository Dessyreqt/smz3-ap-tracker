# Archipelago SMZ3 Tracker Package for PopTracker

This is an autotracking package for PopTracker to use with the [Archipelago](https://archipelago.gg) implementation of the Super Metroid/Zelda: A Link to the Past (SMZ3) randomizer. 

## Installation

Download the latest release of the package from the [releases page](https://github.com/Dessyreqt/smz3-ap-tracker/releases/latest) to your `packs` directory.

## PopTracker

For PopTracker the `packs` folder can be under `USER/Documents/PopTracker/packs`, `USER/PopTracker/packs` or `APP/packs`, where `USER` stands for your user directory and `APP` for the PopTracker installation directory.

## Building locally

The build process has only been tested on Windows and requires:
- [Python 3.10+](https://www.python.org/downloads/)
- A copy of PopTracker installed in the root of the `./test` directory, which can be downloaded from the [PopTracker releases page](https://github.com/black-sliver/PopTracker/releases/latest). It is recommended to add a `portable.txt` file to the `test` directory to make PopTracker portable.

Install the required dependencies with:
```bash
pip install -r requirements.txt
```

Run the test script for testing. This will build the package and run a test version of PopTracker:
```bash
python test.py
```

The package can be built with:
```bash
python build.py -v {version} -c "{change_log}"
```
Where `{version}` is the version of the package and `{change_log}` is the change log for the package. The change log should be a single line of text, so if you want to use multiple lines, you can use `\n` to separate them.
The package will be built in the `./bin` directory. The script will then output additional steps to release the new version on GitHub.

## License
This package is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Contributing
Contributions are welcome! If you have any suggestions or find any bugs, please open an issue on the [GitHub repository](https://github.com/Dessyreqt/smz3-ap-tracker/issues/new)
