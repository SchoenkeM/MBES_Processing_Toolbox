function  S = UpdateOutlier(S)

 
  fnames = fieldnames(S.Outlier);
  flag = strcmp(fnames,'Percentage') | strcmp(fnames,'Total');
  fnames(flag)=[];
  
  if isempty(S.Outlier.Total)
      S.Outlier.Total=zeros(size(S.raw.x))==1;
  end

  
  for i = 1:length(fnames)
      if ~isempty(S.Outlier.(fnames{i,1}))
             S.Outlier.Total =  S.Outlier.Total | S.Outlier.(fnames{i,1}); 
      end
  end
 
 N=length(S.Outlier.Total);  
 S.Outlier.Percentage = (sum(S.Outlier.Total)/N)*100;
 
 if S.Outlier.Percentage == 100
    txt= ['- WARNING: All Data points are flagged as ',...
        'Outliers'];       
    varin =   '';   
    varunit = [];
    Verbose(txt,varin,varunit) 
 end
     
     
     
end

