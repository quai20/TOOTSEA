function boolean = is_whole_day(test_datenum)
% Does this datenum represent a whole day or some fraction?
%
% boolean = is_whole_day(test_datenum)
%
% Input:
%   test_datenum
%
% Output:
%   boolean

% Kevin J. Delaney
% November 24, 2008

boolean = [];

if ~exist('test_datenum', 'var')
    help(mfilename);
    return
end

if length(test_datenum) > 1
    boolean = false(length(test_datenum), 1);
    
    for k = 1:length(test_datenum)
        boolean(k) = is_whole_day(test_datenum(k));
    end
    
else
    
    boolean = false;

    if isempty(test_datenum) || ...
       ~isdatenum(test_datenum)
        errordlg('Input "test_datenum" is empty or not a valid datenum.', mfilename);
        return
    end

    [year, month, day, hour, minute, second] = datevec(test_datenum);
    boolean = (hour == 0) && (minute == 0) && (second == 0);
end