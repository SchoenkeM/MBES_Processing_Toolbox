function [varargout]=printVarSize(var)

S=whos; Sbytes=round(S.bytes./1000000); 

if Sbytes >= 1000 
   Sbytes = Sbytes./1000;
   Einheit = 'Gb';
   txt='%0.2f %s';
elseif Sbytes==0
   Einheit = 'Kbit'; 
   Sbytes= S.bytes;
   txt='%d %s';
else
   Einheit = 'Mb';
   txt='%d %s';
end

%fprintf('\n\tINFO: Size of input variable: %0.2f %s\n\n',Sbytes,Einheit);
if isempty(nargout)
   fprintf(txt,Sbytes,Einheit);
else
   varargout{1,1}=sprintf(txt,Sbytes,Einheit);
end

end