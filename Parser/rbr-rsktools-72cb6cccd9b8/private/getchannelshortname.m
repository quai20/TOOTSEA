function shortName = getchannelshortname(longName)

% getchannelshorname - Return short name for given channel long name.
%
% Syntax:  shortName = getchannelshortname(longName)
%
% Inputs:
%   longName - longName of the channels
%
% Outputs:
%   shorName - shorName of the channels
%
% See also: getchannelindex
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2019-05-16


channelList =   {'conductivity','temperature','pressure','sea pressure','depth',...
                 'salinity','velocity','dissolved O2','buoyancy frequency squared','stability',...
                 'turbidity','par','chlorophyll','acceleration','specific conductivity',...
                 'bpr pressure','bpr temperature','partial co2 pressure','period','ph',...
                 'transmittance','voltage','distance','speed of sound','density anomaly',...
                 'significant wave height','significant wave period','1/10 wave height','1/10 wave period','maximum wave height',...
                 'maximum wave period','average wave height','average wave period','wave energy','tidal slope',...
                 'pressure gauge temperature','ct cell temperature','external cabled temperature','optode temperature','temperature (conductivity correction)'};
shortNameList = {'cond00','temp00','pres00','pres08','dpth01',...
                 'sal_00','pvel00','ddox00','buoy00','stbl00',...
                 'turb00','par_01','fluo01','acc_00','scon00',...
                 'bpr_08','bpr_09','pco200','peri00','ph__00',...
                 'tran00','volt00','alti00','sos_00','dden00',...
                 'wave00','wave01','wave02','wave03','wave04',...
                 'wave05','wave06','wave07','wave08','slop00',...
                 'temp05','temp11','temp13','temp16','temp11'};
 
if ischar(longName)
    longName = {longName};
end

longName = lower(longName);

shortName = cell(size(longName));
[~,ind1,ind2] = intersect(longName,channelList,'stable');
shortName(ind1) = shortNameList(ind2);
[shortName{cellfun(@isempty,shortName)}] = deal('cnt_00');
     
idx = strncmpi('dissolved',longName,9);
if any(idx)
    shortName(idx) = repmat({'ddox00'},1,sum(idx));
end

idx = strncmpi('chlorophyll',longName,11);
if any(idx)
    shortName(idx) = repmat({'fluo01'},1,sum(idx));
end

end
