clearvars;
close all force;

load('data_photodiode.mat');
noms = {'thibaud', 'wassim', 'vincent', ...
    'moctar', 'amadou', 'boris', 'mahmoud'};

% classe mouille angle valeur
data = zeros(length(data_photodiode), 4);
for ind = 1:length(data_photodiode)
    namefile = data_photodiode{ind,1};
    ind1 = regexp(namefile,'_');
    ind2 = regexp(namefile,'-teensy');
    id = namefile(ind1+1:ind2-1);
    
    if ~isempty(regexp(id, 'vincent', 'once'))
        id_mesure = id(14:end);
        if id_mesure(end) == 'm'
            data(ind,2) = 1;
        end
        data(ind,3) =   str2double(id_mesure(1));
        data(ind,1) = 1;
        data(ind,4) = data_photodiode{ind, 4} - data_photodiode{ind, 2}
    end
end

data