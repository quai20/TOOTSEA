function [MDim, MData, MMetadata]=Concerto_Parser()
%
% Developped for TOOTSEA 2024
% K. BALEM - LOPS IFREMER
%
% Read RSK file with RSKTOOLS by RBR
%
%%%%%%%%%%%%%%%% GUI RELATIVE
[FileName,PathName,~] = uigetfile('*','Select RSK data File');
if isequal(FileName,0) 
    return; 
end
fname=[PathName FileName]; 
%%%%%%%%%%%%%%%%

set(gcf, 'pointer', 'watch');
drawnow;

rsk = RSKopen(fname);
rsk = RSKreaddata(rsk);

MDim.Time= rsk.data.tstamp;
MDim.FileName=FileName;

for i=1:length(rsk.channels)    
    eval(['MData.' rsk.channels(i).shortName '= rsk.data.values(:,i);']);  
    
end      
    
Metalist=fieldnames(rsk.instruments);
MMetadata.Properties={};
MMetadata.Values={};
for i=1:length(Metalist)
    if(isstruct(getfield(rsk.instruments,Metalist{i}))==0)
     MMetadata.Properties=[MMetadata.Properties; Metalist{i}];
     MMetadata.Values=[MMetadata.Values; {num2str(getfield(rsk.instruments,Metalist{i}))}];    
    end        
end

set(gcf, 'pointer', 'arrow');
end
