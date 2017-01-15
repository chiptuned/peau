clearvars;
close all force;

%% Param�tres
fclose(instrfind) %#ok<PRTCAL> % On s'assure que les ports s�rie sont ferm�s
timeout_seconds = 60;
port = 'COM3';
log_path = 'logs/';

%% V�rification de l'�tat de l'arduino et dossiers
if ~exist('ard','var')
    fprintf('Chargement de la carte...\n');
    if ~isempty(instrfind)
        fclose(instrfind);
    end
    ard = serial(port,'BaudRate',115200,'DataBits',8);
    set(ard, 'Timeout', 1);
    fopen(ard);
end
if ~exist(log_path(1:end-1),'dir')
    mkdir(log_path);
end

%% Lancement
id_name = input('Identifiant fichier session : ', 's');
tstart = tic;
data = [];

str_now = datestr(now,'dd-mm-yyyy--HH-MM-SS-FFF');
last_end = tic;
while true
    fprintf('Attente du microcontrolleur...\n')
    header = '';
    while isempty(header)
        if toc(last_end)<timeout_seconds
        warning('off','all');
        header = fgetl(ard);
        warning('on','all');
        else
            error(['Pas de r�ponse depuis plus de ', ...
                num2str(timeout_seconds), ' secondes.'])
        end
    end
    values_header = str2num(header); %#ok<ST2NM>
    angle = values_header(1);
    time_scanning_millis = values_header(2);
    pause_scanning_millis = values_header(3);
    angular_resolution = values_header(4);
    analog_res = values_header(5);
    nb_scans = values_header(6);

    fprintf('D�but du balayage...\n')
    nb_mesures = floor(angular_resolution*angle*nb_scans*2);
    cpt = 0;
    while cpt < nb_mesures
       cpt = cpt + 1; 
       fgetl(ard); % la mesure, a stocker
    end
    fprintf('Fin du balayage...\n')
    last_end = tic;
    % les mesures, a afficher
end