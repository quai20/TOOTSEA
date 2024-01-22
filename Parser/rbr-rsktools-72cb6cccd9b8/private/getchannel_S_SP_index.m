function [Scol,SPcol] = getchannel_S_SP_index(RSK)
    try
        Scol = getchannelindex(RSK, 'Salinity');
    catch
        RSKerror('RSKderiveSA requires practical salinity. Use RSKderivesalinity...');
    end
    try
        SPcol = getchannelindex(RSK, 'Sea Pressure');
    catch
        RSKerror('RSKderiveSA requires sea pressure. Use RSKderiveseapressure...');
    end
end
