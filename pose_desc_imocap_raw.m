function [norm_pos, dist_rel, angle_rel, ort_rel, cart_traj, radial_traj, dist_rel_traj,...
    angle_rel_traj, ort_rel_traj] = pose_desc_imocap_raw(imocap, frame_range, theta, phi, opt, no_flip)
% POSE_DESC_IMOCAP Get the raw pose descriptor (without whitening and normalization) from imocap.
if nargin < 6,
    no_flip = false;
end
if ~isfield(imocap, 'xyz_mat')                         ,
    imocap.xyz_mat = trans2xyz_mat(imocap.trans);  % This may be useful in certain cases.
end
joint_loc   = imocap.xyz_mat;
HIP_IND     = 1;
NUM_JOINTS  = 14;
num_pairs   = NUM_JOINTS*(NUM_JOINTS - 1)/2;
num_triples = 3*NUM_JOINTS*(NUM_JOINTS - 1)*(NUM_JOINTS - 2)/6;
dist_pairs    = zeros(num_pairs, 2);
angle_triples = zeros(num_triples, 3);
p_ind = 0;
q_ind = 0;
for ii = 1 : NUM_JOINTS,
    for iii = ii + 1: NUM_JOINTS,
        p_ind = p_ind + 1;
        dist_pairs(p_ind, :) = [ii,iii];
    end        
    for ij = 1 : NUM_JOINTS,            
        if ij~=ii,
            for ik = 1:NUM_JOINTS,                
                % Remove reversed indices.
                is_reversed = sum( (angle_triples(:, 1) == ik) & ...
                    (angle_triples(:, 2)== ij) & (angle_triples(:, 3)== ii) );
                
                if ik~=ii && ik~=ij && ~is_reversed,
                    q_ind = q_ind + 1;
                    angle_triples(q_ind, :) = [ii ij ik];
                end                
            end
        end
    end
end

D          = 1000;
look_at    = joint_loc(1+3*(HIP_IND-1):3*HIP_IND, 1); % first frame
% Compute the camera matrix and position for the whole sequence.
C          = cam_matrix_theta_phi(theta, phi, D, look_at');

[corres, imocap_part_ind] = fmp_imocap_corres();
left_shoulder_ind  = imocap_part_ind('LeftArm');
right_shoulder_ind = imocap_part_ind('RightArm');

num_frames = numel(frame_range);
% Allocate memory here.
cumu_pose  = zeros(2, NUM_JOINTS, num_frames);

ind = 1;
for frame = frame_range,

    bone_loc_3d  = reshape(joint_loc(:, frame), 3, []);
    pts2d_imocap = render_orthographic(bone_loc_3d, C);
    curr_corres  = corres{2};
    if ~no_flip,
        % Left is actually in the the left, i.e. person facing front.
        lsx = pts2d_imocap(1, imocap.data_inds(left_shoulder_ind));
        rsx = pts2d_imocap(1, imocap.data_inds(right_shoulder_ind));
        if  lsx > rsx,
            curr_corres = corres{1};
        end
    end
    pose2d = pts2d_imocap(:, imocap.data_inds(curr_corres));
%     clf;
%     draw_bones2d(pose2d, 0);
%     pause(1/3);
            
    cumu_pose(:, :, ind)  = pose2d;    
    ind                   = ind + 1;
end
shoulders         = [find(curr_corres == imocap_part_ind('LeftArm')) find(curr_corres==imocap_part_ind('RightArm'))];
hips              = [find(curr_corres == imocap_part_ind('LeftUpLeg')) find(curr_corres==imocap_part_ind('RightUpLeg'))];
neck              = curr_corres == imocap_part_ind('Neck1');

diff_torso        = mean(cumu_pose(:, hips, :), 2) - mean(cumu_pose(:, shoulders, :), 2);
torso_height      = sqrt(sum(reshape(diff_torso, 2, []).^2, 1));
median_normalizer = median(torso_height);

% rescale such that median torso height is 1.
positions     = cumu_pose./median_normalizer;
ref_joint_loc = squeeze(mean(positions(:, hips, :), 2));
neck_loc      = squeeze(positions(:, neck, :));
diff_vec      = ref_joint_loc - neck_loc;
ref_joint_ort = atan2(diff_vec(2, :), diff_vec(1, :));


[norm_pos, dist_rel, angle_rel, ort_rel, cart_traj, radial_traj, dist_rel_traj,...
    angle_rel_traj, ort_rel_traj] = pose_2d_motion_rel_desc(positions, ...
    ref_joint_loc, ref_joint_ort, dist_pairs, angle_triples, opt, true);
