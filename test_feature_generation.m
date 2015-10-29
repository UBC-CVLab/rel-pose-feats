%% Generate relational pose features from motion capture data.
close all;
% Read a BVH from CMU mocap.
FPS       = 24; % Render at 24 frames per second.
BASE_PATH = 'data/';

tic;
[imocap, ~] = load_imocap_seq( '12_02', BASE_PATH, FPS);
fprintf('%.4f seconds loading the mocap file.\n', toc);


% Pick parameters.
frame_range = 1:100;
theta       = pi/3; % Elevation angle measured from the vertical.
phi         = pi/2; % Azimuthal angle.
opt         = struct('T', 5, 's', 2);

% Call the function.
fprintf('Generating relational pose features for a mocap sequence...');
[norm_pos, dist_rel, angle_rel, ort_rel, cart_traj, radial_traj, dist_rel_traj,...
    angle_rel_traj, ort_rel_traj] = pose_desc_imocap(imocap, frame_range, theta, phi, opt);

%
fprintf('done\n');
imagesc(norm_pos);

%% Generate relational pose features for FMP output.
fmp_data   = load('query001.mat');
pose2d     = fmp_data.pose2d;
num_frames = numel(pose2d);

fprintf('Generating relational pose features for an fmp pose sequence...');
[norm_pos, dist_rel, angle_rel, ort_rel, cart_traj, radial_traj, dist_rel_traj,...
    angle_rel_traj, ort_rel_traj] = pose_desc_fmp(pose2d, 1:num_frames, opt);

fprintf('done\n');
figure;
imagesc(norm_pos);
