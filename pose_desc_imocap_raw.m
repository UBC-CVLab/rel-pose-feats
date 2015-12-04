function [norm_pos, dist_rel, angle_rel, ort_rel, cart_traj, radial_traj, dist_rel_traj,...
    angle_rel_traj, ort_rel_traj] = pose_desc_imocap_raw(imocap, frame_range, theta, phi, opt)
% POSE_DESC_IMOCAP Get the raw pose descriptor (without whitening and normalization) from imocap.
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
look_at    = imocap.xyz{HIP_IND}(:, 1); % first frame
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
    % Get 3D locations of different bones.
    bone_loc_3d  = zeros(size(imocap, 2), 3);
    
    for i=1:size(imocap.xyz, 2),
        bone_loc = imocap.xyz{1, i};
        if ~isempty(bone_loc)
            bone_loc_3d(i, :) = bone_loc(:, frame)';
        end
        % We have 2d pose for each frame so we do not need to check if 2d pose exists for this frame.
    end
    pts2d_imocap = render_orthographic(bone_loc_3d', C);
    
    % Left is actually in the the left, i.e. person facing front.
    lsx = pts2d_imocap(1, left_shoulder_ind);
    rsx = pts2d_imocap(1, right_shoulder_ind);
    if  lsx > rsx,
        curr_corres = corres{1};
    else
        curr_corres = corres{2};
    end
    pose2d = pts2d_imocap(:, curr_corres);
    %clf;
    %draw_bones2d(pose2d, []);
    %pause;
           
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
% 
% for f_i = 1 : numel(frame_range),
%     clf;
%     hold on;
%     plot(ref_joint_loc(1, f_i), ref_joint_loc(2, f_i), 'bd');
%     draw_bones2d(positions(:, :, f_i), []);
%     
%     pause(1/30);
% end
% opt = struct('T', 7, 's', 3);
[norm_pos, dist_rel, angle_rel, ort_rel, cart_traj, radial_traj, dist_rel_traj,...
    angle_rel_traj, ort_rel_traj] = pose_2d_motion_rel_desc(positions, ...
    ref_joint_loc, ref_joint_ort, dist_pairs, angle_triples, opt, true);
