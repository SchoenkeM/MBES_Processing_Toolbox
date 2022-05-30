function Verbose(txt,varin,varunit)
% Function that provides feedback to the user
%     txt of type 'char' 
%   varin of type integer, char, float
% varunit of type integer, char, float 
%         


LineStart   = '\n\t'; % specifies the starting column of the line
strSize     = 80;     % valid String length
PlaceHolder = '.';

  
%% ________________________________________________________________________
% Create taper for text alignment
    strTaper ='';
    for j = 1: strSize 
        strTaper = [strTaper PlaceHolder];   %#ok<AGROW>
    end
%% ________________________________________________________________________
% Check input Input variable 
%Get length of Input variable type "text"
    l_txt=length(txt);

% Check input for Input variable "varin"
    if isa(varin,'cell')
        varin=cell2mat(varin);
    end
    
    l_varin = 0; % predefine
    if isempty(varin)==0
        if isa(varin,'char') 
            l_varin= length(varin);
            varin = sprintf('%s   ',varin); 
        elseif isa(varin,'string') 
            fprintf([' \nWARNING: Input of type String for variable',...
                    ' "varin" is not supported by function Verbose\n']);
            return; 
        elseif isa(varin,'double') && mod(varin,round(varin))==0
            l_varin=length(num2str(varin));
            varin=sprintf('%d   ',varin);
        elseif isa(varin,'double')
            l_varin=length(num2str(round(varin)));
            varin=sprintf('%02.2f',varin);    
        else
            fprintf([' \nWARNING: Invalid input type for variable',...
            ' "varin" in function Verbose\n']);
           
        end
    else
         fprintf([' \nWARNING: No input for variable "varin"',...
          'in function Verbose\n']);
    
    end

% Check input for Input variable "varunit"
    if isa(varunit,'double') && isempty(varunit)==0
            if mod(varunit,round(varunit))==0
                varunit = sprintf('%d',varunit);
            else
                varunit= sprintf('%02.2f',varunit); 
            end
    elseif isa(varunit,'char')
            varunit = sprintf('%s',varunit); 
    else
%            fprintf([' \nWARNING: Invalid input type for variable',...
%            ' "varunit" in function Verbose\n']);
    end

%% ________________________________________________________________________
   n=l_txt + l_varin; 
   m=strSize-n;
   fprintf([LineStart '%s%-*.*s %s %s'],txt,m,m,strTaper,varin,varunit)
   

end