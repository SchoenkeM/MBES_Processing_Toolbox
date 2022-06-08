# MBES Processing Toolbox
Processing Tool for hydroacoustic data recorded by multibeam echosounder (MBES) systems to classify anthropogenically impacted seafloor surface by bottom trawling, whose characteristics differ significantly from geologic morphologies. The advantage is that the statistic of the measured bathymetry is computed before the actual grid is performed.

## Publication in [Remote Sensing](https://www.mdpi.com/journal/remotesensing)
This toolbox is used in the publication of Schönke et al. (**add DOI as soon as available**). To replicate the processing used in the paper download version [1.0.0](https://github.com/SchoenkeM/MBES_Processing_Toolbox/releases/1.0.0), since new versions will be released as the toolbox evolves further. The MBES raw data presented in that study are stored on dedicated servers at the Leibniz Institute for Baltic Sea Research Warnemünde and are available from the corresponding author at reasonable request via [e-mail](mailto:mischa.schoenke@io-warnemuende.de). The point cloud data (ship logs and soundings) used for the calculations are available [here](https://doi.org/10.5281/zenodo.6597161).

## Installation
### Download the latest release
1. Visit the [latest release](https://github.com/SchoenkeM/MBES_Processing_Toolbox/releases/latest/).
2. Download the `Source code (zip)` file.

### Maintain as a git submodule
#### Install submodule
1. To add the MBES Processing Toolbox repository as a git submodule run:
```
git submodule add https://github.com/SchoenkeM/MBES_Processing_Toolbox.git <relativePathWithinSuperrepository>
```
This should create a `.gitmodules` file in the root of the superrepository, if it doesn't exist yet.
2. In that file add the `branch = release` line. So that it looks like this:
```
[submodule "<relativePathWithinSuperrepository>"]
	path = <relativePathWithinSuperrepository>
	url = https://github.com/SchoenkeM/MBES_Processing_Toolbox.git
	branch = release
```

#### Update submodule
1. If you want to pull the latest release from this repository to your submodule run
```
git submodule update --remote --merge
```

## Copyright

Copyright 2021-2022 including all subfunctions by the author Mischa Schönke

mail: mischa.schoenke@io-warnemuende.de

This function was developed within the MGF project, for the purpose
to improve the evaluation of small scale surface feature measured
by a multibeam echosunder.
