__________________________________________________________________________
Patchnotes

Update 25.08.2021 v0.1.0b1
Include QPS exported ship track to compute tiles.

Update 01.10.2021 v0.1.0b2
Major changes. Create stand-alone version exclusively  
for Multibeam application

Update 30.11.2021 v0.1.0b3
Major changes. Implement a loop over all processing steps, so that
files are processed one after another, which saves the RAM not to
get overloaded and allows the function to be run on every PC.
Therefore all feedback loops got adjusted.

BugFix 10.12.2021 v0.1.0b4
In Split2Tile line 150; It appeared during Ship turns, that the max value
of points in tile exceeds more than 55000, which was the previous
reference value to compute the 10% threshold. Several tiles with less
than 5000 data points were wrongly deleted, so that whole profiles were
empty after processing.

Update 12.01.2022 v0.1.0b5
In WriteTrackline2GeoTiff function. QGIS can not handle nan values, which
lead to errors in several GDAL functions. Therefore option is
implemented to chose between the options "nan" and "-9999" for
transparent values

__________________________________________________________________________
Know Bug and issiue:

- Several function descriptions are still missing
- Spatial Processing function exist but is not implemented so far
- The bands in output GEOTiff have no labelling (just numbers 1 to 11)
- The average median function is to too slow without parfor loop and is  
  not implemented

==========================================================================
