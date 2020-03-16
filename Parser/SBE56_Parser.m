function [MDim, MData, MMetadata]=SBE56_Parser()
%
% Developped for TOOTSEA 2017
% K. BALEM - LOPS IFREMER
%
% Read CNV or CSB File by calling SBE56Parse function from IMOS Toolbox
%
%%%%%%%%%%%%%%%% GUI RELATIVE
[FileName,PathName,~] = uigetfile('*','Select SBE data File');
if isequal(FileName,0) 
    return; 
end
fname=[PathName FileName]; 
%%%%%%%%%%%%%%%%

set(gcf, 'pointer', 'watch');
drawnow;

SBST=SBE56Parse({fname},1);

MDim.Time=SBST.dimensions{1}.data;
MDim.FileName=FileName;

for i=1:length(SBST.variables)    
    eval(['MData.' SBST.variables{i}.name '= SBST.variables{i}.data;']);      
end      
    
Metalist=fieldnames(SBST.meta);
MMetadata.Properties={};
MMetadata.Values={};
for i=1:length(Metalist)
    if(isstruct(getfield(SBST.meta,Metalist{i}))==0)
     MMetadata.Properties=[MMetadata.Properties; Metalist{i}];
     MMetadata.Values=[MMetadata.Values; {num2str(getfield(SBST.meta,Metalist{i}))}];    
    end        
end

set(gcf, 'pointer', 'arrow');
end

