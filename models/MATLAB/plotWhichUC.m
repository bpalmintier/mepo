function table = plotWhichUC(out, gen, varargin)
% Chapter 4: Which UC constraints matter figure scratchpad
%% Step 1: Copy run info from Excel
% create empty runs var
%   runs = {};
% open in Variable editor and copy full set of Raw Results whenUC dir & run
% code info from UC+CapPlan Compare Summary Tables.xlsx
%
% The list of runs is assumed to first change then rps then opt.co2_limit
%
%% Step 2: Extract Data & Compute Statistics
%[out, gen] = PlanDiff(runs);

%Setup optional parameters and their defaults
defaults = {
            'fig_cap'       true    %produce grided capacity bar graphs
            'fig_diff'      false    %produce grided difference metric plots
            'rps_levels' 	40
            'co2_limit' 	'47Mt'
            };
opt = SetDefaultFields(struct(varargin{:}), defaults);

table = [];

%% Step 0: Initialization

n_rps = length(opt.rps_levels);
n_co2 = length(opt.co2_limit);

run_group_offset = 20; %number of rows between start of one run group and next

ops_type_labels = { 
                    'Full UC'
                    'UcLp'
                    'UC-FlexRsrv'
                    'UC-noRsrv'
                    'UC-noMaint'
                    'UC-noRamp'
                    'UC-noStart'
                    'UC-noMinUpDwn'
                    'Simple'
                    'Simp-noDerate'
                    'onlyMaint'
                    'onlyRamp'
                    'onlyUC'
                    'onlyStart'
                    'onlyMinUpDwn'
                    'onlyFlex-strict'
                    'edRsv-Flex'
                    'edRsv-seperate'
                   };
cap_ops_types = 1:length(ops_type_labels);  %Include all variations on constraints


fig = 1;
%% Step 3: Draw grids of stacked bar plots
%                  1-field_name                 2-title                                 3-max   4-leg_mask                        
cap_type_table = { 
%                   'adj_new_cap'        'Adjusted New Capacity (GW)'                     []      []                              
%                   'adj_new_cap'        'Adjusted New Capacity (GW, constant Y-scale)'	325     []                                
                   'new_cap'            'New Capacity (GW)'                              []      gen.expand_mask                  
%                   'new_cap'            'New Capacity (GW, constant Y-scale)'           325      []                              
                   'new_therm_cap'      'New Thermal Capacity (GW)'                      []      gen.expand_mask & gen.therm_mask 
%                   'adj_new_therm_cap'  'Adjusted New Thermal Capacity (GW)'             []      gen.expand_mask & gen.therm_mask
                   'energy'             'PREDICTED Energy Production (TWh)'              325      []                              
                 };
for t = 1:size(cap_type_table,1)
    figure(fig)
    fig = fig+1;
    clear plot_data

    plot_idx = 1;
    first_run_offset = 0;

    %extract data and zero out any bad runs
    for run_idx=1:length(cap_ops_types)
        run_offset_add = cap_ops_types(run_idx);
        if out(first_run_offset+run_offset_add).solved == 1
            plot_data(run_idx,:) = out(first_run_offset+run_offset_add).(cap_type_table{t,1}); %#ok<AGROW>
        else
            plot_data(run_idx,:) = 0; %#ok<AGROW>
        end
    end

    bar_handle = bar(plot_data,'stack');
    %Make some room for the legend
    set(gca,'OuterPosition',[0,0.1,.9,.8]);

    grid('on')
    %Scale x-axis to fit data
    xlim([0, length(cap_ops_types)+1]) 
    %Set y-axis limits if desired
    if not(isempty(cap_type_table{t,3}))
        ylim([0 cap_type_table{t,3}])
    end
    
    ylabel(sprintf('  %s  ', cap_type_table{t,2}))

    % Add text labels
    % Thanks NZTideMan from http://www.mathworks.com/matlabcentral/newsreader/view_thread/151280
    set(gca,'XTick',1:length(cap_ops_types))
    set(gca,'XTickLabel',ops_type_labels(cap_ops_types))

    % Rotate tick labels
    % Requires rotate tick label from Matlab File Exchange
    %  This is included with the ADP toolbox
    % or get from: http://www.mathworks.com/matlabcentral/fileexchange/8722-rotate-tick-label
    rotateticklabel(gca);

    %Add legend only once & position to right of overall figure
    if plot_idx == 1 && not(isscalar(cap_type_table{t,4}) && isnan(cap_type_table{t,4}))
        % Note reverse order to match plot order
        % Thanks  Paul Goulart from http://www.mathworks.com/matlabcentral/newsreader/view_thread/37537
        if isempty(cap_type_table{t,4})
            leg_mask = 1:gen.n;
        else
            leg_mask = cap_type_table{t,4};
        end
        leg_txt = strrep(out(1).g_names(leg_mask),'_',' ');
        legend(bar_handle(end:-1:1), leg_txt(end:-1:1),'Location',[.85 0.35 0.10 .3])
    end

    % pad with spaces to avoid truncation
    title(sprintf('  %s (RPS=%d%%, CO2 limit=%s)      ', ...
            cap_type_table{t,2}, opt.rps_levels, opt.co2_limit),...
            'FontWeight','bold','FontSize',15)

end

%% Step 4: Draw area plots for scalar metrics
if opt.fig_diff
    %                   field_name                  title                                           first_type in_summary 
    diff_metric_table = { 'renew_fraction'          'Actual Renewable Energy Fraction'                  1       true
                          'CO2e_total_Mt'           'Total Carbon Emissions (Mt)'                       1       true
                          'cost_total_Musd'         'Total Cost (M$)'                                   1       true
                          'energy_non_served_GWh'   'Non-served Energy (GWh)'                           1       true 
                          'cost_pdiff'              'Difference in Total Cost (percent)'                2       false
                          'co2_pdiff'               'Difference in CO2 emission (percent)'              2       false
                          'e_mix_madiff'            'Mean Absolute Difference in Energy Mix'            2       false
                          'new_cap_fract_madiff'    'Mean Absolute Difference in Capacity Fraction'     2       false
                          'new_cap_type_madiff'     'Mean Absolute Difference in Capacity Type'         2       false
                          'norm_new_cap'            'Normalized New Capacity Difference'                2       false
                          'adj_cost_pdiff'          'Adjusted Difference in Total Cost (percent)'       2       false
                          'adj_cap_mix_madiff'      'Adjusted Normalized New Capacity Difference'       2       false
                        };

    for m = 1:size(diff_metric_table,1)
        figure(fig)
        fig = fig+1;
        
        o_start = diff_metric_table{m,3};
        
        %Collect all data first, so can use uniform color range
        this_max = -Inf;
        this_min = Inf;
        for o = o_start:n_ops
            if diff_metric_table{m,4}
                idx_list = o:run_group_offset:length(out);
                plot_data{o}=zeros(length(idx_list),1);
                for n = 1:length(idx_list)
                    plot_data{o}(n) = out(idx_list(n)).summary.(diff_metric_table{m,1});
                end
            else
                plot_data{o} = [out(o:run_group_offset:end).(diff_metric_table{m,1})];
            end
            
            %Skip edRsv if desired
            if o ~= 3 || not(diff_no_scale_to_edRsv)
                %Update min&max, while we are a vector
                this_min = min(this_min, min(plot_data{o}));
                this_max = max(this_max, max(plot_data{o}));
            end
            
            %Convert to properly shaped matrix
            plot_data{o} = reshape(plot_data{o},n_rps,n_co2)';
            plot_data{o} = plot_data{o}(end:-1:1,:);

            %Also store results in table format
            table.(diff_metric_table{m,1}).(ops_type_labels{o})=plot_data{o};
        end
        
        %Now produce sub-plots
        for o = o_start:n_ops
            subplot(n_ops-o_start+1,4, (o-o_start)*4+[1,3])
            %Plot as "image" using consistant scaling
            imagesc(plot_data{o},[this_min, this_max])
            title(ops_type_labels{o})
            
            if o == o_start
                colorbar('Position', [.8 0.2 0.1 .6])
            end
        end
        
        %Overall figure title
        % Thanks Grzegorz Knor for the idea
        % from http://www.mathworks.com/matlabcentral/answers/29855
        axes('Units','Normal','Position',[.075 .075 .85 .85],'Visible','off'); %#ok<LAXES>
        set(get(gca,'Title'),'Visible','on')
        % pad with spaces to avoid truncation
        title(sprintf('  %s  ', diff_metric_table{m,2}),'FontWeight','bold','FontSize',15)

    end
end