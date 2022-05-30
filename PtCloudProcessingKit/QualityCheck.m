function QualityCheck(flag)

       QualityChecksum=sum(flag)/length(flag)*100;
       if QualityChecksum>50
           fprintf('\n\t\t -> Warning %2.0f%% of the data set is flagged as outlier', QualityChecksum);    
       end
       
end