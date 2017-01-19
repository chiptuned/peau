clear variables;
close all force;

load('data_spectro.mat')

nb_data = numel(label);

% On change le nombre de plus proches voisins et le nombre de validations
k_max = 3;
nb_cross_validations = 20;
% On envoie les ratios d'apprentissage
ratios_learning = 0.1:0.1:0.9;
k_reco = 1:k_max;
reco = zeros(numel(ratios_learning),k_max);

nb_tries = numel(ratios_learning)*numel(k_reco)*nb_cross_validations;
idx_try  = 0;
bar = waitbar(idx_try,'Computing...');

for ratio_idx = 1:numel(ratios_learning)
        for k = 1:numel(k_reco)
            reco_val = zeros(1,nb_cross_validations);
            for ind = 1:nb_cross_validations
                % On permute les données (pour les tirer au hasard)
                iter_perm = randperm(nb_data);
                idx_fin = floor(nb_data*ratios_learning(ratio_idx));
                % On crée les bases de données d'apprentissage et
                % reconnaissance
                data_learning = data(:,iter_perm(1:idx_fin));
                label_learning = label(iter_perm(1:idx_fin));
                data_reco = data(:,iter_perm(idx_fin+1:end));
                label_reco = label(iter_perm(idx_fin+1:end));
                
                % On fait le kppv
                labels_kppv = mykppv(data_learning, label_learning, data_reco, k_reco(k));
                % On calcule le taux de reconnaissance
                reco_val(ind) = numel(find(labels_kppv-label_reco == 0))/numel(label_reco);
                idx_try = idx_try + 1;
                waitbar(idx_try/nb_tries)
            end
            reco(ratio_idx,k) = mean(reco_val);
        end
end
delete(bar);