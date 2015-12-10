function xyz = trans2xyz(trans)
%TRANS2XYZ Get the XYZ location of a joint given the transformation matrix.
%
% Input
%    trans : 1xnum_bones cell array of 1xnum_frames cell array of 3x4 matrices.
% 
% Output
%    xyz   : 1xnum_bones cell array of 3xnum_frames matrices.
%

% Ankur
xyz                 = trans;
not_empty_inds      = cellfun(@(x)(~isempty(x)), xyz);
xyz(not_empty_inds) = cellfun(@(x) reshape(x(:, 4, :), 3, []), trans(not_empty_inds), 'UniformOutput', false);
end

