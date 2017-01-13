clearvars;
close all force;
 
%%% Il faut modifier le type de carte, dans la variable board, 'teensy', ou
%%% 'arduino'. Ensuite il faut choisir le port dans la variable pin_readV,
%%% et aussi le port série, que l'on peut retrouver en regardant le port
%%% sur lequel est conneté le microcontrolleur, ici com5.

%%% Si vous ne possédez pas le package arduino, il faut simplement taper
%%% "arduino" dans la console, et il vous proposera d'installer les paquets
%%% nécéssaires

%%% SI PASSAGE ARDUINO A TEENSY, IL FAUT "CLEAR ALL"

%% Paramètres

port = 'com5';
board = 'teensy';
pin_readV = 'A0';
nb_secondes = 30;
log_path = 'logs/';
analogresolution = 16; % pour teensy

%% Vérification de l'état de l'arduino et dossiers
if ~exist('ard','var')
    if strcmp(board,'teensy')
        fprintf('Chargement de la teensy...\n');
        if ~isempty(instrfind)
            fclose(instrfind);
        end
        ard = serial(port,'BaudRate',9600,'DataBits',8);
        fopen(ard);
        val_ref = (2^analogresolution)/3.3;
    else
        fprintf('Chargement de l''arduino...\n');
        ard = arduino;%(port,board);
    end
end
if ~exist(log_path(1:end-1),'dir')
    mkdir(log_path);
end

%% Lancement
id_name = input('Identifiant fichier : ', 's');
input('Appuyez sur entrée pour lancer...');
tstart = tic;
data = [];

str_now = datestr(now,'dd-mm-yyyy--HH-MM-SS-FFF');

int_restant = floor(nb_secondes);
while toc(tstart) < nb_secondes
    if (nb_secondes-floor(toc(tstart))) < int_restant
        int_restant = nb_secondes-floor(toc(tstart));
        fprintf('%d...\n',int_restant);
    end
    
    if strcmp(board,'teensy')
        val = fgetl(ard);
        if ~isempty(val)
            value = str2double(val)/val_ref;
        end
    else
        value = ard.readVoltage(pin_readV);
    end
    
    data = [data; toc(tstart), value];
    
end

%% Filtrage de mauvaises valeurs
thresh_bad_voltage = 5.1;
idx_bad = find(data(:,2)>thresh_bad_voltage);
data(idx_bad,:) = [];

if strcmp(board,'teensy')
    fclose(ard);
end

%% Sauvegarde et affichage
csvwrite([log_path, str_now, '_', id_name, '-', board, '.csv'],data);
plot(data(:,1), data(:,2), '.b');
xlabel('Temps en secondes')
ylabel('Tension en Volt')
title(['Mesure ', id_name]);
axis([0, nb_secondes, floor(min(data(:,2))), ceil(max(data(:,2)))])