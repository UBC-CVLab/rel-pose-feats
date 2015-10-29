function outX = positions_to_cartesian_trajectory(positions,T,trajectory_step)
	if nargin==2
		tmp = T;
		T = tmp.T;
		trajectory_step = tmp.s;
	end
   	% position is 30 by Nframes
	% x_joint1, y_joint1, x_joint2, y_joint2, x3, y3
	% X is 2*trajectory_length by Nframes
	nframes = size(positions,3);
	positions = reshape(positions,[],nframes);
	X = X_to_trajectory(positions,T,trajectory_step);
	%[trajectory_length,nxyjoints,out_nframes] =  size(X);
	%dx = X(:,1:2:end,:);
	%dy = X(:,2:2:end,:);
	%outX = cat(1,dx,dy);
	outX = X;
	

