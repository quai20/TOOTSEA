function [MDim, MData, MMetadata]=Aquapro_Parser()
%
% Developped for TOOTSEA 2019
% K. BALEM - LOPS IFREMER
%
% Read .prf aquadopp profiler file and call aquadoppProfilerParse from IMOS Toolbox
%
%%%%%%%%%%%%%%%% GUI RELATIVE
[FileName,PathName,~] = uigetfile('*','Select PRF data File');
if isequal(FileName,0) 
    return; 
end
fname={[PathName FileName]}; 
%%%%%%%%%%%%%%%%

set(gcf, 'pointer', 'watch');
drawnow;

AQST = aquadoppProfilerParse(fname,1);
%BIN MAPPING BASED ON IMOS TOOLBOX
AQST_BinMapped = adcpBinMappingPP({AQST}, 'raw', 1 );
AQST = AQST_BinMapped{1};

MDim.Time=AQST.dimensions{1}.data;
MDim.BinDepth=AQST.dimensions{2}.data;
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

