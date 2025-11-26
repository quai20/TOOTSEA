%
% Create a netcdf file gathering data from all instrument
% separated netcdf files, with configuration of sampling 
% and filtering.
% K. Balem - LOPS / IFREMER - 2018
% coded for RREX project
%
clear; clc;
%GLOBAl
opath='~/Bureau/Swotalis/MOORING_DATA/PROCESSING_KEVIN/M1';                    %<============================
outName='TEST_4_START.nc';        %<============================
writenc=1; %write netcdf automatically
%TIME
tstep=1/24;
datearray=datenum(2023,03,18,12,00,00):tstep:datenum(2023,11,25,12,00,00);   %<============================
NDAYS=length(datearray);
%LEVELS
NB_LEVELS=32;        %<============================
%VARS
%VARS={'PRES','TEMP','CNDC','PSAL','DEPTH'};                %<============================
VARS={'DEPTH','UCUR','VCUR','WCUR','CSPD','CDIR'};   %<==============AAA==============
lat=-23.4833; 
lon=167.34286;

%%%%%%%%%%% NOTHING TO CHANGE AFTER THAT IN THEORY

%INIT VARS & QC
for i=1:length(VARS)
   eval([VARS{i} '=zeros(NB_LEVELS,NDAYS)*NaN;']);    
   eval([VARS{i} '_QC=zeros(NB_LEVELS,NDAYS);']);    
end

%GO GO GO : WHILE STOPPED WHEN USER CANCEL UI INPUT
while(1)
    
   [FileName,PathName,~] = uigetfile([opath '*.nc'],'Select nc file');
   %EMPTY FILENAME
    if isequal(FileName,0) 
        break; 
    end
    fname=[PathName FileName];  
    disp(fname);
    %GET INFO FROM NC FILE
    finfo = ncinfo(fname);
    %BUILD PARAMLIST
    ParamList={};
    for i=1:length(finfo.Variables)
        ParamList{i}=finfo.Variables(i).Name;
    end
    [indx,tf] = listdlg('PromptString','Select var :','SelectionMode','multiple','ListString',ParamList);
    if(tf==0)
        break;
    end    
    %TIME SETUP
    dtim=ncread(fname,'TIME')+datenum(1950,1,1,0,0,0);
    dt=round((dtim(2)-dtim(1))*24*3600);
    %GO THROUGHT EACH VAR
    for k=1:length(indx) 
        data=ncread(fname,ParamList{indx(k)});
        if(strcmp(ParamList{indx(k)},'BINPRES') || strcmp(ParamList{indx(k)},'BINDEPTH') || strcmp(ParamList{indx(k)},'DEPTH'))
            datq=ncread(fname,'DEPTH_QC');
        else
            datq=ncread(fname,[ParamList{indx(k)} '_QC']);
        end       
        %TRANSP IF NECESS
        if(size(data,1)>size(data,2)) data=data'; end
        if(size(datq,1)>size(datq,2)) datq=datq'; end
        
        if(size(data,1)>1)
            [indL,tL] = listdlg('PromptString',[ParamList{indx(k)} ' levels'],'SelectionMode','multiple','ListString',num2str([1:size(data,1)]'));
            levels=indL;
        else
            levels=1;
        end
        %GO THROUGHT EACH LEVEL OF VAR AND FILTER
        datd=[];
        for nl=levels %1:size(data,1)            
            %DISP CHECK
            disp(['VAR ',ParamList{indx(k)},' - Lev ',num2str(nl)]);
            %
            ld_data=data(nl,:);
            if(size(datq,1)>1)
                ld_datq=datq(nl,:);
            else
                ld_datq=datq(1,:);
            end
            %NaNify bad data
            ld_data(ld_datq==4)=NaN;    
            ld_dat0=ld_data; %saved for futur comparison
            %Sliding mean NaN values before filtering            
            ind=find(isnan(ld_data));
            sldv=(48*60*60)/dt;       % THIS IS IMPORTANT, SIZE OF SLIDING WINDOW ... 
            for j=1:length(ind)
                if(ind(j)<=sldv) a=1; else a=ind(j)-sldv; end
                if(ind(j)>=length(ld_data)-sldv) b=length(ld_data); else b=ind(j)+sldv; end
                mint=ld_data(a:b);
                ld_data(ind(j))=mean(mint(~isnan(mint)));
            end
            %Filter        
            Tc=(3600*24*2*tstep);             
            %[ld_datf,~,~,~,~]=Lanczosfilter(ld_data,dt,1/Tc,100000,'low');
            if((1/Tc)/((1/dt)/2)==1)
                cut=0.99;
            else
                cut=(1/Tc)/((1/dt)/2);
            end
            [bf,af] = butter(3,cut);
            ld_datf=filtfilt(bf,af,double(ld_data));
            %Decimation            
            [Ct,ia,ic] = unique(dtim);        
            datd(nl,:)=interp1(Ct,ld_datf(ia),datearray);            
            %NaN alone points (no data in the +-tstep around it)
            for n=1:length(datd(nl,:))
                indZX=(dtim>datearray(n)-tstep & dtim<datearray(n)+tstep);
                if(sum(~isnan(ld_dat0(indZX)))<= 3 ) % NOT CLEAR WICH VALUE I HAVE TO PUT HERE ... 
                    if n==1
                        datd(nl,[n,n+1])=NaN;
                    elseif n==length(datd(nl,:))
                        datd(nl,[n-1,n])=NaN;
                    else
                        datd(nl,[n-1,n,n+1])=NaN;
                    end
                end
            end     
        end 
        [indy,tb] = listdlg('PromptString',[ParamList{indx(k)} '(' num2str(size(datd)) ') -> VAR ?'],...
        'SelectionMode','single','ListString',VARS);    
        if(tb==0)
            break;
        end
        [indz,tc] = listdlg('PromptString',[ParamList{indx(k)} '(' num2str(size(datd)) ') -> LEVEL ?'],...
        'SelectionMode','multiple','ListString',num2str([1:NB_LEVELS]'));
        if(tc==0)
            break;
        end         
        %ASSIGN
        %le fliplr qui sert à retourner les niveaux car dans
        %le fichier adcp, niveau 1 = bottom, et dans le fichier
        %mouillage, niveau 1 = surface.
        if(size(data,1)>1)
            choice = questdlg('Flip Cells ?','','Keep order','Flip Array','Keep order');
            switch choice
                case 'Keep order'
                    disp(['ASSIGN TO : ' VARS{indy} ' - LEV : ' num2str(indz)]);
                    eval([VARS{indy} '([' num2str(indz) '],:)=datd;']);       
                case 'Flip Array'
                    disp(['ASSIGN TO : ' VARS{indy} ' - LEV : ' num2str(fliplr(indz))]);
                    eval([VARS{indy} '([' num2str(fliplr(indz)) '],:)=datd;']);       
            end            
        else
            disp(['ASSIGN TO : ' VARS{indy} ' - LEV : ' num2str(indz)]);
            eval([VARS{indy} '([' num2str(indz) '],:)=datd;']);       
        end    
        
    end       
end

if(writenc)
    %WRITE NC FILE
    %GO GO GO
    % Open the file to write
    nc = netcdf.create(outName,'64BIT_OFFSET');
    netcdf.close(nc)
    % ----------------------------+
    %   Write global attributes   |
    % ----------------------------+    
    ncwriteatt(outName,'/','data_type', 'OceanSITES time-series data');
    %ncwriteatt(outName,'/','site_code', Mooring);
    %ncwriteatt(outName,'/','platform_code', Mooring);
    ncwriteatt(outName,'/','data_mode', 'D');
    %ncwriteatt(outName,'/','title', [Mooring ' mooring file']);
    ncwriteatt(outName,'/','summary', 'This file gathers all mooring instruments data, filtered and decimated. See eulerian data report for details.');
    %ncwriteatt(outName,'/','principal_investigator', 'Virginie Thierry');
    %ncwriteatt(outName,'/','principal_investigator_email', 'Virginie.Thierry@ifremer.fr');
    ncwriteatt(outName,'/','institution', 'IFREMER');
    ncwriteatt(outName,'/','project', 'SWOTALIS');
    ncwriteatt(outName,'/','keywords', 'SWOTALIS,SWOT,moorings,adcp,microcat,aquadopp,currentmeters,concerto');
    %
    %ncwriteatt(outName,'/','area', 'North Atlantic Ocean');
    ncwriteatt(outName,'/','geospatial_lat_min', num2str(lat));
    ncwriteatt(outName,'/','geospatial_lon_min', num2str(lon));
    ncwriteatt(outName,'/','geospatial_lat_max', num2str(lat));
    ncwriteatt(outName,'/','geospatial_lon_max', num2str(lon));
    %ncwriteatt(outName,'/','geospatial_vertical_min', num2str(min(DEPTH(1,:))));
    %ncwriteatt(outName,'/','geospatial_vertical_max', num2str(max(DEPTH(end,:))));
    ncwriteatt(outName,'/','time_coverage_start', datestr(datearray(1),'yyyy-mm-ddTHH:MM:SSZ'));
    ncwriteatt(outName,'/','time_coverage_end', datestr(datearray(end),'yyyy-mm-ddTHH:MM:SSZ'));
    %
    ncwriteatt(outName,'/','format_version', '1.3');
    ncwriteatt(outName,'/','Conventions','CF-1.6,OceanSITES-1.3,ACDD-1.2');    
    %
    ncwriteatt(outName,'/','publisher_name', 'Kevin Balem');
    ncwriteatt(outName,'/','publisher_email', 'Kevin.Balem@ifremer.fr');
    ncwriteatt(outName,'/','update_interval', 'void');       
    %
    ncwriteatt(outName,'/','date_created', datestr(datenum(2023,02,02),'yyyy-mm-ddTHH:MM:SSZ'));
    ncwriteatt(outName,'/','date_modified', datestr(now,'yyyy-mm-ddTHH:MM:SSZ'));
    %ncwriteatt(outName,'/','contributor_name','Virginie Thierry, Kevin Balem, Pascale LHerminier, Herle Mercier, Pierre Branellec');
    %
    % --------------------------------------+
    %   Write coordinate variables          |
    % --------------------------------------+
    
    nccreate(outName,'TIME', 'Dimensions',{'TIME',NDAYS}, 'Datatype','double');
    ncwrite(outName,'TIME', double(datearray-datenum(1950,1,1,0,0,0)));
    ncwriteatt(outName,'TIME', 'standard_name','time');
    ncwriteatt(outName,'TIME', 'units','days since 1950-01-01T00:00:00Z');
    ncwriteatt(outName,'TIME', 'axis','T');
    ncwriteatt(outName,'TIME', 'long_name','time of measurement');
    ncwriteatt(outName,'TIME', 'valid_min', single(0));
    ncwriteatt(outName,'TIME', 'valid_max', single(90000));
    
    nccreate(outName,'LATITUDE', 'Dimensions',{'LATITUDE',1}, 'Datatype','single');
    ncwrite(outName,'LATITUDE', single(lat));
    ncwriteatt(outName,'LATITUDE', 'standard_name','latitude');
    ncwriteatt(outName,'LATITUDE', 'units','degrees_north');
    ncwriteatt(outName,'LATITUDE', 'axis','Y');
    ncwriteatt(outName,'LATITUDE', 'long_name','Latitude of each location');
    ncwriteatt(outName,'LATITUDE', 'reference','WGS84');
    ncwriteatt(outName,'LATITUDE', 'valid_min',-90);
    ncwriteatt(outName,'LATITUDE', 'valid_max',90);
    
    nccreate(outName,'LONGITUDE', 'Dimensions',{'LONGITUDE',1}, 'Datatype','single');
    ncwrite(outName,'LONGITUDE', single(lon));
    ncwriteatt(outName,'LONGITUDE', 'standard_name','longitude');
    ncwriteatt(outName,'LONGITUDE', 'units','degrees_east');
    ncwriteatt(outName,'LONGITUDE', 'axis','X');
    ncwriteatt(outName,'LONGITUDE', 'long_name','Longitude of each location');
    ncwriteatt(outName,'LONGITUDE', 'reference','WGS84');
    ncwriteatt(outName,'LONGITUDE', 'valid_min',-180);
    ncwriteatt(outName,'LONGITUDE', 'valid_max',180);
    
    %VARS
    %SEARCH PROPERTIES IN DB
    OSP=load('OC_params.mat');
    for k=1:length(VARS)
        oinn=find(strcmp(OSP.PARAM,VARS{k}));
        if(~isempty(oinn))
            PROPS(k).Unit=OSP.UNIT{(oinn)};
            PROPS(k).Long_name=OSP.LONGNAME{(oinn)};
            PROPS(k).FillValue=OSP.FILLVALUE(oinn);
            PROPS(k).ValidMin=OSP.MIN(oinn);
            PROPS(k).ValidMax=OSP.MAX(oinn);
        end
    end
    %WRITE
    %VAR
    for k=1:length(VARS)
        %VAR
        nccreate(outName,VARS{k}, 'Dimensions',{'N_LEVELS',NB_LEVELS,'TIME',NDAYS});         
        ncwriteatt(outName,VARS{k}, 'long_name',strrep(PROPS(k).Long_name,'_',' '));
        ncwriteatt(outName,VARS{k}, 'standard_name',strrep(PROPS(k).Long_name,' ','_'));
        ncwriteatt(outName,VARS{k}, 'units',PROPS(k).Unit);
        ncwriteatt(outName,VARS{k}, '_FillValue',PROPS(k).FillValue);
        ncwriteatt(outName,VARS{k}, 'valid_min',PROPS(k).ValidMin);
        ncwriteatt(outName,VARS{k}, 'valid_max',PROPS(k).ValidMax);
        if(strcmp(VARS{k},'DEPTH'))
            ncwriteatt(outName,VARS{k}, 'axis','Z');
        end
        eval(['ncwrite(outName,VARS{k}, double(' VARS{k} '));']);               
        %QC
        nccreate(outName,[VARS{k} '_QC'], 'Dimensions',{'N_LEVELS',NB_LEVELS,'TIME',NDAYS},'Datatype','int8');        
        ncwriteatt(outName,[VARS{k} '_QC'], 'long_name','quality flag');      
        ncwriteatt(outName,[VARS{k} '_QC'], 'conventions','OceanSites reference table 2');      
        ncwriteatt(outName,[VARS{k} '_QC'], '_FillValue',int8(-128));
        ncwriteatt(outName,[VARS{k} '_QC'], 'valid_min',int8(0));
        ncwriteatt(outName,[VARS{k} '_QC'], 'valid_max',int8(9));
        ncwriteatt(outName,[VARS{k} '_QC'], 'flag_values',int8(0:9));
        ncwriteatt(outName,[VARS{k} '_QC'], 'flag_meanings',...
        'unknown good_data probably_good_data potentially_correctable_bad_data bad_data nominal_value interpolated_value missing_value');             
        eval(['ncwrite(outName,[VARS{k} ''_QC''], double(' VARS{k} '_QC));']);               
    end       
    %END
end
