clearvars;
close all;

data = import_data_cxf('data12jan.cxf');
figure;

noms = {'Thibaud', 'Wassim', 'Vincent', ...
    'Moctar', 'Amadou', 'Boris', 'Mahmoud'};
type_samples = {'Peau', 'Veine', 'Bruit'};
mesures = cell(length(type_samples),length(noms));
mesures(:,1) = {2:6;7:11;12:13};
mesures(:,2) = {14:18;17:22;23:24};
mesures(:,3) = {26:30;31:35;36:37};
mesures(:,4) = {38:42;43:47;48:49};
mesures(:,5) = {50:55;56:60;61:62};
mesures(:,6) = {63:67;68:73;74:75};
mesures(:,7) = {76:80;81:85;86:87};

%2 lignes on prend pas en compte les mesures 'bruit'
mesures_moyennes_peau = zeros(size(data{1,2},1), 2, length(noms));
for ind_pers = 1:size(mesures,2)
    for ind = 1:size(mesures,1)
        num_samples = mesures{ind,ind_pers};
        for ind_samples = num_samples
            %%[ind_pers, ind, ind_samples]
            values = data{ind_samples,2};
            plot(values(:,1), values(:,2))
            hold on;
        end
        hold off;
        title([noms{ind_pers}, ', ', type_samples{ind}]);
        axis([350 750 0 0.5]);
        xlabel('Longueur d''onde en nanomètres')
        ylabel('Amplitude')
        pause;
    end
end


