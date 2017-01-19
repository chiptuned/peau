clearvars;
close all force;

log_path = 'logs/';
thresh = 0.3
d = dir([log_path, '*.csv']);
for ind = 1:length(d)
    data = csvread([log_path, d(ind).name]);
    
    plot(data(:,1), data(:,2), '.b');
xlabel('Temps en secondes')
ylabel('Tension en Volt')
title(['Mesure ', d(ind).name]);
axis([0, data(end,1), floor(min(data(:,2))), ceil(max(data(:,2)))])
drawnow
end