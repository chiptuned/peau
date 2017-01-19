function [data] = import_data_cxf(filename)

% On ouvre un buffer qui lit le fichier
fid = fopen(filename);

% On lit une ligne du fichier avec fgets
tline = fgets(fid);

% On initialise le nombre d'échantillons à 0 et la data
nb_samples = 0;
data = [];


% Tant qu'on est pas a la fin du fichier
while ischar(tline)
    % Si on est sur un début de sample
    if ~isempty(regexp(tline,'<Sample>', 'once'))
        % On incrémente le nombre de samples
        nb_samples = nb_samples+1;
        
        % On récupère le nom
        name = fgets(fid);
        startIndex = regexp(name,'Name');
        line_cell = cell(1,2);
        line_cell{1} = name(startIndex(1)+5:startIndex(2)-3);
        
        % On ouvre une variable sample qui contient les valeurs
        samples = [];
        fin_sample = false;
        while ~fin_sample
            tline = fgets(fid);
            startIndex = regexp(tline,'<Value', 'once');
            endIndex = regexp(tline,'</Value', 'once');
            if ~isempty(startIndex)
                lambda = str2double(tline(startIndex+13:startIndex+15));
                val = str2double(tline(startIndex+18:endIndex-1));
                samples = [samples; lambda, val];
            elseif ~isempty(regexp(tline,'</Sample>', 'once'))
                fin_sample = true;
            end
        end
        line_cell{2} = samples;
        data = [data; line_cell];
    end
    tline = fgets(fid);
end
fclose(fid);
