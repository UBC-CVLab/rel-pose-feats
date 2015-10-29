function [fmp_parts_name, fmp_part_ind] = fmp_parts()
% FMP_PARTS Define and list FMP parts.
%
% Output:
%   fmp_parts_name - 1x26 cell of strings. FMP parts.
%   fmp_part_ind   - Map. part_name->index.
%
% ----------
% Ankur
fmp_parts_name = {...
    'head', ... %1
    'neck', ... %2
    'lshoulder', ... %3
    'luparm', ... % 4
    'lelbow', ... % 5
    'lforearm', ... % 6
    'lhand', ... % 7
    'labdmn1', ...% 8
    'labdmn2',... % 9
    'lhip',... % 10
    'lthigh',... % 11
    'lknee',... % 12
    'lshin',... % 13
    'lfoot',... % 14
    'rshoulder', ... %15
    'ruparm', ... % 16
    'relbow', ... % 17
    'rforearm', ... % 18    
    'rhand', ... % 19
    'rabdmn1', ...% 20
    'rabdmn2',... % 21
    'rhip',... % 22
    'rthigh',... % 23
    'rknee',... % 24
    'rshin',... % 25
    'rfoot',... % 26
    };
if nargout>1
    inds = 1:size(fmp_parts_name, 2);
    fmp_part_ind = containers.Map(fmp_parts_name, inds);
end