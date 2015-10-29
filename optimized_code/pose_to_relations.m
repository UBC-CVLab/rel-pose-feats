function X = pose_to_relations(positions, dist_pairs)
% positions  : 2 x num_joints x num_frames
% dist_pairs : 2 x num_pairs

Nframes    = size(positions, 3);
num_joints = size(positions, 2);
num_pairs  = num_joints*(num_joints - 1)/2;
if nargin < 2 || isempty(dist_pairs),
    dist_pairs = zeros(num_pairs, 2);
    p = 0;
    for i = 1 : num_joints,
        for j = i + 1 : num_joints,
            p = p + 1;
            dist_pairs(p, :) = [i,j];
        end
    end
end
assert(num_pairs == size(dist_pairs, 1));

X = zeros(num_pairs,Nframes);

for iframe = 1:Nframes
    diff_vec    = positions(:, dist_pairs(:, 1), iframe) - positions(:,  dist_pairs(:, 2), iframe);
    %     if dim3,
    %         nvec = sqrt(sum(diff_vec(1,:).^2 + diff_vec(2,:).^2 + diff_vec(3,:).^2, 1));
    %     else
    %         nvec = sqrt(sum(diff_vec(1,:).^2 + diff_vec(2,:).^2, 1));
    %     end
    % nvec = cellfun(@norm, num2cell(diff_vec, 1));
    nvec = sqrt(sum(diff_vec.^2, 1));
    % assert(all(nvec - nvec_new)<10^-6);
    X(:, iframe) = nvec;
end
