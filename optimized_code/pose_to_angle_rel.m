function X = pose_to_angle_rel( positions, angle_triples, radian_output)
% POSE_TO_ANGLE_REL Optimized version of POSITION_TO_ANGLE_RELATIONS
%
% Calculates angles of the triangle formed by every triplet of 3 joints.
%
% positions     : 2 x num_joints x num_frames
% angle_triples : all triplets of indices [1, num_joints]. See the code
%                   below for how it is constructed.
% radian_output : boolean. True output is in radians else in degrees.
% dim3          : Set true when positions are 3d locations.

% ---
% Ankur

num_frames  = size(positions, 3);
num_joints  = size(positions, 2);
num_triples = 3*num_joints*(num_joints - 1)*(num_joints - 2)/6; % 3 * (N choose 3)

if nargin < 3 || isempty(radian_output),
    radian_output = false;
end

if nargin < 2 || isempty(angle_triples),
    angle_triples = zeros(num_triples, 3);
    q_ind = 0;
    for ii = 1 : num_joints,
        for ij = 1 : num_joints,
            if ij~=ii,
                for ik = 1:num_joints,
                    % Remove reversed indices.
                    is_reversed = sum( (angle_triples(:, 1) == ik) & ...
                        (angle_triples(:, 2)== ij) & (angle_triples(:, 3)== ii) );
                    
                    if ik~=ii && ik~=ij && ~is_reversed,
                        q_ind = q_ind + 1;
                        angle_triples(q_ind, :) = [ii ij ik];
                    end
                end
            end
        end
    end
end
assert(num_triples == size(angle_triples, 1));

X = zeros(num_triples, num_frames);

for iframe = 1:num_frames
    % Angle between all triples.
    diff_vec1 = positions(:, angle_triples(:, 1), iframe) - positions(:,  angle_triples(:, 2), iframe); % 1-2
    diff_vec2 = positions(:, angle_triples(:, 3), iframe) - positions(:,  angle_triples(:, 2), iframe); % 3-2
    % if dim3,
    % nvec1 = sqrt(diff_vec1(1,:).^2 + diff_vec1(2,:).^2 + diff_vec1(3,:).^2);
    % nvec2 = sqrt(diff_vec2(1,:).^2 + diff_vec2(2,:).^2 + diff_vec2(3,:).^2);
    % else
    % nvec1 = sqrt(diff_vec1(1,:).^2 + diff_vec1(2,:).^2);
    % nvec2 = sqrt(diff_vec2(1,:).^2 + diff_vec2(2,:).^2);
    % end
    %     nvec1 = cellfun(@norm, num2cell(diff_vec1, 1));
    %     nvec2 = cellfun(@norm, num2cell(diff_vec2, 1));
    
    nvec1 = sqrt(sum(diff_vec1.^2, 1));
    nvec2 = sqrt(sum(diff_vec2.^2, 1));
    %     assert(all(abs(nvec1 - nvec1_new)<10^-6));
    %     assert(all(abs(nvec2 - nvec2_new)<10^-6));
    
    ndot = dot(diff_vec1, diff_vec2)./(nvec1.*nvec2 + 0.000000001);
    
    X(:, iframe) = acos(ndot);
end
if ~radian_output,
    X = X * 180/pi;
end