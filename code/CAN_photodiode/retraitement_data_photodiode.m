clearvars;
close all force;

load('data_photodiode.mat');
noms = {'thibaud', 'wassim', 'vincent', ...
    'moctar', 'amadou', 'boris', 'mahmoud'};
angles = [74,60,46,34];

%% Insertion dans un tableau
% classe mouille angle valeur
data = zeros(length(data_photodiode), 4);
for ind = 1:length(data_photodiode)
    namefile = data_photodiode{ind,1};
    ind1 = regexp(namefile,'_');
    ind2 = regexp(namefile,'-teensy');
    id = namefile(ind1+1:ind2-1);
    
    for ind2 = 1:length(noms)
        if ~isempty(regexp(id, noms{ind2}, 'once'))
            id_mesure = id(length(noms{ind2})+7:end);
            data(ind,1) = ind2;
        end
    end
    if data(ind,1) == 0
        continue;
    end
    if contains(id_mesure,'m')
        data(ind,2) = 1;
    end
    data(ind,3) =   str2double(id_mesure(1));
    data(ind,4) = data_photodiode{ind, 4} - data_photodiode{ind, 2};
    
end

%% Filtrage des mauvais fichiers + rassemblement des fichiers en une mesure
data = data(data(:,1)~=0,:);
for ind = 1:length(noms)
    for ind2 = 0:1 % mouille ou pas
        for ind3 = 1:numel(angles) % nb d'angle
            cond_moy = (data(:,1)==ind).*(data(:,2)==ind2).*(data(:,3)==ind3);
            idx_to_moy = find(cond_moy);
            if numel(idx_to_moy) > 1
                data(idx_to_moy(1),4) = mean(data(idx_to_moy,4));
                data(idx_to_moy(2:end),:) = [];
            end
        end
    end
end

% Remplacement des angles
data(:,3) = angles(data(:,3));

%% Affichage
legend_polar = {};
for ind = 1:length(noms)
    for ind2 = 0:1
        cond_aff = (data(:,1)==ind).*(data(:,2)==ind2);
        theta = data(find(cond_aff),3);
        rho = data(find(cond_aff),4);
        
        if numel(theta) > 1
            if ind2 == 0
                marker = '-';
            else
                marker = '--';
            end
            % rajouter un truc pour avoir la meme couleur
            polar(theta*pi/180,rho,marker)
            hold on;
            if ind2
                strpeau = ' humidifie';
            else
                strpeau = ' sec';
            end
            legend_polar = [legend_polar; strcat(noms(ind), ', ',strpeau)];
        end
    end
end
legend(legend_polar)
xl = get(gca,'XLim'); yl = get(gca,'YLim');
set(gca,'XLim', [0 xl(2)], 'YLim', [0 yl(2)]);
ylabel('Tension (Volt)') 
title('Polar scattering diagram of subjects')