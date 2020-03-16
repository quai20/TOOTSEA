function boolean = isdatenum(test_datenum)
% Is this a reasonable datenum?
%
% boolean = isdatenum(test_datenum)
%
% Input:
%   test_datenum
%
% Output:
%   boolean

% Kevin J. Delaney
% September 11, 2008

boolean = [];
earliest_reasonable_datenum = datenum(1900, 1, 1, 0, 0, 0);
latest_reasonable_datenum = datenum(2099, 12, 31, 23, 59, 59);

if ~exist('test_datenum', 'var')
    help(mfilename);
    return
end

boolean = false;

if isempty(test_datenum) || ...
   ~isnumeric(test_datenum)
%     errordlg('Input "test_datenum" is empty or non-numeric.', mfilename);
    return
end

boolean = (test_datenum >= earliest_reasonable_datenum) & ...
          (test_datenum <= latest_reasonable_datenum);