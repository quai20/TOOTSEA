function [MDim, MData, MMetadata]=Signature_Parser()
%
% Developped for TOOTSEA 2019
% K. BALEM - LOPS IFREMER
%
% Read .prf aquadopp profiler file and call aquadoppProfilerParse from IMOS Toolbox
%
%%%%%%%%%%%%%%%% GUI RELATIVE
[FileName,PathName,~] = uigetfile('*','Select AD2CP data File');
if isequal(FileName,0) 
    return; 
end
fname={[PathName FileName]}; 
%%%%%%%%%%%%%%%%

set(gcf, 'pointer', 'watch');
drawnow;

SGST = signatureParse(fname,1);
%BIN MAPPING BASED ON IMOS TOOLBOX
SGST_BinMapped = adcpBinMappingPP({SGST}, 'raw', 1 );
SGST = SGST_BinMapped{1};

MDim.Time=SGST.dimensions{1}.data;
MDim.BinDepth=SGST.dimensions{2}.data;
MDim.FileName=FileName;
MUnits={};
for i=1:length(SGST.variables)    
    eval(['MData.' SGST.variables{i}.name '= SGST.variables{i}.data;']);        
end      
  
Metalist=fieldnames(SGST.meta);
MMetadata.Properties={};
MMetadata.Values={};
for i=1:length(Metalist)
    if(isstruct(getfield(SGST.meta,Metalist{i}))==0)
     MMetadata.Properties=[MMetadata.Properties; Metalist{i}];
     MMetadata.Values=[MMetadata.Values; {num2str(getfield(SGST.meta,Metalist{i}))}];    
    end        
end

set(gcf, 'pointer', 'arrow');
end

