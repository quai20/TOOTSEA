function Data_out = surfAdcpNan(DATA,DEPH)

for i=1:length(DATA.Time)    
    dbin=DEPH.Data(i)-DATA.Depth;    
    for j=1:length(dbin)
        if(dbin(j)<0)
           Data_out(j,i)=NaN;            
        else
           Data_out(j,i)=DATA.Data(j,i);             
        end
    end           
end
