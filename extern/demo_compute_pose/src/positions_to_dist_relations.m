function X = positions_to_relations(positions,T)

Nframes = size(positions,3);
dist_pairs = cell(1);
p = 0;
for i = 1:15
    for j = 1:15
        add = 1;
        if (i==j)
            add = 0;
        end
        for k = 1:p
            if sum(abs(dist_pairs{k}-[j i]))==0
                add = 0;
                break;
            end
        end
		if add
            p = p + 1;
            dist_pairs{p} = [i,j];
  	    end
    end
end
ngroups = p;
npointsPerGroup = length(dist_pairs{1});
X = zeros(ngroups,Nframes);
for iframe = 1:Nframes
	p = zeros(2,npointsPerGroup, ngroups);
	for ig = 1:ngroups
		for ip = 1:npointsPerGroup
			p(:,ip, ig) = positions(:,dist_pairs{ig}(ip),iframe);
		end
	end
	X(:,iframe) = compute_distance_features(p);
end


function distance = compute_distance_features(p)
	%[ndim,npoints, ngroups] = size(p);
    [p1, p2] = deal(squeeze(p(:,1, :)), squeeze(p(:,2, :)));
	dx = p1(1,:)-p2(1,:);
	dy = p1(2,:)-p2(2,:);
	distance = dx.*dx + dy.*dy;
	distance = sqrt(distance);

 
