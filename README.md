[![DOI](https://img.shields.io/badge/DOI-10.17882%2F59331-informational)](https://doi.org/10.17882/59331)

# Tootsea
<img src="https://user-images.githubusercontent.com/17851004/80486405-66ec1a80-895b-11ea-93be-c8914089584c.png" alt="tootsea logo" width=300>

## Summary
TOOTSEA (Toolbox for Oceanographic mooring Time Series Exploration and Analysis) is a Matlab software, developped at LOPS (Laboratoire d'Océanographie Physique et Spatiale), IFREMER. This tool is dedicated to analyzing datasets from moored oceanographic instruments (Currentmeter, CTD, Thermistance, ...). TOOTSEA allows the user to explore the data and metadata from various instruments file, to analyze them with multiple plots and stats available, to do some processing/corrections and qualify (automatically and manually) the data, and finally to export the work in a netcdf file.  
Find web documentation [here](https://quai20.github.io/TOOTSEA/).

Some work plan :
* [X] Some code review before release
* [X] [Web documentation](https://quai20.github.io/TOOTSEA/) 
* [X] Some unit testing in tests/ (to be continued, with GUIDE test if possible)
* [X] Some tiny example datasets to be used in the tests
* [X] Contribution guidelines  
* [X] [Release](https://github.com/quai20/TOOTSEA/releases)

## Testing
You can test some basic behaviours of Tootsea by running `run_tests`, which runs every `test_xxx.m` test file present in the `tests` directory. If you want to contribute to the code, please consider adding your tests there.  
Since `TOOTSEA` is UI based, some behaviors are tricky to test automatically, for those, you can find some testing protocols in [tests/testing_protocols.md](tests/testing_protocols.md).

## Contributing to `TOOTSEA`

Should one want to propose a change or new feature, please file an issue through the GitHub interface. Bug reports specifically may be made here. When proposing a change/new feature, or reporting a bug, please illustrate the issue with a minimal reproducible example, including texts, codes and resultant outputs.  

By contributing to this project, you agree to follow the [Code of conduct](docs/codeOfconduct.md)
