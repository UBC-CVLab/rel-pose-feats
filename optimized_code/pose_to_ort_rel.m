function X = pose_to_ort_rel( positions, out_pairs, ref_ort, output_radian )
% POS_TO_ORT_REL Calculated relative orientation to all bones.
%
% positions : 2 x num_bones x num_frames
% out_pairs : Indices of all pairs of bones.
% ref_ort   : 1 x num_frames. Reference orientation in radians.
% output_radian :  boolean. Set true to get output in radians [default: false]

Nframes = size(positions,3);
% angle 0 to 180
% ort -180 to 180

num_bones            = size(positions, 2);
id_for_neck_to_belly = 1;
num_pairs            = num_bones*(num_bones - 1)/2;

if nargin < 4,
    output_radian = false;
end
    
if nargin < 3,
    ref_ort = [];
end

if nargin < 2 || isempty(out_pairs),
    out_pairs = zeros(num_pairs, 2);
    p = 0;
    for i = 1 : num_bones,
        for j = (i + 1) : num_bones,
            p = p + 1;
            out_pairs(p, :) = [i, j];
        end
    end
end

assert(num_pairs  == size(out_pairs, 1));
X  = zeros(num_pairs, Nframes);

for iframe = 1 : Nframes,    
    diff_vec    = positions(:, out_pairs(:, 2), iframe) - positions(:,  out_pairs(:, 1), iframe);    
    X(:,iframe) = atan2(diff_vec(2, :), diff_vec(1, :))*180/pi;
end

if isempty(ref_ort),
    ref_ort  = X(id_for_neck_to_belly,:);
    tmp      = X(setdiff(1:end, id_for_neck_to_belly),:);
    tmp      = abs(tmp-repmat(ref_ort, [num_pairs-1 1]));
else    
    tmp      = abs(X-repmat(ref_ort*180/pi, [num_pairs 1]));
end

ind      = (tmp>180);
tmp(ind) = 360-tmp(ind);
X        = tmp;

if output_radian,
    X = X*pi/180;
end


