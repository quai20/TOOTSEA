function RSKwarning(warningMessage)

p = inputParser;
addRequired(p,'warningMessage', @ischar);
parse(p, warningMessage)

warningMessage = p.Results.warningMessage;

disp(warningMessage)

end

