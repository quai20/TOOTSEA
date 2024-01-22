function RSKerror(errorMessage)

p = inputParser;
addRequired(p,'errorMessage', @ischar);
parse(p, errorMessage)

errorMessage = p.Results.errorMessage;

error(errorMessage)

end

