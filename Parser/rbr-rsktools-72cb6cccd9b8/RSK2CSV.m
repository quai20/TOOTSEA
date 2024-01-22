function RSK2CSV(RSK, varargin)

% RSK2CSV - Write one or more CSV files of logger data and metadata.
%
% Syntax: RSK2CSV(RSK, [OPTIONS])
%
% RSK2CSV outputs the RSK structure format into one or more CSV
% file. The CSV file contains important logger metadata and a row of
% variable names and units above each column of channel data.  If the
% data has been parsed into profiles, then one file will be written
% for each profile. Furthermore, an extra column called
% 'cast_direction' will be included.  The column will contain 'd' or
% 'u' to indicate whether the sample is part of the downcast or
% upcast, respectively.
%    
% Note: The header also includes entries for station metadata,
% although as of RSKtools v2.2.0 these must be populated by the user.
% In future versions of RSKtools some of these fields may be filled
% automatically using, for example, Ruskin annotations.
%
% Below is an example of a CSV file created with RSK2CSV:
%
% //Creator: RBR Ltd
% //Create Time: 23-Jan-2018 09:49:17
% //Instrument model firmware and serialID: RBRmaestro 12.03 80217
% //Sample period: 0.167 second
% //Processing history:
% ///Users/RZhang/code/rsk_files/080217_20150919_1417.rsk opened using RSKtools v2.1.0.
% //Sea pressure calculated using an atmospheric pressure of 10.1325 dbar.
% //Cruise:
% //Station:
% //Vessel:
% //Latitude:
% //Longitude:
% //Depth:
% //Date:
% //Weather:
% //Crew:
% //Comment: Hey Jude
% 
% //Time(yyyy-mm-dd HH:MM:ss.FFF),  Conductivity(mS/cm),   Pressure(dbar),   Dissolved_O2(%)     
% 2015-09-19 08:32:16.000,           34.6058,           12.6400,          694.7396
% 2015-09-19 08:32:16.167,           34.6085,           12.4154,          682.4502
% 2015-09-19 08:32:16.333,           34.6130,           12.4157,          666.1949
%
% 
% Inputs:
%    [Required] - RSK - Structure containing the logger metadata, along 
%                       with the added 'data' field.
%
%    [Optional] - channel - Longname of channel(s) to include in CSV file
%                 (e.g., temperature, salinity, etc), default is all
%                 channels.
%
%                 profile - Profile number for output CSV files, default is
%                 all profiles.
%
%                 direction - Direction for output CSV files, default is
%                 both.
%
%                 outputdir - directory for output CSV files, default is
%                 current directory.
%
%                 comment - Extra comments to attach to the end of the
%                 header.
%
% Outputs:
%
%    CSV file - Output CSV file contains logger metadata, processing
%    log entries, user-defined comments, and column data of selected
%    channels.
%
% Example:
%   rsk = RSKopen(fname);
%   rsk = RSKreadprofiles(rsk);
%   RSK2CSV(rsk,'channel',{'Temperature','Pressure'},'outputdir','/Users/decide/where','comment','Hey Jude');
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2019-04-08


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
outputdir = p.Results.outputdir;
comment = p.Results.comment;
direction = p.Results.direction;


if exist(outputdir, 'dir') ~= 7
    RSKerror('Input directory does not exist.')
end

checkDataField(RSK)

% Check if the structure comes from RSKreaddata or RSKreadprofiles?
isProfile = isfield(RSK.data,'direction');

if ~isProfile && (~isempty(profile) || ~isempty(direction))
    RSKerror('RSK structure is not organized into profiles. Use RSKreadprofiles or RSKtimeseries2profiles.');
end

if isempty(direction); direction = 'both'; end;

if ~strcmp('both', direction) && isProfile && ...
    (all(strcmp('up',{RSK.data.direction})) && ~strcmp(direction,'up') || all(strcmp('down',{RSK.data.direction})) && ~strcmp(direction,'down'))
    RSKerror('Requested cast direction or profile does not exist in RSK structure, use RSKreadprofiles.')
end

% Set up metadata
RBR = struct;
[firmwareV, ~, ~]  = readfirmwarever(RSK);
RBR.name = [RSK.instruments.model ' ' firmwareV ' ' num2str(RSK.instruments.serialID)];

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

% Sample period
sampleperiod = readsamplingperiod(RSK);

% Fix up variable names by replacing spaces with underscores
RBR.channelnames = strrep(RBR.channelnames,' ','_');

% Epochs
RBR.starttime = datestr(RSK.epochs.startTime, 'dd/mm/yyyy HH:MM:SS PM');
RBR.endtime = datestr(RSK.epochs.endTime, 'dd/mm/yyyy HH:MM:SS PM');

% Set up data tables and output accordingly. When the structure comes from
% RSKreaddata, one CSV file is saved, when it comes from RSKreadprofiles,
% multiple CSV files are saved.
[~,inputfilename,~] = fileparts(RSK.toolSettings.filename);
filename = ([inputfilename '.csv']); 
nchannels = length(channels);
fmt_time = 'yyyy-mm-dd HH:MM:ss.FFF';
channel_name_unit = strcat(RBR.channelnames, {'('}, RBR.channelunits, {'),   '});
if ~isProfile,
    channel_name_unit{end} = strrep(channel_name_unit{end},',','');
end
log = RSK.log(:,2);

% Check if both upcast and downcast needs reading?
directions = 1;
if isfield(RSK,'profiles') && isfield(RSK.profiles,'order') && length(RSK.profiles.order) ~= 1 && strcmp(direction,'both')
    directions = 2;
end

% Determine output data format
templen = num2str(round(median(cellfun(@length, channel_name_unit))));
if isProfile, 
    fmt_data = ['%s,',repmat(['%' templen '.4f,'], 1, nchannels), ['%' templen 's\n']];
else
    fmt_data = ['%s,',repmat(['%' templen '.4f,'], 1, nchannels-1), ['%' templen '.4f'], '\n'];
end

% Determine which profile(s) for output
if isProfile,
    select_cast = getdataindex(RSK, profile, direction);
else
    select_cast = 1;
end

for castidx = select_cast(1:directions:end); 
    
    for d = 1 : directions
        
        directionidx = castidx - 1 + d;
        
        RBR(directionidx).sampletimes = cellstr(datestr(RSK.data(directionidx).tstamp, fmt_time));
        RBR(directionidx).data = RSK.data(directionidx).values(:,chanCol);     
        data2fill{d} = [RBR(directionidx).sampletimes, num2cell(RBR(directionidx).data)];
        
        if isProfile
            RBR(directionidx).castdirection = repmat(RSK.data(directionidx).direction(1), length(RBR(directionidx).sampletimes),1);
            data2fill{d} = [data2fill{d}, cellstr(RBR(directionidx).castdirection)];
        end
    end
    
    % File name added with 'profile#' when rsk has profiles
    if isProfile
        filename = ([inputfilename, '_profile' num2str(RSK.data(castidx).profilenumber, '%04d') '.csv']); 
    end

    fid = fopen([outputdir filesep filename],'w');
    
    % Output header information
    fprintf(fid,'%s\n','//Creator: RBR Ltd');
    fprintf(fid,'%s\n',['//Create Time: ' datestr(now)]);
    fprintf(fid,'%s\n',['//Instrument model firmware and serialID: ' RBR.name]);
    fprintf(fid,'%s\n',['//Sample period: ' num2str(sampleperiod) ' second']);
    fprintf(fid,'%s\n','//Processing history:');
    for l = 1:length(log), fprintf(fid,'%s\n',['//' log{l}]); end
    
    if isfield(RSK.data,'cruise') && ~isempty(RSK.data(castidx).cruise)
        temp = RSK.data(castidx).cruise;
        fprintf(fid,'%s\n',['//Cruise: ' num2str(temp{1})]);
    else
        fprintf(fid,'%s\n','//Cruise:');
    end
    if isfield(RSK.data,'station') && ~isempty(RSK.data(castidx).station)
        temp = RSK.data(castidx).station;
        fprintf(fid,'%s\n',['//Station: ' num2str(temp{1})]);
    else
        fprintf(fid,'%s\n','//Station:');
    end
    if isfield(RSK.data,'latitude')
        fprintf(fid,'%s\n',['//Latitude: ' num2str(RSK.data(castidx).latitude)]);
    else
        fprintf(fid,'%s\n','//Latitude:');
    end
    if isfield(RSK.data,'longitude')
        fprintf(fid,'%s\n',['//Longitude: ' num2str(RSK.data(castidx).longitude)]);
    else
        fprintf(fid,'%s\n','//Longitude:');
    end
    if isfield(RSK.data,'depth')
        fprintf(fid,'%s\n',['//Depth: ' num2str(RSK.data(castidx).depth)]);
    else
        fprintf(fid,'%s\n','//Depth:');
    end
    if isfield(RSK.data,'date') && ~isempty(RSK.data(castidx).date)
        temp = RSK.data(castidx).date;
        fprintf(fid,'%s\n',['//Date: ' num2str(temp{1})]);
    else
        fprintf(fid,'%s\n','//Date:');
    end
    if isfield(RSK.data,'weather') && ~isempty(RSK.data(castidx).weather)
        temp = RSK.data(castidx).weather;
        fprintf(fid,'%s\n',['//Weather: ' num2str(temp{1})]);
    else
        fprintf(fid,'%s\n','//Weather:');
    end
    if isfield(RSK.data,'crew') && ~isempty(RSK.data(castidx).crew)
        temp = RSK.data(castidx).crew;
        fprintf(fid,'%s\n',['//Crew: ' num2str(temp{1})]);
    else
        fprintf(fid,'%s\n','//Crew:'); 
    end
    if isfield(RSK.data,'comment');
        temp = RSK.data(castidx).comment;
        if ~isempty(temp), fprintf(fid,'%s\n',['//Comment: ' num2str(temp{1})]); end
        if ~isempty(comment), fprintf(fid,'%s\n',['//' comment]); end
    else
        if ~isempty(comment), fprintf(fid,'%s\n',['//Comment: ' comment]); end
    end
        
    fprintf(fid,'\n');   
    
    % Output time and variable names and/or cast_direction
    output_name = ['//Time(' fmt_time '),  ', channel_name_unit{:}];
    if isProfile
        output_name = [output_name, '  Cast_direction'];
    end    
    fprintf(fid, '%s  ', output_name);
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