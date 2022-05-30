function Data= txt2mat(Data)
    
    FullName=fullfile(Data.Directory,Data.ScanName);
  % Open *.csv-file of CLS data type for reading process
     fileID = fopen(FullName,'r');   
  % checks if file is readable or prints message and skips data set
    if fileID < 1
         fprintf('failed. Unable to open file');
    else         


    % TEXTSCAN format specifiers
      formatSpec = '%f%f%f%d%d%[^\n\r]';
      delimiter = ',';
      startRow = 1;
      endRow = inf;
    % Scan document
      txtdata = textscan(fileID, formatSpec, endRow-startRow,...
           'Delimiter', delimiter, 'MultipleDelimsAsOne', true, ...
           'ReturnOnError',false, 'EndOfLine', '\r\n');
      txtdata(:,6)=[];
    % txtdata= cell2mat(txtdata);  
       
      Data.raw.x=txtdata{1,1};
      Data.raw.y=txtdata{1,2};
      Data.raw.z=txtdata{1,3};
      Data.raw.angle = single(txtdata{1,4});
      Data.raw.ping  = single(txtdata{1,5});

    % close reading file after reading header
      fclose('all'); 
           
      
    end
end

