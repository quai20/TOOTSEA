function logdata = logentrydata(RSK, profile, direction)

%LOGENTRYDATA - Create part of a log entry to describe data elements used.
%
% Syntax:  [logdata] = LOGENTRYDATA(RSK, profile, direction)
%
% Creates a log entry explaining the casts described by the profile and
% direction arguments. 
%
% Inputs:
%    RSK - The input RSK structure
%
%    profile - Profile number. Default is to use all profiles.
%
%    direction - Cast direction. Default is to use all available
%          directions.
%
% Outputs:
%    logdata - String describing the data elements used.
%
% See also: RSKsmooth, RSKdespike.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-06-20

if size(RSK.data, 2) == 1
    logdata = 'the data';
    return
end



profilecast = size(RSK.profiles.order, 2);
if isempty(profile)
    if profilecast == 2 && ~strcmp(direction, 'both') && ~isempty(direction)
        logdata = ['all ' direction 'cast'];
    else
        logdata = 'all profiles';
    end
elseif length(profile) == 1
    if profilecast == 2 && ~strcmp(direction, 'both') && ~isempty(direction)
        logdata = [direction 'cast of profile ' num2str(profile, '%1.0f')];
    else
        logdata = ['profile ' num2str(profile, '%1.0f')];
    end
else
    if profilecast == 2 && ~strcmp(direction, 'both') && ~isempty(direction)
        logdata = [direction 'cast of profiles ' num2str(profile(1:end-1), '%1.0f, ') ' and ' num2str(profile(end))];
    else
        logdata = ['profiles ' num2str(profile(1:end-1), '%1.0f, ') ' and ' num2str(profile(end))];
    end
end

end