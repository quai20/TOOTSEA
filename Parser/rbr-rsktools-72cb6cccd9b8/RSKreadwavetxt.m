function [RBR] = RSKreadwavetxt(file)

% RSKreadwavetxt - Reads wave data from a Ruskin txt export.
%
% Syntax:  RSK = RSKreadwavetxt(file)
% 
% DISCLAIMER: This script is meant as a temporary solution to a bug in
% Ruskin that prevents export of large RSK files to Matlab format,
% specifically for files obtained from "wave"-type loggers. This
% function may disappear in the future.
%
% Reads the Ruskin exported text data for a "wave" instrument into a
% Matlab structure comparable to what would have been obtained using
% the Ruskin Matlab export. 
% 
% Inputs: 
%    file - Filename of the text export archive directory to be read. Note
%           that Ruskin exports a zip file of the folder containing the
%           metadata and all the data tables, with each data type (data,
%           burst, events, wave, etc) stored as separately named csv files.
%
% Outputs:
%    RBR - Structure containing the data.
%
% Example: 
%    system('unzip 099999_20160517_1200.zip') % not necessary if already unzipped
%    RBR = RSKreadwavetxt('099999_20160517_1200');
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2016-05-17

%metadatafile = [file filesep file '_metadata.txt'];
datafile = [file filesep file '_data.txt'];
wavefile = [file filesep file '_wave.txt'];
burstfile = [file filesep file '_burst.txt'];

datastruct = table2struct(readtable(datafile), 'ToScalar', true);
wavedatastruct = table2struct(readtable(wavefile), 'ToScalar', true);
burstdatastruct = table2struct(readtable(burstfile), 'ToScalar', true);

channelnames = {'Pressure'; 'Sea pressure'; 'Depth'; 'Tidal slope'; 'Significant wave height'; 'Maximum wave height'; 'Average wave height'; '1/10 wave height'; 'Wave energy'};

% create data matrix
ind = find(ismember(datastruct.Time,wavedatastruct.Time));

data = horzcat(datastruct.Pressure(ind), datastruct.SeaPressure(ind), datastruct.Depth(ind), ...
               datastruct.TidalSlope(ind), wavedatastruct.SignificantWaveHeight, ... 
               wavedatastruct.MaximumWaveHeight, wavedatastruct.AverageWaveHeight, ...
               wavedatastruct.x1_10WaveHeight, wavedatastruct.WaveEnergy);
sampletimes = datenum(datastruct.Time);

burstsamplinglength = sum(burstdatastruct.Burst == 1);
n = burstsamplinglength*length(sampletimes) - length(burstdatastruct.Burst);
burstdatastruct.Burst = [burstdatastruct.Burst; zeros(n, 1)];
burstdatastruct.Pressure = [burstdatastruct.Pressure; zeros(n, 1)];
burstdatastruct.Wave = [burstdatastruct.Wave; zeros(n, 1)];
wavedata = struct('burstheight', wavedatastruct.SignificantWaveHeight, ...
                  'burstperiod', wavedatastruct.SignificantWavePeriod, ...
                  'averageperiod', wavedatastruct.AverageWavePeriod, ...
                  'burstdata', reshape(burstdatastruct.Pressure, burstsamplinglength, length(sampletimes)), ...
                  'burstwave', reshape(burstdatastruct.Wave, burstsamplinglength, length(sampletimes)));

sampletimes = sampletimes(ind);   
wavedata.burstdata = wavedata.burstdata(:,ind);
wavedata.burstwave = wavedata.burstwave(:,ind);
              
% create structures
RBR.channelnames = channelnames;
RBR.sampletimes = sampletimes;
RBR.data = data;
RBR.wavedata = wavedata;

end