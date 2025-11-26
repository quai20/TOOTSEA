%
% K.BALEM - IFREMER/LOPS
% Developped for TOOTSEA 2024
%
function QC_out = above_sealevel(PARAM,DEPTH)
%
% QC 4 for above sea level ADCP data
%
QC_out = PARAM.QC_Serie;
for i=1:size(PARAM.Data,2)
  for lev=1:size(PARAM.Data,1)
    if(DEPTH.Data(i)-PARAM.Depth(lev))<0
        QC_out(lev,i)=4;
    end
  end
end

