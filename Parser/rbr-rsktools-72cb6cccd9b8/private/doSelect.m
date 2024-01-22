function [results] = doSelect(RSK, sql)

    mksqlite('open', RSK.toolSettings.filename);
    results = mksqlite(sql);
    mksqlite('close')
    
end