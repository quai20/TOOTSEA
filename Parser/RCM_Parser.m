function [MDim, MData, MMetadata]=RCM_Parser()
%
% Developped for TOOTSEA 2017
% K. BALEM - LOPS IFREMER
%
% Read .Asc (from instrument) and .conf (build with coef and param) files
%
%%%%%%%%%%%%%%%% GUI RELATIVE
[FileName,PathName,~] = uigetfile('*.Asc','Select RCM data File');
if isequal(FileName,0) 
    return; 
end
fname=[PathName FileName]; 
%%%%%%%%%%%%%%%%
[ConfName,PathName,~] = uigetfile('*.conf','Select Conf File');
if isequal(ConfName,0) 
    return; 
end
cfname=[PathName ConfName]; 
%%%%%%%%%%%%%%%%

set(gcf, 'pointer', 'watch');
drawnow;

%hh=load(fname);
fid=fopen(fname,'r');
gg=[];
firstline=1;
%READ FIRST
tline=fgetl(fid);
while ischar(tline)    
    if(~isempty(tline))      
      numline=str2num(tline);
      if(numline(1) ~= 7)
        gg=[gg;numline];
      end
      if(firstline==1)
        start_date=datenum(numline(2)+2000,numline(3),numline(4),numline(5),numline(6),0);
      end
      firstline=0;
    end
    tline=fgetl(fid);      
end
fclose(fid);

for i=1:length(gg)
 TT.time(i)=start_date+(i-1)*1/24;   
end

%read conf file to get names & coef
fid2=fopen(cfname,'r');
line=fgetl(fid2);
i=1;
while (ischar(line) && ~isempty(line))
   CC=regexp(line,'(\w*)\s*(.*)','tokens'); 
   coef=str2num(CC{1}{2});
   eval(['MData.' CC{1}{1} ' = polyval(coef,gg(:,i));' ])    
   i=i+1;
   line=fgetl(fid2);
end
fclose(fid2);

MDim.Time=TT.time;
MDim.FileName=FileName;

MMetadata.Properties = {};
MMetadata.Values = {};

set(gcf, 'pointer', 'arrow');

