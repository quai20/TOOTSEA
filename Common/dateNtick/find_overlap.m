function varargout = find_overlap(region_1, region_2, varargin)
% Given two regions of data, find their union & intersection.
%   Intersection_limits (data limits encompassing region_1 AND region_2)
%   Union_limits (data limits encompassing region_1 OR region_2)
%
% [Intersection_limits, ...
%  Union_limits, ...
%  One_but_not_two_limits, ...
%  Two_but_not_one_limits] = find_overlap(region_1, region_2, ...
%                                        'inclusive', inclusive_switch, ...
%                                        'threshold', threshold_value)
%
% Ex.                  -1 0 1 2 3 4 5
%       Region 1:       ***********
%       Region 2:             +++++++
%       Intersection:         &&&&&
%       Union:          @@@@@@@@@@@@@
%       One not two:    ******
%       Two not one:               ++
%
%   [q1, q2, q3, q4] = find_overlap([-1 4], [2 5]) returns
%           q1 = [2 4]
%           q2 = [-1 5]
%           q3 = [-1 2]
%           q4 = [4 5]
%
% If one region wholly inside another, can have TWO rows in output:
%
% Ex.  [q1, q2, q3, q4] = find_overlap([-1 5], [2 3]) returns
%           q1 = [2 3]
%           q2 = [-1 5]
%           q3 = [-1 2;
%                  3 5];
%           q4 = []
%
% Inputs:
%   region_1, region_2      [min, max] limits defining a region
%
% Options:
%   inclusive_switch        Boolean: if a equals b or c, is it "between"?
%                               default: true (equals counts as "between")
%                               otherwise, specify false
%   threshold_value         Is there some small value for which overlaps
%                               should be ignored?
%
% Outputs:
%   Intersection_limits     data limits of the intersection of region_1 and region_2
%   Union_limits            data limits of the union of region_1 and region_2
%   One_but_not_two_limits  data limits of region 1 that is NOT in region 2
%                               if region 1 is wholly inside region 2, null
%                               if region 2 is wholly inside region 1, will
%                               have two rows--for left & right-hand
%                               portions
%   Two_but_not_one_limits  data limits of region 2 that is NOT in region 1
%                               if region 2 is wholly inside region 1, null
%                               if region 1 is wholly inside region 2, will
%                               have two rows--for left & right-hand
%                               portions

% Kevin J. Delaney
% October 1, 2008
% November 19, 2008     Added One_but_not_two, Two_but_not_one outputs.
% April 5, 2010         Added 'inclusive', 'threshold' options.
% June 10, 2010         Added Case 6: regions are identical.

varargout{1} = [];
varargout{2} = [];
varargout{3} = [];
varargout{4} = [];
inclusive = true;
threshold_value = 0;

if ~exist('region_1', 'var')
    help(mfilename);
    return
end
 
if ~isnumeric(region_1)
    errordlg('Input "region_1" is non-numeric.', ...
        mfilename);
    return
end

if ~exist('region_2', 'var') || ...
    ~isnumeric(region_2)
    errordlg('Input "region_2" is non-numeric.', ...
        mfilename);
    return
end

for index = 1 : 2 : (length(varargin) - 1)
    option_name = varargin{index};
    
    if isempty(option_name) || ~ischar(option_name)
        errordlg('Option name is empty or non-char.', mfilename);
        return
    end
    
    option_value = varargin{index + 1};
    
    if isempty(option_value)
        errordlg('Option value is empty.', mfilename);
        return
    end
    
    switch lower(option_name)
                   
        case 'inclusive'

            if ischar(option_value)
                switch lower(option_value)
                    case {'inclusive', 'yes', 'true', 'y', 't'}
                        inclusive = true;
                    case {'exclusive', 'false', 'no', 'f', 'n'}
                        inclusive = false;
                    otherwise
                        errordlg(['Unknown "inclusive" selection "', option_value, '".'], ...
                            mfilename);
                        return
                end
            elseif islogical(option_value)
                inclusive = option_value;
            else
                errordlg('Option "inclusive" neither boolean nor char.', mfilename);
                return
            end

                        
        case 'threshold'
            
            if ~isnumeric(option_value)
                errordlg('Input "threshold" is non-numeric.', mfilename);
                return
            end
            
            threshold_value = option_value;
            
            
        otherwise
            errordlg(['Unknown option "', option_name, '".'], mfilename);
            return
    end
end

%   Handle empty inputs.
if isempty(region_1)
    varargout{2} = region_2;
    varargout{4} = region_2;
    return
end

if isempty(region_2)
    varargout{2} = region_1;
    varargout{3} = region_1;
    return
end

region_1_limits = [min(region_1), max(region_1)];
region_2_limits = [min(region_2), max(region_2)];

Intersection_limits = [max([region_1_limits(1), region_2_limits(1)]), ...
                       min([region_1_limits(2), region_2_limits(2)])];

Union_limits = [min([region_1_limits(1), region_2_limits(1)]), ...
                max([region_1_limits(2), region_2_limits(2)])];

if Intersection_limits(2) < Intersection_limits(1)
    Intersection_limits = [];
end

%   Multiple cases:
%   1) No intersection between regions 1 & 2.
if isempty(Intersection_limits)
    One_but_not_two_limits = region_1_limits;
    Two_but_not_one_limits = region_2_limits;

%   2) Region 1 overlapping region 2 left edge.
elseif isbetween(region_1_limits(2), region_2_limits(1), region_2_limits(2), 'inclusive', inclusive, 'threshold', threshold_value) && ...
      ~isbetween(region_1_limits(1), region_2_limits(1), region_2_limits(2), 'inclusive', inclusive, 'threshold', threshold_value)
  
    One_but_not_two_limits = [region_1_limits(1), region_2_limits(1)];  
    Two_but_not_one_limits = [region_1_limits(2), region_2_limits(2)];  
    
%   3) Region 1 wholly inside region 2.
elseif isbetween(region_1_limits(1), region_2_limits(1), region_2_limits(2), 'inclusive', inclusive, 'threshold', threshold_value) && ...
       isbetween(region_1_limits(2), region_2_limits(1), region_2_limits(2), 'inclusive', inclusive, 'threshold', threshold_value)
    One_but_not_two_limits = [];
    Two_but_not_one_limits(1, :) = [region_2_limits(1), region_1_limits(1)];  
    Two_but_not_one_limits(2, :) = [region_1_limits(2), region_2_limits(2)];

%   4) Region 2 wholly inside region 1.
elseif isbetween(region_2_limits(1), region_1_limits(1), region_1_limits(2), 'inclusive', inclusive, 'threshold', threshold_value) && ...
       isbetween(region_2_limits(2), region_1_limits(1), region_1_limits(2), 'inclusive', inclusive, 'threshold', threshold_value)
    One_but_not_two_limits(1, :) = [region_1_limits(1), region_2_limits(1)];  
    One_but_not_two_limits(2, :) = [region_2_limits(2), region_1_limits(2)];
    Two_but_not_one_limits = [];

%   5) Region 1 overlapping region 2 right edge.
elseif isbetween(region_1_limits(1), region_2_limits(1), region_2_limits(2), 'inclusive', inclusive, 'threshold', threshold_value) && ...
      ~isbetween(region_1_limits(2), region_2_limits(1), region_2_limits(2), 'inclusive', inclusive, 'threshold', threshold_value)
    One_but_not_two_limits = [region_2_limits(2), region_1_limits(2)];
    Two_but_not_one_limits = [region_2_limits(1), region_1_limits(1)];

%   6) Within the tolerance, Region 1 identical to Region 2.
else
    One_but_not_two_limits = [];
    Two_but_not_one_limits = [];
end
    
varargout{1} = Intersection_limits;
varargout{2} = Union_limits;
varargout{3} = One_but_not_two_limits;
varargout{4} = Two_but_not_one_limits;