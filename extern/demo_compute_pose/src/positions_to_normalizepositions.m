function positions = positions_to_normalizepositions(positions)

	% between neck and belly
    torso_positions = (positions(:,2,:)+positions(:,1,:))/2;
    positions = positions-repmat(torso_positions,[1 15 1]);
	% seperate two coordinates
	positions = reshape(positions,30,[]);
