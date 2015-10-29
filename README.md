## Relational pose features from 2d human skeleton. 

Human pose similarity cannot be described well in terms of absolute location of body parts. One can instead generate features which capture relationship between position and orientation of body parts. Relational pose features are These have been used as features for action recognition [1] and mocap retrieval [3].

Original code is written by **Hueihan Jhuang**. Here, I provide some speed-ups and an interface for FMP and mocap data. For more details see [1].

### Examples
```
% Add files to path.
init_rel_pose_feats
```
1. **Generate relational pose features from FMP output [2].**
```
% Load fmp output already saved in a mat file.
fmp_data   = load('query001.mat');
pose2d     = fmp_data.pose2d;
num_frames = numel(pose2d);

% These parameters are the same as described in the paper [1].
opt        = struct('T', 5, 's', 2);  

% Each of these output matrices contain different relational feature types.
[norm_pos, dist_rel, angle_rel, ort_rel, cart_traj, radial_traj, dist_rel_traj,...
    angle_rel_traj, ort_rel_traj] = pose_desc_fmp(pose2d, 1:num_frames, opt);
```

2. **Generate relational pose features from motion-capture for one of its projects.**
```
% Read a mocap file (in BVH format).
[imocap, ~] = load_imocap_seq( '12_02', BASE_PATH, FPS);

% Pick parameters.
frame_range = 1:100;
theta       = pi/3; % Elevation angle measured from the vertical.
phi         = pi/2; % Azimuthal angle.
opt         = struct('T', 5, 's', 2);

% Call the function.
[norm_pos, dist_rel, angle_rel, ort_rel, cart_traj, radial_traj, dist_rel_traj,...
    angle_rel_traj, ort_rel_traj] = pose_desc_imocap(imocap, frame_range, theta, phi, opt);
```

### Dependencies [included in the package]
- demo_compute_pose by **Hueihan Jhuang** available at http://files.is.tue.mpg.de/jhmdb/demo_compute_pose.zip

- [mocap-dense-trajectories](https://github.com/jltmtz/mocap-dense-trajectories) available on Github.

### References
1. Hueihan Jhuang; Gall, J.; Zuffi, S.; Schmid, C.; Black, M.J., "Towards Understanding Action Recognition," in Computer Vision (ICCV), 2013 IEEE International Conference on , vol., no., pp.3192-3199, 1-8 Dec. 2013 
2. Yi Yang; Ramanan, D., "Articulated Human Detection with Flexible Mixtures of Parts," in Pattern Analysis and Machine Intelligence, IEEE Transactions on , vol.35, no.12, pp.2878-2890, Dec. 2013
3. Ankur Gupta; He, J.; Martinez J.; Little J.J.; Woodham R.J., "Efficient video-based retrieval of human motion with flexible alignment," in WACV, 2016 (to appear) 
