function [PathDatabase,Opto_Data,Opto_Data_description]=Load_Optogenetic_Inactivation_database

% Database folder
disp('Where is the Database folder ?')
[PathDatabase]=uigetdir([],'Where is the Database folder ?');
disp(['Database path : ' PathDatabase])

% Load Matrices
load([PathDatabase filesep 'Opto_Inactivation_data.mat']);

% %clearvars
% clearvars -except PathDatabase LFP_Data LFP_Data_description...
%     spike_data spike_data_description LFP_data LFP_data_descritpion

end

