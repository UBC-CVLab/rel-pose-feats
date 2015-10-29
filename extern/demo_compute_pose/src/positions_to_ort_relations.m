function X = positions_to_relations(positions,T)

Nframes = size(positions,3);
% angle 0 to 180
% ort -180 to 180
ort_pairs = cell(1);
id_for_neck_to_belly = 0;
p = 0;
for i = 1:15
    for j = 1:15
        add = 1;
       	if (i==j)
            add = 0;
        end
        for k = 1:p
            if sum(abs(ort_pairs{k}-[j i]))==0
                add = 0;
                break;
            end
        end
        if add
            p = p + 1;
            ort_pairs{p} = [i,j];
			if ((i==1 & j==2 ) | ( i==2 & j==1))
				id_for_neck_to_belly = p;
			end
       end
    end
end

ngroups = p;
npointsPerGroup = length(ort_pairs{1});
X = zeros(ngroups,Nframes);
for iframe = 1:Nframes
	p = zeros(2,npointsPerGroup, ngroups);
	for ig = 1:ngroups
		for ip = 1:npointsPerGroup
			p(:,ip, ig) = positions(:,ort_pairs{ig}(ip),iframe);
		end
	end
	X(:,iframe) = compute_ort_features(p);
end
 neck_to_belly_ort = X(id_for_neck_to_belly,:);
 tmp = X(setdiff(1:end,id_for_neck_to_belly),:);
 tmp = abs(tmp-repmat(neck_to_belly_ort,[ngroups-1 1]));
 ind = (tmp>180);
 tmp(ind) = 360-tmp(ind);
 X = tmp;

function ort = compute_ort_features(p)
    [p1, p2] = deal(squeeze(p(:,1, :)), squeeze(p(:,2, :)));
	dx = p2(1,:)-p1(1,:);
	dy = p2(2,:)-p1(2,:);
	% orientation of the vector from p2 to p1
	% only mearningful for 2D points
	ort = atan2(dy,dx)*180/pi;



