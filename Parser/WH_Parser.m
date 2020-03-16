function [MDim, MData, MMetadata]=WH_Parser()
%
% Developped for TOOTSEA 2017
% K. BALEM - LOPS IFREMER
%
% Read binary WH File and call workhorseParse function from IMOS Toolbox
%
%%%%%%%%%%%%%%%% GUI RELATIVE
[FileName,PathName,~] = uigetfile('*','Select WorkHorse data File');
if isequal(FileName,0) 
    return; 
end
fname=[PathName FileName]; 
%%%%%%%%%%%%%%%%

set(gcf, 'pointer', 'watch');
drawnow;

WHST=workhorseParse(fname);

MDim.Time=WHST.dimensions{1}.data;
MDim.BinDepth=WHST.dimensions{2}.data;
MDim.FileName=FileName;

for i=1:length(WHST.variables)   
    eval(['MData.' WHST.variables{i}.name '= WHST.variables{i}.data;']);        
end      
    
Metalist=fieldnames(WHST.meta);
MMetadata.Properties={};
MMetadata.Values={};
for i=1:length(Metalist)
    if(isstruct(getfield(WHST.meta,Metalist{i}))==0)
     MMetadata.Properties=[MMetadata.Properties; Metalist{i}];
     MMetadata.Values=[MMetadata.Values; {num2str(getfield(WHST.meta,Metalist{i}))}];    
    end        
end

set(gcf, 'pointer', 'arrow');
end

