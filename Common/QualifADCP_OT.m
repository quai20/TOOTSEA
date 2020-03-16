%load('/home4/homedir4/perso/kbalem/TOOTSEA_b2/RREX_MOORINGS/PROCESS/ICE/mat/WH75_SN881.mat');
tic;
ToQualif={'UCUR','VCUR','CDIR','CSPD'};
% READ CONFIGURATION FILE
fid=fopen('Common/autoqc_conf.txt','r');
for i=1:6 %QC NuMBER
    line=fgetl(fid); %--------------------
    line=fgetl(fid); %#QC TITLE
    qc_file{i}=fgetl(fid); %filename
    if(i==5)
        qc_conf(i).parm=sscanf(fgetl(fid),'%d/%d/%d-%d:%d:%d %d/%d/%d-%d:%d:%d'); %test conf
    elseif (i==6)
        qc_conf(i).parm=textscan(fgetl(fid),'%s'); %test conf
        qc_conf(i).parm=qc_conf(i).parm{1};
    else
        qc_conf(i).parm=str2num(fgetl(fid)); %test conf
    end
    qc_conf(i).val=str2num(fgetl(fid)); %QC values
end
fclose(fid);
%
for i=1:length(ToQualif)
    k=find(strcmp(ParamList,ToQualif{i}));
    disp(ToQualif{i});    
    FinalQC=PARAMETERS(k).QC_Serie;    
    for nv=1:28 %size(PARAMETERS(k).Data,1) %au delà de 28 plus de données.
        % LOOP APPLY QC FUNCTION
        disp(['Level ' num2str(nv)]);
        for j=[4,6]  %QC NUMBER
            hQC_Serie = [];
            disp(qc_file{j});
            eval(['hQC_Serie = ' qc_file{j} ...
                '(qc_conf(j),ParamList,PARAMETERS,k,nv);']);
            % QC CHANGE ONLY IF HIGHER
            for m=1:length(FinalQC(nv,:))
                if(hQC_Serie(m)>FinalQC(nv,m))
                    FinalQC(nv,m)=hQC_Serie(m);
                end
            end
        end
    end
    PARAMETERS(k).QC_Serie = FinalQC;
end

toc;

outfile='/home4/homedir4/perso/kbalem/TOOTSEA_b2/RREX_MOORINGS/PROCESS/ICE/mat/WH75_SN881_BIS.mat';
save(outfile,'ParamList','PARAMETERS','MDim','MMetadata','-v7.3');
disp(['saved in ' outfile]);
