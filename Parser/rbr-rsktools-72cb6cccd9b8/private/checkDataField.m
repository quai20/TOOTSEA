function checkDataField(RSK)

if ~isfield(RSK,'data')
    RSKerror('RSK structure does not contain any data, use RSKreaddata or RSKreadprofiles.')
end

end