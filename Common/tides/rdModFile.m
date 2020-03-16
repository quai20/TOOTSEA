% function to read model control file
% usage:
% [ModName,GridName,Fxy_ll]=rdModFile(Model,k);
%
% Model - control file name for a tidal model, consisting of lines
%         <elevation file name>
%         <transport file name>
%         <grid file name>
%         <function to convert lat,lon to x,y>
% 4th line is given only for models on cartesian grid (in km)
% All model files should be provided in OTIS format
% k =1/2 for elevations/transports
%
% OUTPUT
% ModName - model file name for elvations/transports
% GridName - grid file name
% Fxy_ll - function to convert lat,lon to x,y
%          (only for models on cartesian grid (in km));
%          If model is on lat/lon grid Fxy_ll=[];

function [ModName,GridName,Fxy_ll]=rdModFile(Model,k)
i1=findstr(Model,filesep);
pname=[];
if isempty(i1)==0,pname=Model(1:i1(end));end
fid=fopen(Model,'r');
ModName=[];GridName=[];Fxy_ll=[];
if fid<1,fprintf('File %s does not exist\n',Model);return;end
hfile=fgetl(fid);
ufile=fgetl(fid);
gfile=fgetl(fid);
i1=strfind(hfile,filesep);
i2=strfind(ufile,filesep);
i3=strfind(gfile,filesep);
% if ~isempty(i3),GridName=gfile;else GridName=[pname gfile];end
% if k==1 & ~isempty(i1),pname=[];end
% if k==2 &  ~isempty(i2),pname=[];end
if ~isempty(i3) && ~strcmp(gfile(1:4),'DATA'),GridName=gfile;else GridName=[pname gfile];end
if k==1 && ~isempty(i1) && ~strcmp(hfile(1:4),'DATA'), pname=[];end
if k==2 &&  ~isempty(i2) && ~strcmp(ufile(1:4),'DATA'), pname=[];end
if k==1,ModName=[pname hfile];else ModName=[pname ufile];end
Fxy_ll=fgetl(fid);
if Fxy_ll==-1,Fxy_ll=[];end
fclose(fid);
return

