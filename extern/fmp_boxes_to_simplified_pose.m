function pose = fmp_boxes_to_simplified_pose(boxes, fmp_part_map, maps)
% FMP_BOXES_TO_SIMPLIFIED_POSE Get rid of extra joints.
if nargin~=3,    
    if nargin < 2 || isempty(fmp_part_map),
        [~, fmp_part_map] = fmp_parts();
    end
    % To standardize the joint order
    jid		= @(x) fmp_part_map(x);
    maps = [jid('head') jid('neck') jid('lshoulder') jid('lelbow') jid('lhand') jid('lhip') ...
		jid('lknee') jid('lfoot') jid('rshoulder') jid('relbow') jid('rhand') jid('rhip') ...
		jid('rknee') jid('rfoot')];
end



if size(boxes, 1) == 0,
	pose = [];
	return;
end

box = boxes(1, 1:end-2);
xy  = reshape(box, 1, 4, []);
xy  = permute(xy,[1 3 2]);

x1 = xy(:,:,1);
y1 = xy(:,:,2);
x2 = xy(:,:,3);
y2 = xy(:,:,4);

joints = [(x1+x2)'/2 (y1+y2)'/2];


pose = joints(maps, :)';

end