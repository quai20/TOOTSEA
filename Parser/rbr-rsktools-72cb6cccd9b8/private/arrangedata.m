function data = arrangedata(results_struct)

%ARRANGEDATA - Clean data structures during reading.
% 
% Syntax:  [data] = ARRANGEDATA(results_struct)
% 
% Arranges data read from an RSK SQLite database and cleans it by setting
% zeros for empty values (usually occurs at the beginning of profiling runs
% when some sensors are still settling).
% 
% Inputs: 
%    results_struct - Structure containing the logger data read
%                     from the RSK file.
%
% Outputs:
%    data - Structure containing the arranged logger data, ordered
%           by tstamp.
%
% See also: RSKreaddata, RSKreadburstdata.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-06-21

s = struct2cell(results_struct);
data.tstamp = [s{1,:}]';
values = s(2:end,:);



blanks = cellfun('isempty',values);
values(blanks)={NaN};



data.values = cell2mat(values)';

end


