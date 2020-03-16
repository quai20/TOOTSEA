function [MDim, MData, MUnits, MMetadata]=Aquadopp()
%
%Read Aquadopp velocity file
%%%%%%%%%%%%%%%% GUI RELATIVE
[FileName,PathName,~] = uigetfile('*.aqd','Select Aquadopp velocity data File');
if isequal(FileName,0) 
    return; 
end
fname=[PathName FileName]; 
%%%%%%%%%%%%%%%%

set(gcf, 'pointer', 'watch');
drawnow;

fid=fopen(fname,'rb');
tout=fread(fid,inf,'*uint8');
fclose(fid);

tout=double(tout);

% ind=1;Ptypes=[];
% while ((ind<length(tout)) && (tout(ind)==hex2dec('A5')))
%     sz=2*(tout(ind+2)+tout(ind+3)*256);
%     if ~ismember(tout(ind+1),Ptypes)
%         fprintf('%02X %02X: %d \n',[tout(ind) tout(ind+1) sz]);
%         Ptypes(end+1)=tout(ind+1);
%     end
%     ind=ind+sz;
% end

idebA505=strfind(tout',[hex2dec('A5') hex2dec('05') hex2dec('18') hex2dec('00')]);
idebA504=strfind(tout',[hex2dec('A5') hex2dec('04') hex2dec('70') hex2dec('00')]);
idebA500=strfind(tout',[hex2dec('A5') hex2dec('00') hex2dec('00') hex2dec('01')]);
idebA501=strfind(tout',[hex2dec('A5') hex2dec('01') hex2dec('15') hex2dec('00')]);
idebA506=strfind(tout',[hex2dec('A5') hex2dec('06') hex2dec('12') hex2dec('00')]);
idebA580=strfind(tout',[hex2dec('A5') hex2dec('80') hex2dec('15') hex2dec('00')]);

DataA505=zeros( 48,length(idebA505));
DataA504=zeros(224,length(idebA504));
DataA500=zeros(512,length(idebA500));
DataA501=zeros(42 ,length(idebA501));
DataA506=zeros(36 ,length(idebA506));
DataA580=zeros(42 ,length(idebA580));

for u=1:length(idebA505)
    DataA505(:,u)=tout(idebA505(u):idebA505(u)+47)';
end
for u=1:length(idebA504)
    DataA504(:,u)=tout(idebA504(u):idebA504(u)+223)';
end
for u=1:length(idebA500)
    DataA500(:,u)=tout(idebA500(u):idebA500(u)+511)';
end
for u=1:length(idebA501)
    DataA501(:,u)=tout(idebA501(u):idebA501(u)+41)';
end
for u=1:length(idebA506)
    DataA506(:,u)=tout(idebA506(u):idebA506(u)+35)';
end
for u=1:length(idebA580)
    DataA580(:,u)=tout(idebA580(u):idebA580(u)+41)';
end

V.HWConfig   =ParseHWConfig(DataA505);
V.HeadConfig =ParseHeadConfig(DataA504);
V.UserConfig =ParseUserConfig(DataA500);
V.Velocity   =ParseVelocityData(DataA501);
V.DiagHeaders=ParseDiagnosticsHeader(DataA506);
V.DiagData   =ParseVelocityData(DataA580);

%%%%%%%%%%%%%%% GUI RELATIVE
MDim.Time=V.Velocity.Time;
MDim.FileName=FileName;

MData.TEMP=V.Velocity.Temperature;
MData.PRES=V.Velocity.Pressure;
MData.UCUR=V.Velocity.Vel(1,:);
MData.VCUR=V.Velocity.Vel(2,:);
MData.WCUR=V.Velocity.Vel(3,:);
MData.PITCH=V.Velocity.Pitch;
MData.ROLL=V.Velocity.Roll;
MData.HEAD=V.Velocity.Heading;
MData.SNDSPEED=V.Velocity.SoundSpeed;

MUnits={'degrees_Celius','decibar','meter per second','meter per second','meter per second','degrees','degrees','degrees','meter per second'};

MMetadata.Properties = {};
MMetadata.Values = {};

set(gcf, 'pointer', 'arrow');
%%%%%%%%%%%%%%%

return

function V=ParseHWConfig(tout)
    V.Size       =ChampUInt16(tout(3:4))*2;
    V.SerialNo   =char(tout(5:18)');
    V.BoardConfig=ChampUInt16(tout(19:20));
    V.BoardFreq  =ChampUInt16(tout(21:22));
    V.PICVersion =ChampUInt16(tout(23:24));
    V.HWRevision =ChampUInt16(tout(25:26));
    V.RecSize    =ChampUInt16(tout(27:28))*65536;
    V.Status     =ChampUInt16(tout(29:30));
    V.FWVersion  =ChampUInt16(tout(43:44));

    V.ChkSum     =mod(ChampUInt16(tout(47:48))-hex2dec('b58C')-sum(ChampUInt16(tout(1:46))),65536);
return


function V=ParseHeadConfig(tout)
    V.Size       =ChampUInt16(tout(3:4))*2;
    V.HeadConfig =ChampUInt16(tout(5:6));
    V.HeadFreq   =ChampUInt16(tout(7:8));
    V.HeadType   =ChampUInt16(tout(9:10));
    V.SerialNo   =char(tout(11:22)');
    V.SystemData =tout(23:198);
    V.NBeams     =ChampUInt16(tout(221:222));

    V.ChkSum     =mod(ChampUInt16(tout(223:224))-hex2dec('b58C')-sum(ChampUInt16(tout(1:222))),65536);
return

function V=ParseUserConfig(tout)
    V.Size        =ChampUInt16(tout( 3: 4))*2;
    V.XmitLen     =ChampUInt16(tout( 5: 6));
    V.BlnkDstnc   =ChampUInt16(tout( 7: 8));
    V.RcvLen      =ChampUInt16(tout( 9:10));
    V.Tpp         =ChampUInt16(tout(11:12));
    V.Tpb         =ChampUInt16(tout(13:14));
    V.NPings      =ChampUInt16(tout(15:16));
    V.AvgInt      =ChampUInt16(tout(17:18));
    V.NBeams      =ChampUInt16(tout(19:20));
    V.TmgCntrl    =dec2hex(ChampUInt16(tout(21:22)));
    V.PowCntrl    =dec2hex(ChampUInt16(tout(23:24)));
    V.CompassRate =ChampUInt16(tout(31:32));
    V.CoordXForm  =dec2hex(ChampUInt16(tout(33:34)));
    V.NBins       =ChampUInt16(tout(35:36));
    V.BinLength   =ChampUInt16(tout(37:38));
    V.MeasInt     =ChampUInt16(tout(39:40));
    V.DeployName  =char(tout(41:46)');
    V.WrapMode    =dec2hex(ChampUInt16(tout(47:48)));
    V.StartTime   =ParseTimeStruct(tout(49:54));
    V.DiagInt     =ChampUInt32(tout(55:58));
    V.Mode        =dec2hex(ChampUInt16(tout(59:60)));
    V.AdjSoundSpd =ChampUInt16(tout(61:62));
    V.NSampDiag   =ChampUInt16(tout(63:64));
    V.NBeamsDiag  =ChampUInt16(tout(65:66));
    V.NPingsDiag  =ChampUInt16(tout(67:68));
    V.ModeTest    =dec2hex(ChampUInt16(tout(69:70)));
    V.AnaInAddr   =ChampUInt16(tout(71:72));
    V.SWVer       =ChampUInt16(tout(73:74));
    V.VelAdjTable =ChampUInt16(tout(77:256));
    V.Comments    =char(tout(257:436)');
    V.WaveMode    =dec2hex(ChampUInt16(tout(437:438)));
    V.DynPercPos  =ChampUInt16(tout(439:440));
    V.WvXmitLen   =ChampUInt16(tout(441:442));
    V.WvBlnkDstnc =ChampUInt16(tout(443:444));
    V.WvCellSize  =ChampUInt16(tout(445:446));
    V.WvNPingsDiag=ChampUInt16(tout(447:448));
    V.AnaOutScale =ChampUInt16(tout(457:458));
    V.CorrThresh  =ChampUInt16(tout(459:460));
    V.XmitLen2    =ChampUInt16(tout(463:464));
    V.FilterConst =ChampUInt16(tout(495:510));

    V.ChkSum     =mod(ChampUInt16(tout(511:512))-hex2dec('b58C')-sum(ChampUInt16(tout(1:510))),65536);
return

function V=ParseVelocityData(tout)
    sz   =(tout(3)+256*tout(4))*2;
    igood=find(tout(1,:)==hex2dec('A5'));
    tout=tout(:,igood);

    V.Time       =ParseTimeStruct(tout(5:10,:));
    V.Error      =ChampUInt16(tout(11:12,:));
    V.AnaIn1     =ChampInt16(tout(13:14,:));
    V.Battery    =ChampUInt16(tout(15:16,:))*0.1;
    V.SoundSpeed =ChampUInt16(tout(17:18,:))*0.1;
    V.Heading    =ChampInt16(tout(19:20,:))*0.1;
    V.Pitch      =ChampInt16(tout(21:22,:))*0.1;
    V.Roll       =ChampInt16(tout(23:24,:))*0.1;
    V.Pressure   =(tout(25,:)*65536+ChampUInt16(tout(27:28,:)))*0.001;
    V.Status     =tout(26,:);
    V.Temperature=ChampInt16(tout(29:30,:))*0.01;
    V.Vel        =ChampInt16(tout(31:36,:))*0.001;
    V.Amp        =tout(37:39,:);
return

function V=ParseDiagnosticsHeader(tout)
    sz   =(tout(3)+256*tout(4))*2;
    igood=find(tout(1,:)==hex2dec('A5'));
    tout=tout(:,igood);

    V.Records    =ChampUInt16(tout(5:6,:));
    V.Cell       =ChampUInt16(tout(7:8,:));
    V.Noise      =tout(9:12,:);
    V.ProcMagn   =ChampUInt16(tout(13:20,:));
    V.Distance   =ChampUInt16(tout(21:28,:));
return


function V=ParseTimeStruct(tout)
    min =double(bitshift(tout(1,:),-4)*10+bitand(tout(1,:),15));
    sec =double(bitshift(tout(2,:),-4)*10+bitand(tout(2,:),15));
    day =double(bitshift(tout(3,:),-4)*10+bitand(tout(3,:),15));
    hour=double(bitshift(tout(4,:),-4)*10+bitand(tout(4,:),15));
    year=double(bitshift(tout(5,:),-4)*10+bitand(tout(5,:),15));
    mon =double(bitshift(tout(6,:),-4)*10+bitand(tout(6,:),15));
    if size(tout,1)==8
        msec=double(tout(7,:))+double(tout(8,:))*256;
    else
        msec=0;
    end
    
    V=datenum([2000+year' mon' day' hour' min' sec'+msec'/1000])';
return

function V=ChampUInt16(tout)
    V=double(tout(2:2:end,:))*256+double(tout(1:2:end,:));
return;

function V=ChampInt16(tout)
    V=double(tout(2:2:end,:))*256+double(tout(1:2:end,:));
    V=mod(V+2^15,2^16)-2^15;
return;

function V=ChampUInt32(tout)
    V=double(tout(4:4:end,:))*256^3+double(tout(3:4:end,:))*256^2+double(tout(2:4:end,:))*256+double(tout(1:4:end,:));
return;

function V=ChampInt32(tout)
    V=double(tout(4:4:end,:))*256^3+double(tout(3:4:end,:))*256^2+double(tout(2:4:end,:))*256+double(tout(1:4:end,:));
    V=mod(V+2^31,2^32)-2^31;
return;

