function time_tics = nice_time_tics(start_datenum, end_datenum)
% Returns a 'nice' set of datenum tics between two times.
%
% time_tics = nice_time_tics(start_datenum, end_datenum)
%
% Inputs:
%   start_, end_datenum     Matlab datenum format
%
% Output:
%   time_tics               vector of tics in datenum format.

% Kevin J. Delaney
% September 22, 2008
% October 24, 2008      Added time steps of 3, 6 and 12 hours, plus
%                           90, 30, 10 and 5 minutes.
% November 7, 2008      Added time steps of 30, 10, 5 & 2 sec.
% December 6, 2009      Cleaned up handling of month, year tics.
% January 19, 2010      Use wider spacing if more than 15 days.
% February 22, 2010     Use wider spacing if more than 9 months.
% April 7, 2010         Use wider spacing if more than 9 days.
% May 14, 2010          Use 'ceil', not 'round' when determining # of tics.

%   Defaults.
min_nice_num = 3;

if ~exist('start_datenum', 'var')
    help(mfilename);
    time_tics = [];
    return
end

if isempty(start_datenum) || ...
   ~isdatenum(start_datenum)
   % errordlg('Input "start_datenum" is empty or not a valid datenum.', ...
   %     mfilename);
    time_tics = [];
    return
end
    
if ~exist('end_datenum', 'var') || ...
   isempty(end_datenum) || ...
   ~isdatenum(end_datenum)
    %errordlg('Input "end_datenum" is missing, empty or not a valid datenum.', ...
    %    mfilename);
    time_tics = [];
    return
end

time_difference = end_datenum - start_datenum;

[start_year, start_mon, start_day, start_hour, start_min, start_sec] = datevec(start_datenum);
[end_year, end_mon, end_day, end_hour, end_min, end_sec] = datevec(end_datenum);

%   Allow for fractional years, months, etc.
delta_year_total = units(time_difference, 'day', 'year');
delta_mon_total = units(time_difference, 'day', 'month');
delta_day_total = time_difference;
delta_hour_total = units(time_difference, 'day', 'hour');
delta_min_total = units(time_difference, 'day', 'minute');
delta_sec_total = units(time_difference, 'day', 'second');

if delta_year_total > min_nice_num
    tic_start = datenum(start_year, 1, 1, 0, 0, 0);
    tic_end   = datenum(end_year + 1, 1, 1, 0, 0, 0);
    
    %   Maybe interval should be >1 years.
    interval_in_years = max([1, nice_step_size(delta_year_total)]);
    num_tics = round(units(tic_end - tic_start, 'day', 'year') / interval_in_years);
    year_tics = linspace(0, (interval_in_years * num_tics), num_tics+1);
    time_tics = datenum(start_year + year_tics, 1, 1, 0, 0, 0);
    return
    
elseif delta_mon_total >= 18
    tic_start = datenum(start_year, start_mon, 1, 0, 0, 0);
    tic_end   = datenum(end_year, end_mon + 1, 1, 0, 0, 0);

    %   Interval should be 6 months.
    interval_in_months = 6;
    num_tics = ceil(units(tic_end - tic_start, 'day', 'month') / interval_in_months);
    month_tics = linspace(0, (interval_in_months * num_tics), num_tics+1);
    time_tics = datenum(start_year, start_mon + month_tics, 1, 0, 0, 0);
    return
    
elseif delta_mon_total >= 9
    tic_start = datenum(start_year, start_mon, 1, 0, 0, 0);
    tic_end   = datenum(end_year, end_mon + 1, 1, 0, 0, 0);

    %   Interval should be 3 months.
    interval_in_months = 3;
    num_tics = ceil(units(tic_end - tic_start, 'day', 'month') / interval_in_months);
    month_tics = linspace(0, (interval_in_months * num_tics), num_tics+1);
    time_tics = datenum(start_year, start_mon + month_tics, 1, 0, 0, 0);
    return
    
elseif delta_mon_total > min_nice_num
    tic_start = datenum(start_year, start_mon, 1, 0, 0, 0);
    tic_end   = datenum(end_year, end_mon + 1, 1, 0, 0, 0);

    %   Interval should be 1 month1.
    interval_in_months = 1;
    num_tics = ceil(units(tic_end - tic_start, 'day', 'month') / interval_in_months);
    month_tics = linspace(0, (interval_in_months * num_tics), num_tics+1);
    time_tics = datenum(start_year, start_mon + month_tics, 1, 0, 0, 0);
    return
    
elseif delta_day_total > 60
    tic_start = datenum(start_year, start_mon, start_day, 0, 0, 0);
    tic_end = datenum(end_year, end_mon, end_day + 1, 0, 0, 0);
    
    interval_in_days = 14;
    tic_interval = datenum(0, 0, interval_in_days, 0, 0, 0);
    nominal_time_tics = tic_start : tic_interval : tic_end;
    
    if nominal_time_tics(end) > tic_end
        time_tics = [nominal_time_tics(1:(end-1)), tic_end];
    elseif nominal_time_tics(end) < tic_end
        time_tics = [nominal_time_tics, tic_end];
    else
        time_tics = nominal_time_tics;
    end
    
    return
    
elseif delta_day_total >= 15
    tic_start = datenum(start_year, start_mon, start_day, 0, 0, 0);
    tic_end = datenum(end_year, end_mon, end_day + 1, 0, 0, 0);
    
    interval_in_days = 7;
    tic_interval = datenum(0, 0, interval_in_days, 0, 0, 0);
    nominal_time_tics = tic_start : tic_interval : tic_end;
    
    if nominal_time_tics(end) > tic_end
        time_tics = [nominal_time_tics(1:(end-1)), tic_end];
    elseif nominal_time_tics(end) < tic_end
        time_tics = [nominal_time_tics, tic_end];
    else
        time_tics = nominal_time_tics;
    end
    
    return
    
elseif delta_day_total >= 9
    tic_start = datenum(start_year, start_mon, start_day, 0, 0, 0);
    tic_end = datenum(end_year, end_mon, end_day + 1, 0, 0, 0);
    
    interval_in_days = 2;
    tic_interval = datenum(0, 0, interval_in_days, 0, 0, 0);
    nominal_time_tics = tic_start : tic_interval : tic_end;
    
    if nominal_time_tics(end) > tic_end
        time_tics = [nominal_time_tics(1:(end-1)), tic_end];
    elseif nominal_time_tics(end) < tic_end
        time_tics = [nominal_time_tics, tic_end];
    else
        time_tics = nominal_time_tics;
    end
    
    return
    
elseif delta_day_total > min_nice_num
    tic_start = datenum(start_year, start_mon, start_day, 0, 0, 0);
    tic_end = datenum(end_year, end_mon, end_day + 1, 0, 0, 0);
    
    %   Maybe interval should be >1 days.
    interval_in_days = nice_step_size(delta_day_total);
    tic_interval = datenum(0, 0, interval_in_days, 0, 0, 0);
    time_tics = tic_start : tic_interval : tic_end;
    
elseif delta_hour_total >= 60
    %   Move starting point to most recent 12 hour boundary.
    start_hour_lower = 12 * floor(start_hour / 12);
    tic_start = datenum(start_year, start_mon, start_day, start_hour_lower, 0, 0);
    
    %   Move ending point to next 12 hour boundary.
    end_hour_upper = 12 * ceil(end_hour / 12);
    tic_end = datenum(end_year, end_mon, end_day, end_hour_upper, 0, 0);
    
    tic_interval = datenum(0, 0, 0, 12, 0, 0);
    time_tics = tic_start : tic_interval : tic_end;
  
elseif delta_hour_total >= 30
    %   Move starting point to most recent 6 hour boundary.
    start_hour_lower = 6 * floor(start_hour / 6);
    tic_start = datenum(start_year, start_mon, start_day, start_hour_lower, 0, 0);
    
    %   Move ending point to next 6 hour boundary.
    end_hour_upper = 6 * ceil(end_hour / 6);
    tic_end = datenum(end_year, end_mon, end_day, end_hour_upper, 0, 0);
    
    tic_interval = datenum(0, 0, 0, 6, 0, 0);
    time_tics = tic_start : tic_interval : tic_end;

elseif delta_hour_total > 10
    %   Move starting point to most recent 3 hour boundary.
    start_hour_lower = 3 * floor(start_hour / 3);
    tic_start = datenum(start_year, start_mon, start_day, start_hour_lower, 0, 0);
    
    %   Move ending point to next 3 hour boundary.
    end_hour_upper = 3 * ceil(end_hour / 3);
    tic_end = datenum(end_year, end_mon, end_day, end_hour_upper, 0, 0);
    
    tic_interval = datenum(0, 0, 0, 3, 0, 0);
    time_tics = tic_start : tic_interval : tic_end;

elseif delta_hour_total >= 3
    %   Move starting point to most recent 1 hour boundary.
    tic_start = datenum(start_year, start_mon, start_day, start_hour, 0, 0);
    
    %   Move ending point to next 1 hour boundary.
    tic_end = datenum(end_year, end_mon, end_day, end_hour + 1, 0, 0);
    
    tic_interval = datenum(0, 0, 0, 1, 0, 0);
    time_tics = tic_start : tic_interval : tic_end;
      
elseif delta_min_total > 90
    %   Move starting point to most recent 30 minute boundary.
    start_min_lower = 30 * floor(start_min / 30);    
    tic_start = datenum(start_year, start_mon, start_day, start_hour, start_min_lower, 0);
    
    %   Move ending point to next 30 minute boundary.
    end_min_upper = 30 * ceil(end_min / 30);    
    tic_end = datenum(end_year, end_mon, end_day, end_hour, end_min_upper, 0);
    
    tic_interval = datenum(0, 0, 0, 0, 30, 0);
    time_tics = tic_start : tic_interval : tic_end;

elseif delta_min_total > 45
    %   Move starting point to most recent 10 minute boundary.
    start_min_lower = 10 * floor(start_min / 10);    
    tic_start = datenum(start_year, start_mon, start_day, start_hour, start_min_lower, 0);
    
    %   Move ending point to next 10 minute boundary.
    end_min_upper = 10 * ceil(end_min / 10);    
    tic_end = datenum(end_year, end_mon, end_day, end_hour, end_min_upper, 0);
    
    tic_interval = datenum(0, 0, 0, 0, 10, 0);
    time_tics = tic_start : tic_interval : tic_end;
    
elseif delta_min_total > 10
    %   Move starting point to most recent 5 minute boundary.
    start_min_lower = 5 * floor(start_min / 5);    
    tic_start = datenum(start_year, start_mon, start_day, start_hour, start_min_lower, 0);
    
    %   Move ending point to next 5 minute boundary.
    end_min_upper = 5 * ceil(end_min / 5);    
    tic_end = datenum(end_year, end_mon, end_day, end_hour, end_min_upper, 0);
    
    tic_interval = datenum(0, 0, 0, 0, 5, 0);
    time_tics = tic_start : tic_interval : tic_end;
    
elseif delta_min_total > 3
    tic_start = datenum(start_year, start_mon, start_day, start_hour, start_min, 0);
    tic_end = datenum(end_year, end_mon, end_day, end_hour, end_min + 1, 0);

    tic_interval = datenum(0, 0, 0, 0, 1, 0);
    time_tics = tic_start : tic_interval : tic_end;
    
elseif delta_sec_total >= 120
    %   Move starting point to most recent 30 sec boundary.
    start_sec_lower = 30 * floor(start_sec / 30);
    tic_start = datenum(start_year, start_mon, start_day, start_hour, start_min, start_sec_lower);
    
    %   Move ending point to next 30 sec boundary.
    end_sec_upper = 30 * ceil(end_sec / 30);
    tic_end = datenum(end_year, end_mon, end_day, end_hour, end_min, end_sec_upper);
    
    tic_interval = datenum(0, 0, 0, 0, 0, 30);
    time_tics = tic_start : tic_interval : tic_end;
    
elseif delta_sec_total >= 60 
    %   Move starting point to most recent 10 sec boundary.
    start_sec_lower = 10 * floor(start_sec / 10);
    tic_start = datenum(start_year, start_mon, start_day, start_hour, start_min, start_sec_lower);
    
    %   Move ending point to next 10 sec boundary.
    end_sec_upper = 10 * ceil(end_sec / 10);
    tic_end = datenum(end_year, end_mon, end_day, end_hour, end_min, end_sec_upper);
    
    tic_interval = datenum(0, 0, 0, 0, 0, 10);
    time_tics = tic_start : tic_interval : tic_end;
    
elseif delta_sec_total >= 20 
    %   Move starting point to most recent 5 sec boundary.
    start_sec_lower = 5 * floor(start_sec / 5);
    tic_start = datenum(start_year, start_mon, start_day, start_hour, start_min, start_sec_lower);
    
    %   Move ending point to next 5 sec boundary.
    end_sec_upper = 5 * ceil(end_sec / 5);
    tic_end = datenum(end_year, end_mon, end_day, end_hour, end_min, end_sec_upper);
    
    tic_interval = datenum(0, 0, 0, 0, 0, 5);
    time_tics = tic_start : tic_interval : tic_end;
    
elseif delta_sec_total >= 10 
    %   Move starting point to most recent 2 sec boundary.
    start_sec_lower = 2 * floor(start_sec / 2);
    tic_start = datenum(start_year, start_mon, start_day, start_hour, start_min, start_sec_lower);
    
    %   Move ending point to next 2 sec boundary.
    end_sec_upper = 2 * ceil(end_sec / 2);
    tic_end = datenum(end_year, end_mon, end_day, end_hour, end_min, end_sec_upper);
        
    tic_interval = datenum(0, 0, 0, 0, 0, 2);
    time_tics = tic_start : tic_interval : tic_end;

else
    tic_start = datenum(start_year, start_mon, start_day, start_hour, start_min, floor(start_sec));
    tic_end = datenum(end_year, end_mon, end_day, end_hour, end_min, ceil(end_sec));
    
    tic_interval = datenum(0, 0, 0, 0, 0, 1);
    time_tics = tic_start : tic_interval : tic_end;
end

%   Don't cut off the end of the data.
if time_tics(end) < tic_end
    time_tics = [time_tics, time_tics(end) + tic_interval];
end
