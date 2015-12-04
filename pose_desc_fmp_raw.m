function [norm_pos, dist_rel, angle_rel, ort_rel, cart_traj, radial_traj, dist_rel_traj,...
    angle_rel_traj, ort_rel_traj] = pose_desc_fmp_raw(pose2dcell, frame_range, opt)
% POSE_DESC_FMP This function calculates relational pose features
% (unnormalized/raw) from the FMP pose estimates. We assume that every frame has a pose estimate. 
%
% pose2dcell  : 1 x num_frames cell array, each  
%                  - either containing kx28 pose estimates returned by FMP. (14 joints)
%                  - or 2 x 14 already simplified pose.
% frame_range : 1 x N array. Generates descriptors for these frames indices in pose2dcell.
% opt         : Struct. {T: traj length (num previous frames to consider), s: trajectory_step}
%

% Ankur

NUM_JOINTS    = 14;
num_pairs     = NUM_JOINTS*(NUM_JOINTS - 1)/2;
num_triples   = 3*NUM_JOINTS*(NUM_JOINTS - 1)*(NUM_JOINTS - 2)/6;
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

num_frames = numel(frame_range);

% Allocate memory here.
cumu_pose                 = zeros(2, NUM_JOINTS, num_frames);
[corres, imocap_part_ind] = fmp_imocap_corres();
curr_corres               = corres{2}; % This is the default one.

[~, fmp_part_map] = fmp_parts();

% To standardize the joint order
jid		   = @(x) fmp_part_map(x);
joint_maps = [jid('head') jid('neck') jid('lshoulder') jid('lelbow') jid('lhand') jid('lhip') ...
    jid('lknee') jid('lfoot') jid('rshoulder') jid('relbow') jid('rhand') jid('rhip') ...
    jid('rknee') jid('rfoot')];

ind = 1;
for fr_i = frame_range,
        
    fmp_boxes = pose2dcell{fr_i};
    if ~isempty(fmp_boxes) 
        % If in the orginal fmp format.
        if (size(fmp_boxes, 2)==106),
            curr_pose = fmp_boxes_to_simplified_pose(fmp_boxes(1, :), [], joint_maps);
        else % already in simplified format.
            curr_pose = fmp_boxes;
        end
        cumu_pose(:, :, ind)   = curr_pose;
        ind  = ind + 1;
    else
        warning('Missing FMP response...%d', ind);
        continue;
    end

end
cumu_pose = cumu_pose(:, :, 1:ind-1);

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

%if debug,
% for f_i = 1 : numel(frame_range),
%     clf;
%     hold on;
%     plot(ref_joint_loc(1, f_i), ref_joint_loc(2, f_i), 'bd');
%     draw_bones2d(positions(:, :, f_i), []);
%
%     pause(1/30);
% end
% end
[norm_pos, dist_rel, angle_rel, ort_rel, cart_traj, radial_traj, dist_rel_traj,...
    angle_rel_traj, ort_rel_traj] = pose_2d_motion_rel_desc(positions, ...
    ref_joint_loc, ref_joint_ort, dist_pairs, angle_triples, opt, true);
end

