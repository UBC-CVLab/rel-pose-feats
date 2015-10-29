## Relational pose features from 2d human skeleton. 


Human pose similarity cannot be described very well in terms of location of the body parts. One can instead generate features which capture relationship between position and orientation of body parts. These have been used as features for action recognition and mocap retrieval.

Original code is written by Hueihan Jhuang. I provide some speed-ups and an interface for FMP and mocap data.

## Examples
1. **Generate relational pose features from FMP output.**

2. **Generate relational pose features from motion-capture for one of its projects.**

## Dependencies [included in the package]
- demo_compute_pose by Hueihan Jhuang available at http://files.is.tue.mpg.de/jhmdb/demo_compute_pose.zip

- mocap-dense-trajectories available on Github.
References
----------
1. Hueihan Jhuang; Gall, J.; Zuffi, S.; Schmid, C.; Black, M.J., "Towards Understanding Action Recognition," in Computer Vision (ICCV), 2013 IEEE International Conference on , vol., no., pp.3192-3199, 1-8 Dec. 2013 

