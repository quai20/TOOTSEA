function N = num_dims(X)
% Returns the number of dimensions of matrix X; like "ndims" but will report a 1 X m  vector as having one dimension.
%
% N = num_dims(X)
%
% Input:
%   X
%
% Output:
%   N

% Kevin J. Delaney
% January 29, 2009

N = [];

if ~exist('X', 'var')
    help(mfilename);
    return
end

if isempty(X)
    N = 0;
    return
end

dim_vector = size(X);

if length(dim_vector) > 2
    N = ndims(X);
else
    N = sum(dim_vector > 1);
end