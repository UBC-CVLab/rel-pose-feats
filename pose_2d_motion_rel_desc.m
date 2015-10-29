function [norm_pos, dist_rel, angle_rel, ort_rel, cart_traj, radial_traj, dist_rel_traj,...
    angle_rel_traj, ort_rel_traj] = pose_2d_motion_rel_desc(pos_2d_xy, ...
    ref_joint_loc, ref_joint_ort, dist_pairs, angle_triples, opt, RADIAN)
% POSE_2D_MOTION_REL_DESC Calculate relational features as described
% in Jhunag et al. using the code provided by the author. This is the common
% code that can be called for both FMP or imocap poses. For specific
% functions see: POSE_DESC_FMP, POSE_DESC_IMOCAP.
%
% Input-
%  pos_2d_xy      : 2 x num_joints x num_frames double. Standardized position of all the bones.
%  ref_joint_loc  : 2 x num_frames double. Standardized position of body center
%                   to calculate relative position of each joint.
%  ref_joint_ort  : 1 x num_frames. Orientation of the line joining two bones uses as reference orientation.
%  dist_pairs     : 2 x all_combination of joints. Pairs of all joint indices.
%  angle_triplets : 2 x all_angles between all bones. 

% Ankur
if nargin < 7 || isempty(RADIAN),
    RADIAN = true;
end

% Calculates the position of each joint relative to a reference joint.
norm_pos    = pose_to_normalized(pos_2d_xy, ref_joint_loc);
dist_rel    = pose_to_relations(pos_2d_xy,  dist_pairs);
angle_rel   = pose_to_angle_rel(pos_2d_xy,  angle_triples, RADIAN);
ort_rel     = pose_to_ort_rel(pos_2d_xy,    dist_pairs, ref_joint_ort, RADIAN);

% Cartesian/angle traj.
cart_traj   = positions_to_cartesian_trajectory(pos_2d_xy, opt);
radial_traj = positions_to_radial_trajectory(pos_2d_xy,    opt);

if RADIAN,
    radial_traj = radial_traj*pi/180;
end

% Rel feature trajectories
dist_rel_traj  = X_to_trajectory(dist_rel,  opt);
angle_rel_traj = X_to_trajectory(angle_rel, opt);
ort_rel_traj   = X_to_trajectory(ort_rel,   opt);

end