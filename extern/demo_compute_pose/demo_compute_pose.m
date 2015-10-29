% Paper: Towards Understanding Action Recognition, ICCV 2013.
% Date: Feb 5th, 2014
% Author: Hueihan Jhuang
% This file loads joint positions 'joint_positions.mat' (downloaded from http://jhmdb.is.tue.mpg.de/challenge/JHMDB/datasets) and compute 9 kinds of pose features.

addpath(genpath('src'));

opt = struct('T',7,'s',3);

file_joint_positions = 'April_09_brush_hair_u_nm_np1_ba_goo_0/joint_positions.mat';
A = load(file_joint_positions,'pos_world');

% compute normalize joints 
norm_positions = positions_to_normalizepositions(A.pos_world);

% compute relations: distance between two joints
dist_relations = positions_to_dist_relations(A.pos_world);

% compute relations:angle spanned by three joints
angle_relations = positions_to_angle_relations(A.pos_world);

% compute relations: orientation between two joints
ort_relations = positions_to_ort_relations(A.pos_world);

% compute trajectory of positions with cartesian representation:
cartesian_trajectory = positions_to_cartesian_trajectory(A.pos_world,opt);

% compute trajectory of positions with radial representation:
radial_trajectory = positions_to_radial_trajectory(A.pos_world,opt);

% compute trajectory of dist_relations
dist_relation_trajectory = X_to_trajectory(dist_relations,opt);

% compute trajectory of angle_relations
angle_relation_trajectory = X_to_trajectory(angle_relations,opt);

% compute trajectory of ort_relations
ort_relation_trajectory = X_to_trajectory(ort_relations,opt);
