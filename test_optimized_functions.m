% Notes:
%
% Joint indices and names.
% 1: neck
% 2: belly
% 3: face
% 4: right shoulder
% 5: left  shoulder
% 6: right hip
% 7: left  hip
% 8: right elbow
% 9: left elbow
% 10: right knee
% 11: left knee
% 12: right wrist
% 13: left wrist
% 14: right ankle
% 15: left ankle

addpath(genpath('src'));
% Load the pose file.
opt    = struct('T',7,'s',3);
RADIAN = true;
file_joint_positions = 'April_09_brush_hair_u_nm_np1_ba_goo_0/joint_positions.mat';
A = load(file_joint_positions,'pos_world');

CONST_EPS = 10^-9;
%% compute normalize joints
tic;
norm_positions = positions_to_normalizepositions(A.pos_world);
fprintf('Time taken in normalization:%0.4f\n', toc);

% In this case the reference bone is between neck and belly.
ref_bone_pos          = (A.pos_world(:,2,:) + A.pos_world(:,1,:))/2;
norm_positions_new    = pose_to_normalized(A.pos_world, ref_bone_pos);

assert(all(all(norm_positions==norm_positions_new)));
%% compute relations: distance between two joints
num_joints  = size(A.pos_world, 2);
num_frames  = size(A.pos_world, 3);
num_pairs   = num_joints*(num_joints - 1)/2;
num_triples = 3*num_joints*(num_joints - 1)*(num_joints - 2)/6;
dist_pairs    = zeros(num_pairs, 2);
angle_triples = zeros(num_triples, 3);
p_ind = 0;
q_ind = 0;
for ii = 1 : num_joints,
    for iii = ii + 1: num_joints,
        p_ind = p_ind + 1;
        dist_pairs(p_ind, :) = [ii,iii];
    end        
    for ij = 1 : num_joints,            
        if ij~=ii,
            for ik = 1:num_joints,                
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

tic;
dist_relations = positions_to_dist_relations(A.pos_world);
fprintf('Time taken in dist rel:%0.4f\n', toc);

tic;
dist_relations_opt = pose_to_relations(A.pos_world, dist_pairs);
fprintf('Time taken in dist rel optimized:%0.4f\n', toc);

assert(all(all(dist_relations_opt==dist_relations)));

%% compute relations: angle spanned by three joints
tic;
angle_relations = positions_to_angle_relations(A.pos_world);
fprintf('Time taken in pose to rel angle:%0.4f\n', toc);
% Elapsed time is 26.086726 seconds.
% 
tic;
angle_relations_opt = pose_to_angle_rel(A.pos_world, angle_triples);
fprintf('Time taken in pose to rel angle optimized:%0.4f\n', toc);
assert(all(all(abs(angle_relations - angle_relations_opt) < CONST_EPS )));

%% compute relations: orientation between two joints
tic;
ort_relations = positions_to_ort_relations(A.pos_world);
fprintf('Time taken in orientation rel:%0.4f\n', toc);

ref_ort  = zeros(1, num_frames);
neck_id  = 1;
tummy_id = 2;
for iframe = 1 : num_frames,    
    diff_vec        = A.pos_world(:, tummy_id, iframe) - A.pos_world(:,  neck_id, iframe);    
    ref_ort(iframe) = atan2(diff_vec(2), diff_vec(1));
end
tic;

ort_relations_opt = pose_to_ort_rel(A.pos_world, dist_pairs, ref_ort);
ort_relations_opt = ort_relations_opt(2:end, :); % has one extra dimension corresponding to neck-tummy link.

fprintf('Time taken in orientation rel optimized:%0.4f\n', toc);
assert( all( all( (ort_relations - ort_relations_opt) < CONST_EPS) ) );

%% compute trajectories
tic;
cartesian_trajectory      = positions_to_cartesian_trajectory(A.pos_world,opt);
% compute trajectory of positions with radial representation:
radial_trajectory         = positions_to_radial_trajectory(A.pos_world,opt);
% compute trajectory of dist_relations
dist_relation_trajectory  = X_to_trajectory(dist_relations,opt);
% compute trajectory of angle_relations
angle_relation_trajectory = X_to_trajectory(angle_relations,opt);
% compute trajectory of ort_relations
ort_relation_trajectory   = X_to_trajectory(ort_relations,opt);
fprintf('Total time taken for all other features:%0.4f\n', toc);


%% The function which runs everything together.
tic;
[norm_pos, dist_rel, angle_rel, ort_rel, cart_traj, radial_traj, dist_rel_traj,...
    angle_rel_traj, ort_rel_traj] = pose_2d_motion_rel_desc(A.pos_world, ref_bone_pos,...
    ref_ort, dist_pairs, angle_triples, opt, RADIAN);
fprintf('Total time taken features computation:%0.4f\n', toc);
    

%% Test w.r.t previously computed results for the following params.
% opt    = struct('T',7,'s',3);
% RADIAN = true;
% file_joint_positions = 'April_09_brush_hair_u_nm_np1_ba_goo_0/joint_positions.mat';
% A = load(file_joint_positions,'pos_world');

tdata = load('rel-pose-test-data.mat');

% Make sure the values are same.

assert(all(all(abs(tdata.angle_rel - angle_rel)  <  CONST_EPS)));
assert(all(all(all(abs(tdata.angle_rel_traj - angle_rel_traj)  <  CONST_EPS))));
assert(all(all(all(abs(tdata.cart_traj - cart_traj) < CONST_EPS))));
assert(all(all(abs(tdata.dist_rel - dist_rel) < CONST_EPS)));
assert(all(all(all(abs(tdata.dist_rel_traj - dist_rel_traj) < CONST_EPS))));
assert(all(all(abs(tdata.norm_pos - norm_pos) < CONST_EPS)));
assert(all(all(abs(tdata.ort_rel - ort_rel) < CONST_EPS)));
assert(all(all(all(abs(tdata.ort_rel_traj - ort_rel_traj) < CONST_EPS))));
assert(all(all(all(abs(tdata.radial_traj - radial_traj) < CONST_EPS))));

fprintf('Test successful!\n');