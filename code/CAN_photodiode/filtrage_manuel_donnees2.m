clearvars;
close all force;

log_path = 'logs/';
d = dir([log_path, '*.csv']);
% name meanON stdON meanOFF stdOFF
noms = {'thibaud', 'wassim', 'vincent', ...
    'moctar', 'amadou', 'boris', 'mahmoud'};

data_voltage = [];
etiq_voltage = [];

for ind = 1:length(d)
    data = csvread([log_path, d(ind).name]);
    satisfait = false;
    while ~satisfait
        plot(data(:,1), data(:,2), '.b');
        hold on;
        xlabel('Temps en secondes')
        ylabel('Tension en Volt')
        title_first = ['Mesure ', d(ind).name, ', select O'];
        axis([0, data(end,1), floor(min(data(:,2))), ceil(max(data(:,2)))])
        for ind2 = 1:2
            if ind2 == 1
                title([title_first, 'FF aera']);
            else
                title([title_first, 'N aera']);
            end

            rect = getrect;
            x_coin = rect(1);
            y_coin = rect(2);
            dx = rect(3);
            dy = rect(4);

            rectangle('Position',[x_coin, y_coin, dx, dy])

            if dx<0
                x_coin = x_coin + dx;
                dx = -dx;
            end
            if dy<0
                y_coin = y_coin + dy;
                dy = -dy;
            end

            cond1 = (data(:,1)>x_coin);
            cond2 = (data(:,1)<x_coin+dx);
            cond3 = (data(:,2)>y_coin);
            cond4 = (data(:,2)<y_coin+dy);

            good_idx = find(cond1.*cond2.*cond3.*cond4);
            plot(data(good_idx,1), ...
                data(good_idx,2), '.r')
            
            % les tensions sont data(good_idx,2)
            % on passe a la classification de ces points
            % on va les classifier s'ils proviennent d'une classe (noms) et
            % s'ils sont secs et de l'angle 1 (car c'est le seul angle
            % qu'on a, dans une version future pour pourra avoir un
            % diagramme a classer et non pas juste pour un angle
            
            if ind2 == 1
                % moyenne des off
                offset = mean(data(good_idx,2));
            else
                strind1 = regexp(d(ind).name,'_');
                strind2 = regexp(d(ind).name,'-teensy');
                id = d(ind).name(strind1+1:strind2-1);
                cur_class = 0;
                for ind3 = 1:length(noms)
                    if ~isempty(regexp(id, noms{ind3}, 'once'))
                        id_mesure = id(length(noms{ind3})+7:end);
                        cur_class = ind3;
                    end
                end
                if ~((cur_class == 0) || (contains(id_mesure,'m')) || ...
                        (str2double(id_mesure(1)) ~= 1))
                    mesures = data(good_idx,2);
                    for ind_nbmes = 1:numel(mesures)
                        data_voltage = [data_voltage, mesures(ind_nbmes)];
                        etiq_voltage = [etiq_voltage, cur_class];
                    end
                end
            end
        end
        hold off;
        satisfait = input('Satisfait? (0/1) ');
    end
end

data = data_voltage;
label = etiq_voltage;

save('data_app_pd.mat','data','label');