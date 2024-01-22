function RSK = CSV2RSK(fname,varargin)

% CSV2RSK - Convert a csv file into a rsk structure.
%
% Syntax: RSK = CSV2RSK(fname, [OPTIONS])
%
% Inputs: 
%    [Required] - fname - filename of the csv file
%
%    [Optional] - model - instrument model from which data was collected, 
%                 default is 'unknown'
%    
%                 serialID - serial ID of the instrument from which data
%                 was collected, default is 0
%
%                 DDmode - indicate if the data is from DD (directional
%                 dependent) mode, default is false
%
% Output:
%    RSK - RSK structure containing data from the csv file
%
% Note: The header of the csv file must follow exactly the format below to
% make this function work:
%
% "Time (ms)","Conductivity (mS/cm)","Temperature (°C)","Pressure (dbar)"
% 1564099200000,49.5392,21.8148,95.387
% 1564099200167,49.5725,21.8453,95.311
% 1564099200333,49.5948,21.8752,95.237
% ...
%
% where the first column represents time stamp, which is milliseconds
% elapsed since January 1 1970 (i.e. unix time or POSIX time). Header for
% each column is comprised with channel name followed by space and unit 
% (with parentheses) with double quotes.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2020-03-30


p = inputParser;
addRequired(p,'fname', @ischar);
addParameter(p,'model','unknown', @ischar);
addParameter(p,'serialID', 0, @isnumeric);
addParameter(p,'DDmode', false, @islogical);
parse(p, fname, varargin{:})

fname = p.Results.fname;
model = p.Results.model;
serialID = p.Results.serialID;
DDmode = p.Results.DDmode;


data = csvread(fname,1,0);

fid = fopen(fname,'r','n','UTF-8');
varNameAndUnit = strsplit(fgetl(fid),',');
fclose(fid);

varNameAndUnit = varNameAndUnit(2:end);
[channels,units] = deal(cell(size(varNameAndUnit)));

for i = 1:length(varNameAndUnit)
    idx = strfind(varNameAndUnit{i},'(');
    idx = idx(end);
    channels{i} = varNameAndUnit{i}(1:idx-2);
    units{i} = varNameAndUnit{i}(idx:end);
end

channels = regexprep(channels,'"','');
units = regexprep(units,'[",(,)]','');

tstamp = rsktime2datenum(data(:,1))';
values = data(:,2:end);

RSK = RSKcreate('tstamp',tstamp,'values',values,'channel',channels,'unit',...
      units,'filename',[strtok(fname,'.') '.rsk'],'model',model,'serialID',serialID);

% revise sampling rate if data in DD mode
if DDmode
    timeDiff = diff(RSK.data.tstamp)*86400*1000;   
    fastPeriod = round(mode(timeDiff));
    fastPeriod = 1000/(round(1000/fastPeriod));
    timeDiff(timeDiff < fastPeriod + 5 & timeDiff > fastPeriod - 5) = NaN;
    slowPeriod = round(mode(timeDiff));
    
    slowIdx = find(~isnan(timeDiff));
    slowIdx2 = find(diff(slowIdx) > 1);
    p = RSK.data.values(:,getchannelindex(RSK,'pressure'));
    if p(slowIdx2(end-1)+1) > p(slowIdx2(end))
        direction = 'Descending';
    else
        direction = 'Ascending';
    end
    
    if isnan(slowPeriod)
        RSKwarning('The data is not in DD mode, please turn DDmode off.')
    else   
        if isfield(RSK.schedules,'samplingPeriod')
            RSK.schedules = rmfield(RSK.schedules,'samplingPeriod'); 
        end
        RSK.schedules.mode = 'ddsampling';
        RSK.directional.directionalID = 1;
        RSK.directional.scheduleID = 1;        
        RSK.directional.fastPeriod = fastPeriod;
        RSK.directional.slowPeriod = slowPeriod;       
        RSK.directional.direction = direction;       
    end
end

% temporary fix for inconsistent units between WW data and Ruskin
RSK = renamechannels(RSK);

for i = 1:length(RSK.channels)
    if strncmpi(RSK.channels(i).longName,'Dissolved O2',12) && strcmpi(RSK.channels(i).units(2:end),'Mol/L')
        RSK.channels(i).units = lower(RSK.channels(i).units);
    end
    
    if strncmpi(RSK.channels(i).longName,'Chlorophyll',11) && strcmpi(RSK.channels(i).units(2:end),'g/L')
        RSK.channels(i).units = lower(RSK.channels(i).units);
    end
end

end