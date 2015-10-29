function positions = pose_to_normalized(positions, ref_bone_positions)
% POSE_TO_NORMALIZED A more general version of POSITIONS_TO_NORMALIZEDPOSITIONS
num_bones = size(positions, 2);

% between neck and belly
if nargin < 2,
    ref_bone_positions = (positions(:,2,:) + positions(:,1,:))/2;
elseif numel(size(ref_bone_positions))==2,
    ref_bone_positions = permute(ref_bone_positions, [1 3 2]);
end
nxy        = size(positions, 1);
num_joints = size(positions, 2);

positions  = positions - repmat(ref_bone_positions, [1 num_bones 1]);
positions  = reshape(positions, nxy*num_joints,[]);
end