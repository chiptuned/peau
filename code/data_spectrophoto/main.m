clearvars;
close all;

data = import_data_cxf('data12jan.cxf');
noms = {'Thibaud', 'Wassim', 'Vincent', ...
    'Moctar', 'Amadou', 'Boris', 'Mahmoud'};
type_samples = {'Peau', 'Veine', 'Bruit'};
% Ce qu'on veut mesurer, 1 pour peau, 2 pour veine, 3 pour bruit
type_mesures_export = 1;

% On écrit la vérité (les mesures, et leurs classes)
mesures = cell(length(type_samples),length(noms));
nb_ech_samples = size(data{1,2},1);
mesures(:,1) = {2:6;7:11;12:13};
mesures(:,2) = {14:18;17:22;23:24};
mesures(:,3) = {26:30;31:35;36:37};
mesures(:,4) = {38:42;43:47;48:49};
mesures(:,5) = {50:55;56:60;61:62};
mesures(:,6) = {63:67;68:73;74:75};
mesures(:,7) = {76:80;81:85;86:87};
% On récupère les longueurs d'onde
wavelengths = data{mesures{1,1},2};
wavelengths = wavelengths(:,1);

% Initialise les tableaux des samples
nb_mesures_skin = 0;
for ind = 1 :length(noms)
    nb_mesures_skin = nb_mesures_skin + length(mesures{2,ind});
end

mesures_skin = [];% 1 colonne 1 mesure
mesures_skin_etiq = [];% 1 colonne 1 mesure
mesure_data = zeros(nb_ech_samples,2,length(type_samples),length(noms));

%2 lignes on prend pas en compte les mesures 'bruit'
mesures_moyennes_peau = zeros(nb_ech_samples, 2, length(noms));

% Pour chaque personne
for ind_pers = 1:size(mesures,2)
    % Pour chaque type de mesure
    for ind = 1:size(mesures,1)
        
        ind_samples = mesures{ind,ind_pers};
        nb_mesures = length(mesures{ind,ind_pers});
       
        % mesures_collected est l'ensemble de mesures pour la meme partie
        % de peau et la meme personne
        mesures_collected = zeros(nb_ech_samples,nb_mesures);
        % Pour chaque mesure
        for ind2 = 1:nb_mesures
            %On prend le tableau (lambda/valeur) correspondant
            values = data{ind_samples(ind2),2};
            mesures_collected(:,ind2) = values(:,2);
%             plot(wavelengths, mesures_collected(:,ind2))
%             hold on;
        end
        if ind == type_mesures_export
            mesures_skin = [mesures_skin , mesures_collected];
            mesures_skin_etiq = [mesures_skin_etiq, repmat(ind_pers,1,nb_mesures)];
        end
        
        % On calcule la moyenne/variance et on l'affiche
        mesure_data(:,1,ind,ind_pers) = mean(mesures_collected,2);
        mesure_data(:,2,ind,ind_pers) = std(mesures_collected,0,2);
        
%         errorbar(wavelengths, mesure_data(:,1,ind,ind_pers), mesure_data(:,2,ind,ind_pers), 'bl', 'LineWidth', 2);
%         
%         hold off;
%         title([noms{ind_pers}, ', ', type_samples{ind}]);
% 
%         axis([350 750 0 0.5]);
%         xlabel('Longueur d''onde en nanomètres')
%         ylabel('Amplitude')
%         pause;
    end
end

figure
% Ici, pour toutes les personnes, on affiche la moyenne/variance
for ind_pers = 1:size(mesures,2)
    errorbar(wavelengths, mesure_data(:,1,type_mesures_export,ind_pers), ...
        mesure_data(:,2,type_mesures_export,ind_pers));
    hold on;
end
legend(noms)
xlabel('Longueur d''onde en nanomètres')
ylabel('Amplitude')
hold off;
title('Spectres des échantillons de peaux')

data = mesures_skin;
label = mesures_skin_etiq;
classes = noms;
save('data_spectro', 'data', 'label', 'classes');

