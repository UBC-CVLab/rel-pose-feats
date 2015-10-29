w = which(mfilename());
thisDir = fileparts(w);
cd(thisDir);
addpath(thisDir);
% ones(10)*ones(10); % This solves the bug here: http://stackoverflow.com/questions/19268293/matlab-error-cannot-open-with-static-tls

% function to add directories and all its subdirectories to the paths
include  = @(d)addpath(genpath(d));

%% Add subfolders to path.
include(fullfile(thisDir, 'data'));
include(fullfile(thisDir, 'extern'));
include(fullfile(thisDir, 'optimized_code'));
