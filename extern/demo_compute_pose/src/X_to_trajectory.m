function outX = X_to_treajectory(inX,T,trajectory_step)
	if nargin==2
		tmp = T;
		T = tmp.T;
		trajectory_step = tmp.s;
	end
	% X has dimension nfeatures x nframes
	[ndims,nframes] = size(inX);
	%if nframes < T
		%fprintf('not enough frames\n');
		%outX = [];
		%return;
	%end 
	
    inX = shiftdim(inX,-1);
	% X has dimension 1 x nfeatures x nframes
	
	% 1 + (L-1)*s <= T-s
   	% 1 + L*s <= T
    % L <= floor((T-1)/s)
	trajectory_length = floor((T-1)/trajectory_step);
	num_inX_frames_per_outX_features = 1+trajectory_step*trajectory_length;
	% I need at least 1 frame
	out_nframes = nframes - num_inX_frames_per_outX_features + 1;
	if (out_nframes >0)
 		outX = -ones(trajectory_length, ndims, out_nframes);
    	Diff = inX(1,:,1:end-trajectory_step)-inX(1,:,1+trajectory_step:end);
		for it = 1:trajectory_length
        	s = (it-1)*trajectory_step+1;
	    %if (s+out_nframes-1)>size(Diff,3)
		%	% complete the rest of matrix outX with the last valid results
    	%	outX(it:trajectory_length, 1:ndims,1:out_nframes) = repmat(outX(it-1,1:ndims,s:s+out_nframes-1),[trakectory_length-it+1,1,1]);
		%	break;
		%end
        	outX(it,1:ndims,1:out_nframes) = Diff(1,1:ndims,s:s+out_nframes-1);
    	end
	else
		out_nframes = 1;
	 	outX = -ones(trajectory_length, ndims, out_nframes);
    	Diff = inX(1,:,1:end-trajectory_step)-inX(1,:,1+trajectory_step:end);
    	for it = 1:trajectory_length
        	s = (it-1)*trajectory_step+1;
	    	if s>size(Diff,3)
    			outX(it:trajectory_length, 1:ndims, 1) = repmat(outX(it-1,1:ndims,1),[trajectory_length-it+1,1,1]);
				break;
			end
        	outX(it,1:ndims,1) = Diff(1,1:ndims,s);
    	end
	end
