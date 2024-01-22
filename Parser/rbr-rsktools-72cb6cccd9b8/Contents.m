% RSKTOOLS
% Version 3.5.3 2021-09-22
%
% 1.  This toolbox depends on the presence of a functional mksqlite
% library.  We have included a couple of versions here for Windows (32 bit/
% 64 bit), Linux (64 bit) and Mac (64 bit).  If you might need to compile
% another version, the source code can be downloaded from 
% https://sourceforge.net/projects/mksqlite/files/. RSKtools currently uses
% mksqlite Version 2.5.
%
% 2.  Opening an RSK file.  Use RSKopen with a filename as the argument:
%
% RSK = RSKopen('sample.rsk');  
%
% This generates an RSK structure with all the metadata from the database, 
% and a downsampled version of the data.  The downsampled version is useful
% for generating figures of very large data sets.
%
% 3.  Use RSKreaddata to read data from the RSK file:
%
% RSK = RSKreaddata(RSK, 't1', <starttime>, 't2', <endtime>); 
%
% This reads a portion of the 'data' table into the RSK structure
% (replacing any previous data that was read this way).  The <starttime>
% and <endtime> values are the range of data to be read.  Depending on the
% amount of data in your dataset, and the amount of memory in your
% computer, you can read bigger or smaller chunks before Matlab will
% run out of memory.  The times are specified using the Matlab 'datenum' 
% format. You will find the start and end times of the deployment useful
% reference points - these are contained in the RSK structure as the
% RSK.epochs.starttime and RSK.epochs.endtime fields.
%
% 4.  Plot the data!
%
% RSKplotdata(RSK)
%
% This generates a time series plot using the full 'data' that you read in,
% rather than just the downsampled version.  It labels each sublot with the 
% appropriate channel name, so you can get an idea of how to do
% better processing.
%
%
% User files
%   RSKopen                 - open an RBR RSK file and read metadata and downsample data
%   RSKreaddata             - read full dataset from database
%   RSKreadprofiles         - reads and organized data into a series of profiles
%   RSKreadburstdata        - reads burst data for wave file
%   RSKreadcalibrations     - read the calibrations table of an RSK file
%   RSKfindprofiles         - detect profile start and end times using pressure and conductivity
%   RSKtimeseries2profiles  - convert time series data in current rsk structure into profiles
%   CSV2RSK                 - read CSV file into rsk structure in MATLAB
%   RSKderivedepth          - derive depth from pressure
%   RSKderivesalinity       - derive salinity from conductivity, temperature, and sea pressure
%   RSKderiveseapressure    - derive sea pressure from pressure
%   RSKderivevelocity       - derive profiling rate from depth and time
%   RSKderiveC25            - derive specific conductivity at 25 degree Celsius
%   RSKderiveO2             - derive O2 saturation or concentration
%   RSKderivebuoyancy       - derive buoyancy frequency and stability
%   RSKderivesigma          - derive density anomaly relative to P = 0 dbar
%   RSKderivetheta          - derive potential temperature
%   RSKderiveSA             - derive absolute salinity
%   RSKderivesoundspeed     - derive speed of sound in seawater
%   RSKderiveBPR            - derive temperature and pressure from bottom pressure recorder (BPR) period data
%   RSKderiveA0A            - correct RBRquartz³ BPR|zero pressure data for drift using the A-zero-A method
%   RSKcalculateCTlag       - estimate optimal conductivity shift relative to temperature
%   RSKalignchannel         - align a channel in time using a specified lag
%   RSKbinaverage           - bin average the profile data by reference channel intervals
%   RSKcorrecthold          - identify, and then remove or replace zero-order hold points in data
%   RSKcorrectTM            - correct thermal mass inertia effect
%   RSKcorrecttau           - sharpen sensor response
%   RSKdespike              - statistically identify and treat spikes in data
%   RSKremoveloops          - remove values exceeding a threshold profiling rate and pressure reversals
%   RSKsmooth               - apply low-pass filter to data
%   RSKtrim                 - remove or NaN channel data fitting specified criteria
%   RSKgenerate2D           - grid and organize data into a 2D array (e.g., time x depth)
%   RSKcentrebursttimestamp - set the burst timestamps to the centre of each burst period instead of the beginning
%   RSKplotdata             - plot data as a time series
%   RSKplotprofiles         - plot depth profiles for each channel
%   RSKimages               - display bin averaged data in a time-depth heat map
%   RSKplotTS               - plot TS diagram
%   RSKplotburstdata        - plot burst data for wave file
%   RSKplotdownsample       - plot time series of downsampled data
%   RSK2CSV                 - write channel data and metadata to one or more CSV files
%   RSK2ODV                 - write channel data and metadata to one or more ODV files
%   RSK2RSK                 - write rsk file using current rsk structure
%   RSK2MAT                 - write RSK structure to legacy Ruskin .mat format
%   RSKcreate               - convert any data into rsk structure
%   RSKaddchannel           - add a new channel to existing RSK structure
%   RSKaddstationdata       - add station data to RSK data structure
%   RSKremovecasts          - remove either downcasts or upcasts in the RSK structure
%   RSKappendtolog          - append the entry and current time to the log field
%   RSKsettings             - set up global parameters for RSKtools
%   RSKprintchannels        - display channel names and units in MATLAB command window
%
%
% Additional useful files
%   getchannelindex         - returns column index to the data table given a channel name
%   getdataindex            - returns index into the RSK data array given profile numbers and cast directions
%   readsamplingperiod      - returns logger sample interval in seconds
%
%
% For more information, check out documents in QuickStart folder and our
% online user manual: https://docs.rbr-global.com/rsktools
%
%
