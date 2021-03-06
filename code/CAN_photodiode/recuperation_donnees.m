clearvars -except ard;
close all force;

%%% Il faut pr�ciser ou est le dossier des fichiers � ouvrir dans la
%%% varibale log_path. Ensuite, on peut choisir l'identifiant du fichier �
%%% trouver, qui doit �tre une partie de son nom. Si on choisit
%%% l'identifiant qu'on a choisi pour l'acquisition on va le retrouver.
%%% S'il y a plusieurs fichiers, le choix sera demand�.

log_path = 'logs/';

%% Demande de l'identifiant
id_name = input('Identifiant fichier : ', 's');
d = dir([log_path, '*', id_name,'*']);

%% Choix si plusieurs correspondances
if length(d) > 1
    fprintf('Multiple files found : \n');
    for ind = 1:length(d)
        fprintf(['%d : ', d(ind).name, '\n'], ind);
    end
    res = input('Open which one? ');
else
    res = 1;
end

%% Recup�ration
filename = [log_path, d(res).name];
data = csvread(filename);

%% Affichage
plot(data(:,1), data(:,2), '.b');
xlabel('Temps en secondes')
ylabel('Tension en Volt')
title(['Mesure ', id_name]);
axis([0, data(end,1), floor(min(data(:,2))), ceil(max(data(:,2)))])