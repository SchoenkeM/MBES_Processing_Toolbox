function dataStruct = GetDataSkeleton(fpath,fname)



dataStruct.ScanName   = fname;
dataStruct.Directory  = fpath;
%   dataStruct(j).FullName   = FileList(j).fullName;

dataStruct.Header     = [];
dataStruct.raw                = [];
dataStruct.processed          = [];
dataStruct.statistics         = [];
dataStruct.gridded            = [];
dataStruct.spectral           = [];
dataStruct.Outlier.Total      = [];
dataStruct.Outlier.Percentage = 0;




end

