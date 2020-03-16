%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2017
%
function obss = Subserie(obj,name,t1,t2,lev)
%SUBSERIE Summary of this function goes here
%   Detailed explanation goes here
    obss = TimeSerie(name,obj.Time(t1:t2),obj.Data(lev,t1:t2));
    if(~isempty(obj.Depth))
        obss.Depth=obj.Depth(lev);
    else
        obss.Depth=obj.Depth;
    end
    obss.QC_Serie=obj.QC_Serie(lev,t1:t2);
    obss.Unit=obj.Unit;
    obss.Long_name=obj.Long_name;
    obss.FillValue=obj.FillValue;
    obss.ValidMin=obj.ValidMin;
    obss.ValidMax=obj.ValidMax;
end

