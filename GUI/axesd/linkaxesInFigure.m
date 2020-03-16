function linkaxesInFigure(varargin)
% linkaxesInFigure - Finds all visible axes in figure and links them for zooming
% 
% Syntax: linkaxesInFigure(varargin)
% varargin - Can be 'x', 'y', 'xy', 'off'  Same functionality as linkaxes
%   Example:
%       figure;
%       subplot(2,1,1);
%       plot(rand(10,1));
%       subplot(2,1,2);
%       plot(1:10);
%       linkaxesInFigure('x')
%
%   See also: linkaxes

% AUTHOR    : Dan Kominsky
% Copyright 2012  Prime Photonics, LC.
%%
  if (nargin == 0) || ~ischar(varargin{1})
    linkAx = 'xy';
  else
    linkAx = lower(varargin{1});
  end
  
  x = findobj(gcf,'Type','axes','Visible','on');
  try
    linkaxes(x,linkAx)
  catch ME
    disp(ME.message)
  end
