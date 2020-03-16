function [MDim, MData, MMetadata]=Aquadopp_Parser()
%
% Developped for TOOTSEA 2017
% K. BALEM - LOPS IFREMER
%
% Read .aqd velocity file and call aquadoppVelocityParse from IMOS Toolbox
%
%Calling aquadoppVelocityParse
%%%%%%%%%%%%%%%% GUI RELATIVE
[FileName,PathName,~] = uigetfile('*','Select AQD data File');
if isequal(FileName,0) 
    return; 
end
fname={[PathName FileName]}; 
%%%%%%%%%%%%%%%%

set(gcf, 'pointer', 'watch');
drawnow;

AQST = aquadoppVelocityParse(fname,1);

MDim.Time=AQST.dimensions{1}.data;
MDim.FileName=FileName;
MUnits={};
for i=1:length(AQST.variables)    
    eval(['MData.' AQST.variables{i}.name '= AQST.variables{i}.data;']);        
end      
  
Metalist=fieldnames(AQST.meta);
MMetadata.Properties={};
MMetadata.Values={};
for i=1:length(Metalist)
    if(isstruct(getfield(AQST.meta,Metalist{i}))==0)
     MMetadata.Properties=[MMetadata.Properties; Metalist{i}];
     MMetadata.Values=[MMetadata.Values; {num2str(getfield(AQST.meta,Metalist{i}))}];    
    end        
end

set(gcf, 'pointer', 'arrow');
end

