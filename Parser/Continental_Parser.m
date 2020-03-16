function [MDim, MData, MMetadata]=Continental_Parser()
%
% Developped for TOOTSEA 2018
% K. BALEM - LOPS IFREMER
%
% Read binary Continental File (.cpr) and call Continental parse function from IMOS Toolbox
%
%%%%%%%%%%%%%%%% GUI RELATIVE
[FileName,PathName,~] = uigetfile('*.cpr','Select Continetal data File');
if isequal(FileName,0) 
    return; 
end
fname=[PathName FileName]; 
%%%%%%%%%%%%%%%%

set(gcf, 'pointer', 'watch');
drawnow;

CNST=continentalParse({fname},1);

MDim.Time=CNST.dimensions{1}.data;
MDim.BinDepth=CNST.dimensions{2}.data;
MDim.FileName=FileName;

for i=1:length(CNST.variables)   
    eval(['MData.' CNST.variables{i}.name '= CNST.variables{i}.data;']);        
end      
    
Metalist=fieldnames(CNST.meta);
MMetadata.Properties={};
MMetadata.Values={};
for i=1:length(Metalist)
    if(isstruct(getfield(CNST.meta,Metalist{i}))==0)
     MMetadata.Properties=[MMetadata.Properties; Metalist{i}];
     MMetadata.Values=[MMetadata.Values; {num2str(getfield(CNST.meta,Metalist{i}))}];    
    end        
end

set(gcf, 'pointer', 'arrow');
end

