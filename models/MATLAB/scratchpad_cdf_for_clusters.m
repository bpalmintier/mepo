%Scratchpad for cluster error exploration
% Written by Bryan Palmintier
% Extract for CDFs to be run by Mort


% %% Set up Runs list
% if not(exist('reload_data')) || reload_data
%     runs = {
%             '../../results/110925_Long_Term_Unit_Commitment/ercot_results/ercot2007_1wk/'	'TX07_wk_sep_ud_afine_m01'
%             '../../results/110925_Long_Term_Unit_Commitment/ercot_results/ercot2007_1wk/'   'TX07_wk_clust_ud_afine_m01'
%             '../../results/110925_Long_Term_Unit_Commitment/ercot_results/ercot2007_1wk/'	'TX07_wk_Cage_ud_afine_m01'
%             '../../results/110925_Long_Term_Unit_Commitment/ercot_results/ercot2007_1wk/'	'TX07_wk_Csize_ud_afine_m01'
%             '../../results/110925_Long_Term_Unit_Commitment/ercot_results/ercot2007_1wk/'	'TX07_wk_Cefficiency_ud_afine_m01'
%             '../../results/110925_Long_Term_Unit_Commitment/ercot_results/ercot2007_1wk/'	'TX07_wk_Cplant_ud_afine_m01'
%             };
%     %% Get data
%     out = OpsDiff(runs, true); %OpsDiff is in the AdvancedPower family of tools
% end
% reload_data = false

%% Load data from mat file
if not(exist('out','var'))
    load('UCCluster.mat')
end

% and setup names for easier id
id.sep = 1;
    name.full = 'Full Clustering (by type)';    id.full = 2;    color.full = 'k';
    name.age =  'Cluster by AGE';               id.age =  3;    color.age =  'y';
    name.size = 'Cluster by SIZE)';             id.size = 4;    color.size = 'm';
    name.eff =  'Cluster by EFFICIENCY)';       id.eff =  5;	color.eff =  'b';
    name.plant ='Cluster by PLANT)';            id.plant =6;	color.plant ='g';

%% Process diffs of interest
% Notes: 
%  -- all results show commitment/power by "full clustering" groups
%  -- results stored in structures

% Simple absolute differences
uc_diff = struct();
pow_diff = struct();
% Percent differences by unit
uc_pdiff = struct();
pow_pdiff = struct();
% Percent differences divide by total
uc_pdiff_tot = struct();
pow_pdiff_tot = struct();
for f_id=fieldnames(id)'
    f = f_id{1};
    uc_diff.(f)=out(id.sep).uc_as_clust - out(id.(f)).uc_as_clust;
    uc_pdiff.(f)=uc_diff.(f) ./ out(id.sep).uc_as_clust;
    pow_diff.(f)=out(id.sep).pow_as_clust - out(id.(f)).pow_as_clust;
    pow_pdiff.(f)=double(pow_diff.(f)) ./ double(out(id.sep).pow_as_clust);
    
    pow_pdiff_tot.(f) = bsxfun(@rdivide, pow_diff.(f), sum(out(id.sep).pow_as_clust,2));
    uc_pdiff_tot.(f) = bsxfun(@rdivide, double(uc_diff.(f)), sum(out(id.sep).uc_as_clust,2));
end

g_names=out(1).g_names_as_clust;

%% CDFs
% Note: these flatten the unit-type, time space into a single vector
n_entries = numel(pow_diff.full);
names_to_plot = fieldnames(id)';
names_to_plot = names_to_plot(end:-1:2);  %Reversr order & drop separate (non-clustered) results

figure(1)
clf
hold on
title(sprintf('Empirical CDFs for Commitment Error'))
for f_id=names_to_plot
    f = f_id{1};
    if strcmp(f, 'sep')
        continue
    end
    %h = cdfplot(uc_pdiff_tot.(f)(1:end))
    h = plot(sort(uc_pdiff_tot.(f)(1:end)), (1:n_entries)/n_entries);
    set(h,'Color',color.(f))
end
legend(names_to_plot)
grid on

figure(gcf+1)
clf
hold on
title(sprintf('Empirical CDFs for Power Error'))
for f_id=names_to_plot
    f = f_id{1};
    if strcmp(f, 'sep')
        continue
    end
    %h = cdfplot(pow_pdiff_tot.(f)(1:end))
    h = plot(sort(pow_pdiff_tot.(f)(1:end)), (1:n_entries)/n_entries);
    set(h,'Color',color.(f))
end
legend(names_to_plot)
grid on

