function RSK2ODV(RSK, varargin)

% RSK2ODV - Creates one or multiple Ocean Data View (ODV) output from a RSK
% structure.
%
% Syntax: RSK2ODV(RSK, [OPTIONS])
%
% RSK2ODV outputs the RSK structure format into ODV (txt) file(s). The ODV
% file contains some logger metadata and a row of variable names and units 
% above each column of channel data.  If the data has been parsed into 
% profiles, then one file will be written for each profile. Furthermore, 
% an extra column called 'cast_direction' will be included, where 'd' 
% indicates downcast while 'u' indicates upcast.
% 
% Notes: Cruise, station, longitude, latitude and bottom depth are set to 
% `C1`, `S1`, `0.0`, `0.0` and `0.0` respectively as default. They will be 
% filled automatically with Ruskin annotations if they were added by the 
% user. Alternatively, they can be populated with RSKaddstationdata.m.
% 
% Output samples as below:
%
% //<Creator>RBR</Creator>
% //<CreateTime>30-Nov-2017 17:20:01</CreateTime>
% //<Software>RSKtools</Software>
% //<Source></Source>
% //<SourceLast-Modified></SourceLast-Modified>
% //<Version>ODV Spreadsheet V4.0</Version>
% //<DataField>Ocean</DataField>
% //<DataType>Profile</DataType>
% //<DataVariable>label="Cast_direction" value_type="TEXT" is_primary_variable="F" comment="d-downcast u-upcast"</DataVariable>
% //<MissingDataValues>NaN</MissingDataValues>
% // Model=RBRmaestro
% // Firmware=12.03
% // Serial=80217
% //Processing history:
% ///Users/RZhang/code/rsk_files/080217_20150919_1417.rsk opened using RSKtools v2.3.0.
% //Sea pressure calculated using an atmospheric pressure of 10.1325 dbar.
% //Comment: Hey Jude
% 
% Cruise	Station	Type	yyyy-mm-ddTHH:MM:ss.FFF	Longitude[degrees_east]	Latitude [degrees_north]	Bot. Depth [m]	Conductivity[mS/cm]	Pressure[dbar]	Dissolved_O2[%]	Cast_direction	
% C1	S1	C	2015-09-19T08:59:05.000	0.0	0.0	0.0	34.2349	79.0907	472.6810	d
% C1	S1	C	2015-09-19T08:59:05.167	0.0	0.0	0.0	34.2363	78.8998	472.5748	d
% C1	S1	C	2015-09-19T08:59:05.333	0.0	0.0	0.0	34.2414	78.7738	472.5124	d
%
% Inputs:
%    [Required] - RSK - Structure containing the logger metadata, along 
%                       with the added 'data' field.
%
%    [Optional] - channel - Longname of channel for output in ODV file
%                 (e.g., temperature, salinity, etc), default is all
%                 channels.
%
%                 profile - Profile number for output ODV files, default is
%                 all profiles.
%
%                 direction - Direction for output ODV files, default is
%                 both.
%
%                 outputdir - Directory for output ODV files, default is
%                 current directory.
%
%                 comment - Extra comments to attach to the end of the
%                 header.
%
% Outputs:
%
%    ODV file - Output ODV file contains logger metadata, processing
%    log entries, user-defined comments, and column data of selected
%    channels.
%
% Example:
%   rsk = RSKopen(fname);
%   rsk = RSKreadprofiles(rsk);
%   RSK2ODV(rsk,'channel',{'Temperature','Pressure'},'outputdir','/Users/decide/where','comment','Hey Jude');
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-05-11


p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'channel', 'all');
addParameter(p, 'profile', [], @isnumeric);
addParameter(p, 'direction', [], @ischar);
addParameter(p, 'outputdir', pwd);
addParameter(p, 'comment', [], @ischar);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
channel = p.Results.channel;
profile = p.Results.profile;
direction = p.Results.direction;
outputdir = p.Results.outputdir;
comment = p.Results.comment;


if exist(outputdir, 'dir') ~= 7
    RSKerror('Input directory does not exist.')
end

checkDataField(RSK)

% Check if the structure comes from RSKreaddata or RSKreadprofiles?
isProfile = isfield(RSK.data,'direction');

if ~isProfile && (~isempty(profile) || ~isempty(direction))
    RSKerror('RSK structure is not organized into profiles. Use RSKreadprofiles or RSKtimeseries2profiles.');
end

if isempty(direction); 
    direction = 'both'; 
end;

if ~strcmp('both', direction) && isProfile && ...
    (all(strcmp('up',{RSK.data.direction})) && ~strcmp(direction,'up') || all(strcmp('down',{RSK.data.direction})) && ~strcmp(direction,'down'))
    RSKerror('Requested cast direction or profile does not exist in RSK structure, use RSKreadprofiles.')
end

% Set up metadata
RBR = struct;
[firmwareV, ~, ~]  = readfirmwarever(RSK);
RBR.model = RSK.instruments.model;
RBR.firmware = firmwareV;
RBR.serial = num2str(RSK.instruments.serialID);

% Channels
chanCol = [];
channels = cellchannelnames(RSK, channel);
for chan = channels
    chanCol = [chanCol getchannelindex(RSK, chan{1})];
end

RBR.channelnames = {RSK.channels(chanCol).longName}';
RBR.channelunits = {RSK.channels(chanCol).units}';
try
    RBR.channelranging = {RSK.ranging.mode}';
catch
end

% Fix up variable names by replacing spaces with underscores
RBR.channelnames = strrep(RBR.channelnames,' ','_');

% Epochs
RBR.starttime = datestr(RSK.epochs.startTime, 'dd/mm/yyyy HH:MM:SS PM');
RBR.endtime = datestr(RSK.epochs.endTime, 'dd/mm/yyyy HH:MM:SS PM');

% Check if Sea_Pressure exists in output data, if yes, get the index
hasSP = any(strcmpi('Sea_Pressure', RBR.channelnames));

% Set up data tables and output accordingly. When the structure comes from
% RSKreaddata, one txt file is saved, when it comes from RSKreadprofiles,
% multiple txt files are saved.
[~,inputfilename,~] = fileparts(RSK.toolSettings.filename);
filename = ([inputfilename '.txt']); 
nchannels = length(channels);
fmt_time = 'yyyy-mm-ddTHH:MM:ss.FFF';
channel_name_unit = strcat(RBR.channelnames, {'['}, RBR.channelunits, {']'});

if hasSP
   colSPname = find(strncmpi('Sea_Pressure', channel_name_unit, length('Sea_Pressure')));
   channelIdx = colSPname(1);
   nameSP = channel_name_unit(channelIdx);
   tempname = channel_name_unit;
   tempname(channelIdx) = [];
   channel_name_unit = [nameSP; tempname];
end
log = RSK.log(:,2);

% Check if cast direction includes both upcast and downcast?
directions = 1;
if isfield(RSK,'profiles') && isfield(RSK.profiles,'order') && length(RSK.profiles.order) ~= 1 && strcmp(direction,'both')
    directions = 2;
end

% Determine output data format
tempstr = ['%s\t%s\t%s\t%s\t%.2f\t%.2f\t%.1f\t',repmat(('%.4f\t'), 1, nchannels)];
if isProfile, 
    fmt_data = [tempstr, '%s\n'];
else
    fmt_data = [tempstr, '\n'];
end

% Determin which profile(s) for output
if isProfile,
    select_cast = getdataindex(RSK, profile, direction);
else
    select_cast = 1;
end

for castidx = select_cast(1:directions:end); 
    
    for d = 1 : directions
        
        directionidx = castidx - 1 + d;
        
        RBR(directionidx).sampletimes = cellstr(datestr(RSK.data(directionidx).tstamp, fmt_time));
        N = length(RBR(directionidx).sampletimes);       

        if isfield(RSK.data,'cruise') && ~isempty(RSK.data(directionidx).cruise)
            temp = RSK.data(castidx).cruise;
            RBR(directionidx).cruise = repmat(num2str(temp{1}), N,1);
        else
            RBR(directionidx).cruise = repmat('C1', N,1);
        end       
        if isfield(RSK.data,'station') && ~isempty(RSK.data(directionidx).station)
            temp = RSK.data(castidx).station;
            RBR(directionidx).station = repmat(num2str(temp{1}), N,1);
        else
            RBR(directionidx).station = repmat('S1', N,1);
        end 
        RBR(directionidx).type = repmat('C', N,1);  
        if isfield(RSK.data,'latitude') && ~isnan(RSK.data(directionidx).latitude)
            RBR(directionidx).latitude = (RSK.data(directionidx).latitude)*ones(N,1);
        else
            RBR(directionidx).latitude = zeros(N,1);
        end
        if isfield(RSK.data,'longitude') && ~isnan(RSK.data(directionidx).longitude)
            RBR(directionidx).longitude = (RSK.data(directionidx).longitude)*ones(N,1);
        else
            RBR(directionidx).longitude = zeros(N,1);
        end  
        if isfield(RSK.data,'depth') && ~isnan(RSK.data(directionidx).depth)
            RBR(directionidx).bottomdepth = (RSK.data(directionidx).depth)*ones(N,1);
        else
            RBR(directionidx).bottomdepth = zeros(N,1);
        end  

        RBR(directionidx).data = RSK.data(directionidx).values(:,chanCol);

        if hasSP, % Put sea pressure as the first column of the data
            dataSP = RBR(directionidx).data(:,channelIdx);
            tempdata = RBR(directionidx).data;
            tempdata(:,channelIdx) = [];
            RBR(directionidx).data = [dataSP, tempdata];
        end
            data2fill{d} = [cellstr(RBR(directionidx).cruise), cellstr(RBR(directionidx).station),...
            cellstr(RBR(directionidx).type), RBR(directionidx).sampletimes, num2cell(RBR(directionidx).longitude), ...
            num2cell(RBR(directionidx).latitude), num2cell(RBR(directionidx).bottomdepth), num2cell(RBR(directionidx).data)];  
        
        if isProfile
            RBR(directionidx).castdirection = repmat(RSK.data(directionidx).direction(1), length(RBR(directionidx).sampletimes),1);
            data2fill{d} = [data2fill{d}, cellstr(RBR(directionidx).castdirection)];
        end
    end
    
    % File name added with 'profile#' when rsk has profiles
    if isProfile
        filename = ([inputfilename, '_profile' num2str(RSK.data(castidx).profilenumber, '%04d') '.txt']); 
    end

    fid = fopen([outputdir filesep filename],'w');
    
    % Output header information
    fprintf(fid,'%s\n','//<Creator>RBR</Creator>');
    fprintf(fid,'%s\n',['//<CreateTime>' datestr(now) '</CreateTime>']); 	
    fprintf(fid,'%s\n','//<Software>RSKtools</Software>');
    fprintf(fid,'%s\n','//<Source></Source>');
    fprintf(fid,'%s\n','//<SourceLast-Modified></SourceLast-Modified>');
    fprintf(fid,'%s\n','//<Version>ODV Spreadsheet V4.0</Version>');
    fprintf(fid,'%s\n','//<DataField>Ocean</DataField>');
    if isProfile;
        fprintf(fid,'%s\n','//<DataType>Profile</DataType>');
    else
        fprintf(fid,'%s\n','//<DataType>TimeSeries</DataType>');
    end
    if isProfile,
       fprintf(fid,'%s\n','//<DataVariable>label="Cast_direction" value_type="TEXT" is_primary_variable="F" comment="d-downcast u-upcast"</DataVariable>');
    end
    fprintf(fid,'%s\n','//<MissingDataValues>NaN</MissingDataValues>');
    fprintf(fid,'%s\n',['// Model=' RBR.model]);
    fprintf(fid,'%s\n',['// Firmware=' RBR.firmware]);
    fprintf(fid,'%s\n',['// Serial=' RBR.serial]);   
    fprintf(fid,'%s\n','//Processing history:');
    for l = 1:length(log), fprintf(fid,'%s\n',['//' log{l}]); end
    if isfield(RSK.data,'comment');
        temp = RSK.data(castidx).comment;
        fprintf(fid,'%s\n',['//Comment: ' num2str(temp{1})]);
        if ~isempty(comment), 
            fprintf(fid,'%s\n',['//' comment]); 
        end
    else
        if ~isempty(comment), 
            fprintf(fid,'%s\n',['//Comment: ' comment]); 
        end
    end
    fprintf(fid,'\n');    
    
    % Output variable names
    output_name = [{'Cruise'}, {'Station'}, {'Type'}, {fmt_time}, {'Longitude[degrees_east]'}, ...
        {'Latitude [degrees_north]'}, {'Bot. Depth [m]'}, channel_name_unit{:}];
    if isProfile
        output_name = [output_name, 'Cast_direction'];
    end    
    fprintf(fid, repmat(('%s\t'), 1, length(output_name)), output_name{:});
    fprintf(fid, '\n');
    
    % Output data 
    for d = 1 : directions
        outdata = data2fill{d}';
        fprintf(fid, fmt_data, outdata{:});
    end

    fclose(fid);

    fprintf('Wrote: %s/%s\n', outputdir, filename);

end

end