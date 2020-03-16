function sample_data = readSBE26_quartz(filename)
%filename = 'Data_test/SBE/SBE 56 and SBE 26 Example Files/26plus/SBE26plus n° 1019_Saint-Florent.hex'
fid = fopen(filename, 'rt');

header_expr       = '^[\*]\sSBE\s(\w*)\sV\s([\w.]*)\s*SN\s*(\w*)';
cal_coeff_expr    = '^[\*]\s*(\w+)\s*=\s*(\S+)\s*$';
pressure_cal_expr = '^[\*].*\w*pressure sensor.*serial number\s*=\s*(\w*).*range\s*=\s*(\w*)\s*psia.*';
    
sample_data.input_file          = filename;
sample_data.meta.instrument_make        = 'Sea-bird Electronics';
%
line = fgetl(fid);
while isempty(line) || line(1) == '*' || line(1) == 's'
 % 
  if isempty(line) || line(1) == 's'
    line = fgetl(fid);
    continue;
  end    
  % try for calibration coefficient line first
  tkn = regexp(line, cal_coeff_expr, 'tokens');
  if ~isempty(tkn)
    % save the calibration coefficient 
    sample_data.meta.(tkn{1}{1}) = str2double(tkn{1}{2});
    line = fgetl(fid);
    continue;
  end     
  % not sensor info - try pressure sensor info
  tkn = regexp(line, pressure_cal_expr, 'tokens');
  if ~isempty(tkn)    
    sample_data.meta.pressure_serial_no        = strtrim(tkn{1}{1});
    sample_data.meta.pressure_range_psia       = str2double(tkn{1}{2});    
    line = fgetl(fid);   
    continue;
  end    
  % ok, try instrument info  
  tkn = regexp(line, header_expr, 'tokens');
  if ~isempty(tkn)
    sample_data.meta.instrument_model     = tkn{1}{1};
    sample_data.meta.instrument_firmware  = tkn{1}{2};
    sample_data.meta.instrument_serial_no = tkn{1}{3};
  end  
  line = fgetl(fid);
end
% we read one too many lines in the calibration 
% parsing, so we need to backtrack
fseek(fid, -length(line) - 1, 'cof');
line = fgetl(fid);
sample_data.burst.data=[];
sample_data.data=[];
while (~strcmp(line,'S>'))
  if(strcmp(line,'FFFFFFFFBFFFFFFFF'))  
      %read tide parameters on 2 lines (http://www.seabird.com/sites/default/files/documents/26plus_019_0.pdf)
      line=fgetl(fid);
      %time of beginning of first tide sample
      sec2000 = (hex2dec(line(1:8)));
      sample_data.meta.firstsampletime = datestr((sec2000+datenum(2000,01,01)*24*3600)/(24*3600));      
      line=fgetl(fid);
      %tide sample interval, wave integration period
      sample_data.meta.sampleinterval = (hex2dec(line(1:4)));
      sample_data.meta.numberofperiod = (hex2dec(line(5:8)));
      %
      line=fgetl(fid); %SKIP LINE FFFFFFFFFCFFFFFFFF
      line=fgetl(fid); 
  end
  %
  if(strcmp(line,'000000000000000000'))  
      %read burst parameters on 2 lines (http://www.seabird.com/sites/default/files/documents/26plus_019_0.pdf)
      line=fgetl(fid);
      %time of beginning of wave burst, number of samples in burst
      sec2000 = (hex2dec(line(1:8)));
      sample_data.burst.starttime = datestr((sec2000+datenum(2000,01,01)*24*3600)/(24*3600));      
      sample_data.burst.numberofsample = (hex2dec(line(9:12)));
      line=fgetl(fid);
      %pressure temperature compensation number, number of samples in burst
      sample_data.burst.PTCF = (hex2dec(line(1:8)))/256;                   
      sample_data.burst.numberofsample = (hex2dec(line(9:12)));
      line=fgetl(fid);
      %then read burst data
      while(~strcmp(line,'FFFFFFFFFFFFFFFFFF'))
          %read wave burst pressure data %(see http://www.seabird.com/sites/default/files/documents/26plus_019_0.pdf)                   
          U = ( (1.0/sample_data.burst.PTCF) * 1000000 ) - sample_data.meta.U0;
          C = sample_data.meta.C1 + (sample_data.meta.C2 * U) + (sample_data.meta.C3 * U^2);
          D = sample_data.meta.D1 + sample_data.meta.D2 ;
          T0 = (sample_data.meta.T1 + sample_data.meta.T2 * U + sample_data.meta.T3 * U^2 + ...
              sample_data.meta.T4 * U^3) / 1000000 ;                   
          prenum1 = hex2dec(line(1:6))/256; %read lines
          prenum2 = hex2dec(line(7:12))/256; %read lines
          W1 = 1.0 - (T0 * T0 * prenum1 * prenum1) ;
          W2 = 1.0 - (T0 * T0 * prenum2 * prenum2) ;
          pressure1 = (C * W1 * (1.0 - D * W1));
          pressure2 = (C * W2 * (1.0 - D * W2));
          sample_data.burst.data=[sample_data.burst.data; pressure1*0.00689475728 pressure2*0.00689475728 ];
          line=fgetl(fid);
      end
      line=fgetl(fid);
  end
  %read tide pressure, temperature, time
  pressured = (hex2dec(line(1:6))-sample_data.meta.B)/sample_data.meta.M; 
  temperatured = (hex2dec(line(7:10)))/1000 - 10;
  timed = (hex2dec(line(11:18)));
  sample_data.data=[sample_data.data; pressured*0.00689475728 temperatured ((timed+datenum(2000,01,01)*24*3600)/(24*3600))];      
  line=fgetl(fid);
end

fclose(fid);