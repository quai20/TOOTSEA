function [MDim, MData, MMetadata]=SBE3x_Parser()
%
% Developped for TOOTSEA 2017
% K. BALEM - LOPS IFREMER
%
% READ .Asc file, Calling SBE3x (SBE37 or SBE39) from IMOS Toolbox
% For other SBE, other Parser.
%
%%%%%%%%%%%%%%%% GUI RELATIVE
[FileName,PathName,~] = uigetfile('*.asc','Select SBE data File');
if isequal(FileName,0) 
    return; 
end
fname=[PathName FileName]; 
%%%%%%%%%%%%%%%%

set(gcf, 'pointer', 'watch');
drawnow;

SBST=SBE3x(fname,1);

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

