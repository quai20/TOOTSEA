function QCout = NaNifyQC(DATA)

TEMPQ=DATA.QC_Serie;

for k=1:size(DATA.Data,1)
ind=isnan(DATA.Data(k,:));
TEMPQ(k,ind)=NaN;
end

QCout = TEMPQ;

