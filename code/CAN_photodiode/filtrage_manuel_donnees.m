clearvars;
close all force;

log_path = 'logs/';
thresh = 0.3;
d = dir([log_path, '*.csv']);
for ind = 1:length(d)
    data = csvread([log_path, d(ind).name]);
    
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
        
        mean(data(good_idx,2))
        var(data(good_idx,2))
        
    end
    hold off;
end