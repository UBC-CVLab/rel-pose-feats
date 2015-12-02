% DISPLAY_USED_JOINTS Displays the corresponding CMU and 2d pose skeleton.
close all;
imocap = loadbvh('data/12_02.bvh');

% Connection between joints: Ind1 Ind2 
connections = ...    
    [1, 2;
     2, 3
     3, 4
     4, 5
     5, 6
     6, 7     
     1, 8 
     8, 9
     9, 10
     10, 11
     11, 12
     12, 13
     1, 14
     14, 15
     15, 16
     16, 17
     17, 18
     18, 19
     19, 20
     16, 21
     21, 22
     22, 23
     23, 24
     24, 25
     25, 26
     26, 27
     24, 28
     28, 29
     16, 30
     30, 31
     31, 32
     32, 33
     33, 34
     34, 35
     35, 36
     33, 37
     37, 38
    ];

%%
frame = 2;
col_linspec = linspecer(3, 'qualitative');
joint_loc = zeros(size(imocap, 2), 3);
for i=1:numel(imocap),
    loc = imocap(i).Dxyz;
    joint_loc(i, :) = loc(:, frame)';
end
joint_loc = xzy2xyz(joint_loc')';

%% Drawing the bones between the joints.
clf;
hold on;
[corres, imocap_part_ind] = fmp_imocap_corres();
for i=1:size(connections, 1)
    joint_ind1   = connections(i, 1);
    joint_ind2   = connections(i, 2);
    p            = joint_loc([joint_ind1 joint_ind2], :);    
    plot3(p(:, 1), p(:, 2), p(:, 3), 'color', col_linspec(1, :), 'LineWidth', 2);    
end
not_used = setdiff(1:numel(imocap), corres{1});

scatter3(joint_loc(corres{1}, 1), joint_loc(corres{1}, 2), joint_loc(corres{1}, 3), ...
    60, 'MarkerEdgeColor', col_linspec(1, :), 'MarkerFaceColor', col_linspec(3, :));

scatter3(joint_loc(not_used, 1), joint_loc(not_used, 2), joint_loc(not_used, 3), ...
    60, 'MarkerEdgeColor', col_linspec(1, :), 'MarkerFaceColor', col_linspec(2, :));

axis equal;
hold off;
set(gcf, 'Color', ones(1, 3))
axis off;
title('CMU skeleton (green markers show used joints)');
view([-13 24])
% export_fig skeleton.pdf

%% Code to generate the nba_example.mat
% NBA_BASE = '/ubc/cs/research/tracking-raid/datasets/nba-precomp-feats/';%
% load([NBA_BASE 'video/video.mat']);
% load([NBA_BASE 'track-gt.mat']);
% load([NBA_BASE 'fmp/FMP-Output.mat']);

% figure;
% player = 'Andrew_Bynum';
% bbs = get_player_bbs(track_gt, player);
% [pose_cell, pose2d_gt] = get_player_pose_sequence(final_estimates, player);
% for frm_j = 200%1:500 %187 %- LEN_TRAJ
%     % Display image
%     clf;
%     vid_frame = squeeze(video(frm_j,:,:,:)); % starts from zero
%     corner = [bbs(frm_j, 2)-20 bbs(frm_j, 3)-20];
%     hold on;
%     nba_frame = imcrop(vid_frame, [corner  bbs(frm_j, 4)+40 bbs(frm_j, 5)+40] );
%     imshow(nba_frame);    
%     pose_2d = pose2d_gt{frm_j}';
%     gt_pose2d = [pose_2d(1, :)-corner(1); pose_2d(2, :)-corner(2)];
%     hold on;
%     scatter(gt_pose2d(1,:), gt_pose2d(2, :), 60, 'MarkerEdgeColor', col_linspec(1, :), ...
%     'MarkerFaceColor', col_linspec(3, :));
%     pause(1/30);
% end

%% Plotting 2d joints on top of an image.
load('nba_exmaple.mat', 'nba_frame', 'gt_pose2d');
figure;
imshow(nba_frame);    
hold on;
scatter(gt_pose2d(1,:), gt_pose2d(2, :), 120, 'MarkerEdgeColor', col_linspec(1, :), ...
      'MarkerFaceColor', col_linspec(3, :));
set(gcf, 'Color', ones(1, 3));
title('Joints returned by 2d pose detection');