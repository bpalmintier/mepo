%Scratchpad for cluster error exploration

%% Set up Runs list
if not(exist('reload_data')) || reload_data
    runs = {
            '../../results/110925_Long_Term_Unit_Commitment/ercot_results/ercot2007_1wk/'	'TX07_wk_sep_ud_afine_m01'
            '../../results/110925_Long_Term_Unit_Commitment/ercot_results/ercot2007_1wk/'   'TX07_wk_clust_ud_afine_m01'
            '../../results/110925_Long_Term_Unit_Commitment/ercot_results/ercot2007_1wk/'	'TX07_wk_Cage_ud_afine_m01'
            '../../results/110925_Long_Term_Unit_Commitment/ercot_results/ercot2007_1wk/'	'TX07_wk_Csize_ud_afine_m01'
            '../../results/110925_Long_Term_Unit_Commitment/ercot_results/ercot2007_1wk/'	'TX07_wk_Cefficiency_ud_afine_m01'
            '../../results/110925_Long_Term_Unit_Commitment/ercot_results/ercot2007_1wk/'	'TX07_wk_Cplant_ud_afine_m01'
            };
    %% Get data
    out = OpsDiff(runs, true);
end
reload_data = false

id.sep = 1;
    name.full = 'Full Clustering (by type)';    id.full = 2;
    name.age =  'Cluster by AGE';               id.age =  3;
    name.size = 'Cluster by SIZE)';             id.size = 4;
    name.eff =  'Cluster by EFFICIENCY)';       id.eff =  5;
    name.plant ='Cluster by PLANT)';            id.plant =6;

%% Process diffs of interest
% Simple absolute differences
uc_diff = struct();
pow_diff = struct();
% Percent differences by unit
uc_pdiff = struct();
pow_pdiff = struct();
% Percent differences divide by total
uc_pdiff_tot = struct();
pow_pdiff_tot = struct();
for f=fieldnames(id)'
    f = f{1};
    uc_diff.(f)=out(id.sep).uc_as_clust - out(id.(f)).uc_as_clust;
    uc_pdiff.(f)=uc_diff.(f) ./ out(id.sep).uc_as_clust;
    pow_diff.(f)=out(id.sep).pow_as_clust - out(id.(f)).pow_as_clust;
    pow_pdiff.(f)=double(pow_diff.(f)) ./ double(out(id.sep).pow_as_clust);
    
    pow_pdiff_tot.(f) = bsxfun(@rdivide, pow_diff.(f), sum(out(id.sep).pow_as_clust,2));
    uc_pdiff_tot.(f) = bsxfun(@rdivide, double(uc_diff.(f)), sum(out(id.sep).uc_as_clust,2));
end

g_names=out(1).g_names_as_clust;

% %% CDFs
% figure(1)
% cdfplot(pow_diff.full(1:end))
% title(sprintf('Empirical CDF for %s Error: %s', 'Commitment', name.full))
% 
% figure(gcf+1)
% cdfplot(pow_diff.full(1:end))
% title(sprintf('Empirical CDF for %s Error: %s', 'Power', name.full))
% 
%Indeed there are lots of zeros. Let's see if they follow any patterns:

%% Error Heatmaps
for f=fieldnames(name)'
    f = f{1};

    %Commitment
    figure(gcf+1)
    colormap('jet')
    imagesc(uc_diff.(f),[-10, 10])
    colorbar
    title(sprintf('Heatmap of %s Error: %s', 'Commitment', name.(f)))
    set(gca,'XTickLabel',g_names)
    ylabel('Simulation time (hrs)')

    figure(gcf+1)
    colormap('jet')
    imagesc(pow_diff.(f),[-2500,2500])
    colorbar
    title(sprintf('Heatmap of %s Error: %s', 'Power', name.(f)))
    set(gca,'XTickLabel',g_names)
    ylabel('Simulation time (hrs)')
end

%Yes, patterns. Clearly concentrated on certain generators and in certain
%hours. Let's look at ramping 

%% Ramping map
delta_uc = out(id.sep).uc_as_clust(2:end,:) - out(id.sep).uc_as_clust(1:(end-1),:);
delta_pow = out(id.sep).pow_as_clust(2:end,:) - out(id.sep).pow_as_clust(1:(end-1),:);

figure(gcf+1)
colormap('spring')
imagesc(delta_uc)
colorbar
title('Commitment Ramp map')
set(gca,'XTickLabel',g_names)
ylabel('Simulation time (hrs)')

figure(gcf+1)
colormap('spring')
imagesc(delta_pow)
colorbar
title('Power Ramp map')
set(gca,'XTickLabel',g_names)
ylabel('Simulation time (hrs)')

% OK there is a close map for ramping and errors. Let's look at type of
% errors and see if this also maps to a time of day pattern

%% Timeseries comparisons
%figure(gcf+1)
%plot(out(id.sep).uc_as_clust(:,strcmpi('ng_cc',g_names)))

%% Hour of Day Differences (for EFFICIENCY ONLY)
uc_by_hr = 0;
pow_by_hr = 0;
uc_by_hr_pdiff_tot = 0;
pow_by_hr_pdiff_tot = 0;

num_days =7;
for day = 1:num_days
    offset = (day-1)*24;
    uc_by_hr = uc_by_hr + uc_diff.eff((offset+1):(offset+24),:);
    pow_by_hr = pow_by_hr + pow_diff.eff((offset+1):(offset+24),:);
    
    uc_by_hr_pdiff_tot = uc_by_hr_pdiff_tot + uc_pdiff_tot.eff((offset+1):(offset+24),:);
    pow_by_hr_pdiff_tot = pow_by_hr_pdiff_tot + pow_pdiff_tot.eff((offset+1):(offset+24),:);
end
uc_by_hr = double(uc_by_hr)/num_days;
pow_by_hr = pow_by_hr/num_days;
uc_by_hr_pdiff_tot = uc_by_hr_pdiff_tot/num_days;
pow_by_hr_pdiff_tot = pow_by_hr_pdiff_tot/num_days;

