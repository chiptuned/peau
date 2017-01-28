clearvars;
close all force;

%% Paramètres
if ~isempty(instrfind)
    fclose(instrfind) %#ok<PRTCAL> % On s'assure que les ports série sont fermés
end
timeout_seconds = 60;
port = 'COM5';
log_path = 'logs/';
VALEUR_MAX = 1.5;
%% 

%% Vérification de l'état de l'arduino et dossiers
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

last_end = tic;
while true
    fprintf('Attente du microcontrolleur...\n')
    header = '';
    polarplot([], [], '.b')
    title('Attente du microcontrolleur...')
    str_now = datestr(now,'dd-mm-yyyy--HH-MM-SS-FFF');
    axis([0 110 0 VALEUR_MAX])
    hold off;
    drawnow;
    while isempty(header)
        if toc(last_end)<timeout_seconds
        warning('off','all');
        header = fgetl(ard);
        str_now = datestr(now,'dd-mm-yyyy--HH-MM-SS-FFF');
        warning('on','all');
        else
            error(['Pas de réponse depuis plus de ', ...
                num2str(timeout_seconds), ' secondes.'])
        end
    end
    if numel(str2num(header)) == 3
        continue; 
    end
    title('');
    values_header = str2num(header); %#ok<ST2NM>
    angle_bal = values_header(1);
    time_scanning_millis = values_header(2);
    pause_scanning_millis = values_header(3);
    angular_resolution = values_header(4);
    analog_res = values_header(5);
    nb_scans = values_header(6);
    
    fprintf('Début du balayage...\n')
    nb_mesures = floor(angular_resolution*angle_bal*nb_scans*2);
    cpt = 0;
    data = zeros(nb_mesures,3);
    
    
    while cpt < nb_mesures
       cpt = cpt + 1; 
       mesures_line = str2num(fgetl(ard)); % la mesure, a stocker
       time = mesures_line(1);
       angle_val = mesures_line(2)*2*pi/4096;
       tension = mesures_line(3)*3.3/66536
       polarplot(angle_val,tension, '.b')%, 'markersize', 30)
       axis([0 110 0 VALEUR_MAX])
       title(['Diagramme de diffusion polaire, id : ', id_name]);
       hold on;
       drawnow;
       data(cpt,:) = [time, angle_val, tension];
    end
    hold off;
    fprintf('Fin du balayage...\n')
    last_end = tic;
    csvwrite([log_path, str_now, '_', id_name, '.csv'],data);
    % les mesures, a afficher
end
