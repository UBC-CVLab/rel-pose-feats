function outX = positions_to_trajectory_radial(positions,T,trajectory_step)
	if nargin==2
		tmp = T;
		T = tmp.T;
		trajectory_step = tmp.s;
	end
   	% position is 30 by Nframes
	% x1, y1, x2, y2, x3, y3
	% X is 2*trajectory_length by Nframes
	[nxy, njoints, nframes] = size(positions);
	positions = reshape(positions,nxy*njoints,nframes);
	X = X_to_trajectory(positions,T,trajectory_step);
	[trajectory_length,nxyjoints,out_nframes] =  size(X);
	dx = squeeze(X(:,1:2:end,:));
	dy = squeeze(X(:,2:2:end,:));
	outX = zeros(trajectory_length, nxyjoints/2, out_nframes);
	%outX(:,1:2:end,:) = squeeze(sqrt( dx.^2 + dy.^2));
 	outX(:,1:end,:) = squeeze(atan2(dy, dx)/pi*180);
	%outX = reshape(outX,trajectory_length, nxy*njoints, out_nframes);	
