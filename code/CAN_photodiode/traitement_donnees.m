clearvars -except ard;
close all force;

log_path = 'logs/';

%% Demande de l'identifiant
d = dir([log_path, '*.csv']);