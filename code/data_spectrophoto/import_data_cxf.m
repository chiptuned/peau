function [data] = import_data_cxf(filename)
fid = fopen(filename);
tline = fgets(fid);
nb_samples = 0;
data = [];
while ischar(tline)
    
    if ~isempty(regexp(tline,'<Sample>', 'once'))
        nb_samples = nb_samples+1;
        name = fgets(fid);
        startIndex = regexp(name,'Name');
        line_cell = cell(1,2);
        line_cell{1} = name(startIndex(1)+5:startIndex(2)-3);
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
