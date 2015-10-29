## Relational pose features from 2d human skeleton. 

Human pose similarity cannot be described well in terms of absolute location of body parts. One can instead generate features which capture relationship between position and orientation of body parts. Relational pose features are These have been used as features for action recognition [1] and mocap retrieval [3].

The original code is written by **Hueihan Jhuang**. Here, I provide some speed-ups and an interface to generate these features from the FMP [2] output and human motion capture data (as seen from a given angle). For more details see [1].

### Examples
```
% Add files to path.
init_rel_pose_feats
```
1) **Generate relational pose features from FMP output .**
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
2) **Generate relational pose features from motion-capture for one of its projects.**
```
% Read a mocap file (in BVH format).
[imocap, ~] = load_imocap_seq( '12_02', BASE_PATH, FPS);

% Pick parameters.
frame_range = 1:100;
theta       = pi/3; % Elevation angle measured from the vertical.
phi         = pi/2; % Azimuthal angle.
opt         = struct('T', 5, 's', 2);

[norm_pos, dist_rel, angle_rel, ort_rel, cart_traj, radial_traj, dist_rel_traj,...
    angle_rel_traj, ort_rel_traj] = pose_desc_imocap(imocap, frame_range, theta, phi, opt);
```

### Dependencies (included in the package)
- demo_compute_pose by Hueihan Jhuang, available [here](http://files.is.tue.mpg.de/jhmdb/demo_compute_pose.zip).

- [mocap-dense-trajectories](https://github.com/jltmtz/mocap-dense-trajectories) available on Github.

### References
1. Hueihan Jhuang; Gall, J.; Zuffi, S.; Schmid, C.; Black, M.J., "Towards Understanding Action Recognition," in ICCV, 2013
2. Yi Yang; Ramanan, D., "Articulated Human Detection with Flexible Mixtures of Parts," TPAMI, 2013
3. Ankur Gupta; He, J.; Martinez J.; Little J.J.; Woodham R.J., "Efficient video-based retrieval of human motion with flexible alignment," in WACV, 2016 (to appear) 
