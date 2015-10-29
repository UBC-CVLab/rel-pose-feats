function positions= image_to_world(positions,scale)
%inX has dimension 2 x 15 x 40
%outX should have dimension 2 x 15 x 40
	% between neck and belly
if 0
    torso_positions = (positions(:,2,:)+positions(:,1,:))/2; % 2 x 40
    % subtract the center
	positions = positions - repmat(torso_positions,[1 15 1]);
    % rescale
	positions = positions/scale;
    % add the center	
	positions = positions + repmat ( torso_positions,[1 15 1]);
end
width = 320;
height = 240;
aspect_ratio = width/height;
nframes = size(positions,3);

Xi = squeeze(positions(1,:,:));
Yi = squeeze(positions(2,:,:));

Xi = aspect_ratio*(Xi/width - 0.5);
Yi = Yi/height - 0.5;
scale = reshape(scale,[1 nframes]);

X = Xi./repmat(scale,[15 1]);
Y = Yi./repmat(scale,[15 1]);
X = shiftdim(X,-1);
Y = shiftdim(Y,-1);
positions = cat(1,X,Y);


