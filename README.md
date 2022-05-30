# ProcBathy4TM_Imaging
Processing Tool for hydroacoustic data recorded by a multibeam echosounder system

Spatial Processing Software is an approach to classify anthropogenic
impaced seafloor surface by bottom trawling, whose characteristics
differ significantly from geologic morphologies. Advantage is that the
statistic of the measured bathymerty is computed befor the aktual
grid is performed

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
__________________________________________________________________________
Patchnotes

Update 25.08.2021 v0.1
Include QPS exportet Ship track to compute tiles.

Update 01.10.2021 v0.2
Major changes. Create stand alone version exclusivly  
for Mulitbeam application

Update 30.11.2021
Major changes. Implement a loop over all processing steps, so that
files are porcessed one after another, which saves the RAM not to
get overloaded and allows the function to be run on every PC.
Therefore all feedback loops got adjusted.

BugFix 10.12.2021
In Split2Tile line 150; It appeared during Ship turns, that the max value
of points in tile exceeds more than 55000, which was the previous
reference value to compute the 10% threshold. Several tiles with less
than 5000 data points were wrongly deleted, so that whole profiles were
empty after processing.

Update 12.01.2022
In WriteTrackline2GeoTiff function. Qgis can not handle nan values, which
lead to errors in several GDAL functions. Therefore option is
implemented to chose between the options "nan" and "-9999" for
transparent values


First Release 30.11.2021 v1.0.1

__________________________________________________________________________
Know Bug and issiue:

- several function discriptions are still missing
- Spatial Processing function exist but is not implemented so far
- the bands in output GeoTiff have no labeling ( just numbert 1 to 11)
- the average median function is to too slow without parfor loop and is  
  not implemented

==========================================================================
Copyright including all subfunctions by the author Mischa Schönke, 2021

mail: mischa.schoenke@io-warnemuende.de

This function was developed within the MGF project, for the purpose
to improve the evaluation of small scale surface feature measured
by a multibeam echosunder.

Revision 1.0  2021/11/30
