function write_ncfile( UsDat )
%
% WRITE NCFILE function
% 
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
[FileName,PathName,~] = uiputfile('*.nc','Export to nc file',strrep(UsDat.MDim.FileName,'.','-'));
if isequal(FileName,0) 
    return; 
end
file_name=[PathName FileName]; 

set(findall(0,'Type','figure'), 'pointer', 'watch');    

%Vars
latitude=str2num(UsDat.MMetadata.Values{find(strcmp(UsDat.MMetadata.Properties,'Latitude'),1)});
longitude=str2num(UsDat.MMetadata.Values{find(strcmp(UsDat.MMetadata.Properties,'Longitude'),1)});

% Dimensions
TimeDim = length(UsDat.MDim.Time); %C'est le vecteur temps du 1er parametre selectionné (reaffecté dans MDim).
%Mais un test est fait avant pour verifier la coherence entre parametres.

%Nominal depth
%FullDepth = 1;
%VerticalArray=str2num(UsDat.MMetadata.Values{find(strcmp(UsDat.MMetadata.Properties,'Nominal_depth'))});    
%Bin depth
if(isfield(UsDat.MDim,'VerticalDim'))
    BinLenght = length(UsDat.MDim.VerticalDim);
    BinArray=UsDat.MDim.VerticalDim;
end

% Open the file to write
outfile = [file_name];
nc = netcdf.create(outfile,'64BIT_OFFSET');
netcdf.close(nc)

% ----------------------------+
%   Write global attributes   |
% ----------------------------+
%Defined Metadata
for i=1:length(UsDat.MMetadata.Properties)   
ncwriteatt(outfile,'/',UsDat.MMetadata.Properties{i},UsDat.MMetadata.Values{i});
end

% === NC CONVENTIONS ===
ncwriteatt(outfile,'/','format_version', '1.3');
ncwriteatt(outfile,'/','Conventions','CF-1.6,OceanSITES-1.3,ACDD-1.2')
% === PROVENANCE ===
ncwriteatt(outfile,'/','date_modified', datestr(now,'yyyy-mm-ddTHH:MM:SSZ'));
ncwriteatt(outfile,'/','Created from', UsDat.MDim.FileName);

% --------------------------------------+
%   Write coordinate variables          |
% --------------------------------------+

nccreate(outfile,'TIME', 'Dimensions',{'TIME',TimeDim}, 'Datatype','double');
ncwrite(outfile,'TIME', double(UsDat.MDim.Time)- datenum(1950,1,1,0,0,0));
ncwriteatt(outfile,'TIME', 'standard_name','time');
ncwriteatt(outfile,'TIME', 'units','days since 1950-01-01T00:00:00Z');
ncwriteatt(outfile,'TIME', 'axis','T');
ncwriteatt(outfile,'TIME', 'long_name','time of measurement');
ncwriteatt(outfile,'TIME', 'valid_min', single(0));
ncwriteatt(outfile,'TIME', 'valid_max', single(90000));

nccreate(outfile,'LATITUDE', 'Dimensions',{'LATITUDE',1}, 'Datatype','single');
ncwrite(outfile,'LATITUDE', single(latitude));
ncwriteatt(outfile,'LATITUDE', 'standard_name','latitude');
ncwriteatt(outfile,'LATITUDE', 'units','degree_north');
ncwriteatt(outfile,'LATITUDE', 'axis','Y');
ncwriteatt(outfile,'LATITUDE', 'long_name','latitude of measurement');
ncwriteatt(outfile,'LATITUDE', 'reference','WGS84');
ncwriteatt(outfile,'LATITUDE', 'valid_min',-90);
ncwriteatt(outfile,'LATITUDE', 'valid_max',90);

nccreate(outfile,'LONGITUDE', 'Dimensions',{'LONGITUDE',1}, 'Datatype','single');
ncwrite(outfile,'LONGITUDE', single(longitude));
ncwriteatt(outfile,'LONGITUDE', 'standard_name','longitude');
ncwriteatt(outfile,'LONGITUDE', 'units','degree_east');
ncwriteatt(outfile,'LONGITUDE', 'axis','X');
ncwriteatt(outfile,'LONGITUDE', 'long_name','longitude of measurement');
ncwriteatt(outfile,'LONGITUDE', 'reference','WGS84');
ncwriteatt(outfile,'LONGITUDE', 'valid_min',-180);
ncwriteatt(outfile,'LONGITUDE', 'valid_max',180);

% -----------------------------------+
%   Write data variables             |
% -----------------------------------+

if(isfield(UsDat.MDim,'VerticalDim'))
    nccreate(outfile,'DBEAM', 'Dimensions',{'N_LEVELS',BinLenght});       
    ncwriteatt(outfile,'DBEAM', 'long_name','distance along beam');
    ncwriteatt(outfile,'DBEAM', 'standard_name','distance along beam');
    ncwriteatt(outfile,'DBEAM', 'units','meters');
    ncwrite(outfile,'DBEAM', double(BinArray));
end

for i=1:length(UsDat.ParamList_sel)
    
    if(size(UsDat.PARAMETERS_sel(i).Data,1)>1)
        %%%Multilevel        
        %
        nccreate(outfile,UsDat.ParamList_sel{i}, 'Dimensions',{'N_LEVELS',BinLenght,'TIME',TimeDim});       
        ncwriteatt(outfile,UsDat.ParamList_sel{i}, 'long_name',strrep(UsDat.PARAMETERS_sel(i).Long_name,'_',' '));
        ncwriteatt(outfile,UsDat.ParamList_sel{i}, 'standard_name',strrep(UsDat.PARAMETERS_sel(i).Long_name,' ','_'));
        ncwriteatt(outfile,UsDat.ParamList_sel{i}, 'Comment',UsDat.PARAMETERS_sel(i).Comment);
        ncwriteatt(outfile,UsDat.ParamList_sel{i}, 'units',UsDat.PARAMETERS_sel(i).Unit);
        ncwriteatt(outfile,UsDat.ParamList_sel{i}, '_FillValue',UsDat.PARAMETERS_sel(i).FillValue);
        ncwriteatt(outfile,UsDat.ParamList_sel{i}, 'valid_min',UsDat.PARAMETERS_sel(i).ValidMin);
        ncwriteatt(outfile,UsDat.ParamList_sel{i}, 'valid_max',UsDat.PARAMETERS_sel(i).ValidMax);             
        ncwrite(outfile,UsDat.ParamList_sel{i}, double(UsDat.PARAMETERS_sel(i).Data));
        if(UsDat.QC_Choice(i)==1)
        %QC
        nccreate(outfile,[UsDat.ParamList_sel{i} '_QC'], 'Dimensions',{'N_LEVELS',BinLenght,'TIME',TimeDim},'Datatype','int8');        
        ncwriteatt(outfile,[UsDat.ParamList_sel{i} '_QC'], 'long_name','quality flag');      
        ncwriteatt(outfile,[UsDat.ParamList_sel{i} '_QC'], 'conventions','OceanSites reference table 2');      
        ncwriteatt(outfile,[UsDat.ParamList_sel{i} '_QC'], '_FillValue',int8(-128));
        ncwriteatt(outfile,[UsDat.ParamList_sel{i} '_QC'], 'valid_min',int8(0));
        ncwriteatt(outfile,[UsDat.ParamList_sel{i} '_QC'], 'valid_max',int8(9));
        %ncwriteatt(outfile,[UsDat.ParamList_sel{i} '_QC'], 'flag_values','0b,1b,2b,3b,4b,5b,6b,7b,8b,9b');
        ncwriteatt(outfile,[UsDat.ParamList_sel{i} '_QC'], 'flag_values',int8(0:9));
        ncwriteatt(outfile,[UsDat.ParamList_sel{i} '_QC'], 'flag_meaning',...
        'no_qc_performed good_data probably_good_data bad_data_that_are_potentially_correctable bad_data value_changed not_used nominal_value interpolated_value missing_value');      
        ncwrite(outfile,[UsDat.ParamList_sel{i} '_QC'], double(UsDat.PARAMETERS_sel(i).QC_Serie));
        end
    else
        %%%Singlevel
        nccreate(outfile,UsDat.ParamList_sel{i}, 'Dimensions',{'TIME',TimeDim});        
        ncwriteatt(outfile,UsDat.ParamList_sel{i}, 'long_name',strrep(UsDat.PARAMETERS_sel(i).Long_name,'_',' '));
        ncwriteatt(outfile,UsDat.ParamList_sel{i}, 'standard_name',strrep(UsDat.PARAMETERS_sel(i).Long_name,' ','_'));
        ncwriteatt(outfile,UsDat.ParamList_sel{i}, 'Comment',UsDat.PARAMETERS_sel(i).Comment);
        ncwriteatt(outfile,UsDat.ParamList_sel{i}, 'units',UsDat.PARAMETERS_sel(i).Unit);
        ncwriteatt(outfile,UsDat.ParamList_sel{i}, '_FillValue',UsDat.PARAMETERS_sel(i).FillValue);
        ncwriteatt(outfile,UsDat.ParamList_sel{i}, 'valid_min',UsDat.PARAMETERS_sel(i).ValidMin);
        ncwriteatt(outfile,UsDat.ParamList_sel{i}, 'valid_max',UsDat.PARAMETERS_sel(i).ValidMax);
        if(strcmp(UsDat.ParamList_sel{i},'DEPTH'))
            ncwriteatt(outfile,UsDat.ParamList_sel{i}, 'axis','Z');
        end
        ncwrite(outfile,UsDat.ParamList_sel{i}, double(UsDat.PARAMETERS_sel(i).Data));
        
        if(UsDat.QC_Choice(i)==1)
        %QC 
        nccreate(outfile,[UsDat.ParamList_sel{i} '_QC'], 'Dimensions',{'TIME',TimeDim},'Datatype','int8');        
        ncwriteatt(outfile,[UsDat.ParamList_sel{i} '_QC'], 'long_name','quality flag');      
        ncwriteatt(outfile,[UsDat.ParamList_sel{i} '_QC'], 'conventions','OceanSites reference table 2');      
        ncwriteatt(outfile,[UsDat.ParamList_sel{i} '_QC'], '_FillValue',int8(-128));
        ncwriteatt(outfile,[UsDat.ParamList_sel{i} '_QC'], 'valid_min',int8(0));
        ncwriteatt(outfile,[UsDat.ParamList_sel{i} '_QC'], 'valid_max',int8(9));
        %ncwriteatt(outfile,[UsDat.ParamList_sel{i} '_QC'], 'flag_values','0b,1b,2b,3b,4b,5b,6b,7b,8b,9b');
        ncwriteatt(outfile,[UsDat.ParamList_sel{i} '_QC'], 'flag_values',int8(0:9));
        ncwriteatt(outfile,[UsDat.ParamList_sel{i} '_QC'], 'flag_meaning',...
        'no_qc_performed good_data probably_good_data bad_data_that_are_potentially_correctable bad_data value_changed not_used nominal_value interpolated_value missing_value');          
        ncwrite(outfile,[UsDat.ParamList_sel{i} '_QC'], double(UsDat.PARAMETERS_sel(i).QC_Serie));
        end
    end
    
end

set(findall(0,'Type','figure'), 'pointer', 'arrow');    
msgbox([file_name ' created']);

end




