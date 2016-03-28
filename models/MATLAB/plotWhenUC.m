function table = plotWhenUC(out, gen, varargin)
% Chapter 4: When Does UC matter figure scratchpad
%% Step 1: Copy run info from Excel
% create empty runs var
%   runs = {};
% open in Variable editor and copy full set of Raw Results whenUC dir & run
% code info from UC+CapPlan Compare Summary Tables.xlsx
%
% The list of runs is assumed to first change then rps then co2_limit
%
%% Step 2: Extract Data & Compute Statistics
%[out, gen] = PlanDiff(runs);

%Setup optional parameters and their defaults
defaults = {
            'fig_cap'       true    %produce grided capacity bar graphs
            'fig_diff'      false    %produce grided difference metric plots
            };
opt = SetDefaultOpts(struct(varargin{:}), defaults);

table = [];

%% Step 0: Initialization
rps_levels = 0:20:80;
co2_limit = {'None', '141', '94', '47'};

n_rps = length(rps_levels);
n_co2 = length(co2_limit);

run_group_offset = 10; %number of rows between start of one run group and next
                  %-------CapPlan Predicted------  ---------Actual Ops-----------
%Note: we are using the edFlex runs but calling them edRsv
ops_type_labels = {'Adv.', 'Std.', 'mtFlex', 'UcLp', 'Adv', 'Std-Act', 'mtFlex', 'UcLp'};
ops_type_f_names ={'UC', 'Simp', 'edFlex', 'UClp', 'UC_actual', 'Simp_actual', 'edFlex_actual', 'UClp_actual'};
n_ops = length(ops_type_labels);
diff_no_scale_to_edRsv = true;

%% Setup ordered color/name table
%Colors designed to match those used in Excel (Thesis Ch4)
% Cross-hatching in Excel subtituted with a lighter color
gen_order = {%   unit name                  RGB color
                'old_nuke_st'              [193	199	  0]
                'new_nuke_st'              [248	255	  0]
                'new_coal_st_ccs'          [181	181	181]
                'new_coal_st'              [154	 79	  0]
                'old_coal_lig_st'          [120	 61	  0]
                'old_coal_sub_st'          [115	 59	  0]
                'new_ng_cc_ccs'            [ 59	255	255]
                'new_ng_cc'                [ 69	  0 255]
                'old_ng_cc'                [ 60	  0	223]
                'old_ng_gt'                [210	  0	  0]
                'new_ng_gt_aero'           [255	  0	  0]
                'old_ng_st'                [255	165	 72]
                'wind'                     [  0	152	  0]
            };
%Indentify corresponding plot order
[~, leg_ord_all, plot_ord_all] = intersect(gen_order(:,1),out(1).g_names,'stable');
[~, leg_ord_expand, plot_ord_expand] = intersect(gen_order(:,1),gen.g_expand_names,'stable');

fig = 1;
%                  1-field_name                 2-title                                 3-max   4-leg_mask                         5-run_set      6-plot_order
cap_type_table = { 
%                   'adj_new_cap'        'Adjusted New Capacity (GW)'                     []      []                                 5:8 
%                   'adj_new_cap'        'Adjusted New Capacity (GW, constant Y-scale)'	325     []                                   5:8 
                   'new_cap'            'New Capacity (GW)'                              []      leg_ord_expand                     1:2         plot_ord_expand
                   'new_cap'            'New Capacity (GW)'                              []      leg_ord_expand                     1:4         plot_ord_expand
%                   'new_cap'            'New Capacity (GW, constant Y-scale)'           325      []                                 5:8 
%                   'new_therm_cap'      'New Thermal Capacity (GW)'                      []      gen.expand_mask & gen.therm_mask    5:8
%                   'adj_new_therm_cap'  'Adjusted New Thermal Capacity (GW)'             []      gen.expand_mask & gen.therm_mask    5:8
                   'energy'             'PREDICTED Energy Production (TWh)'              325      leg_ord_all                       [5 2:4]     plot_ord_all
                   'energy'             'ACTUAL Energy Production (TWh)'                 325      leg_ord_all                        5:8        plot_ord_all
                   'energy'             'Energy Production (TWh)'                        325      leg_ord_all                       [5,2,6]     plot_ord_all
%BAD         'CO2e_price_usd_t_predict_err' 'Policy Maker: CO2 price prediction error (vs UC actual)'       []      NaN        5:8
%                   'cost_tot_actual'    'Utility: Total actual cost (capital + ops) if built'     []      NaN        5:8
                 };
%% Step 3: Draw grids of stacked bar plots
if opt.fig_cap
    for t = 1:size(cap_type_table,1)
        figure(fig)
        clf
        fig = fig+1;
        clear plot_data

        for c = 1:n_co2
            for r = 1:n_rps
                % Add one to n_rps to save column for legend
                if isnan(cap_type_table{t,4})
                    leg_col = 0;
                else
                    leg_col = 1;
                end
                plot_idx = (n_co2-c)*(n_rps+leg_col)+r;
                first_run_offset = ((c-1)*n_rps+(r-1))*run_group_offset;

                %extract data and zero out any bad runs
                for run_idx=1:length(cap_type_table{t,5})
                    run_offset_add = cap_type_table{t,5}(run_idx);
                    if out(first_run_offset+run_offset_add).solved == 1
                        plot_data(run_idx,:) = out(first_run_offset+run_offset_add).(cap_type_table{t,1}); %#ok<AGROW>
                    else
                        plot_data(run_idx,:) = 0; %#ok<AGROW>
                    end
                end

                % Add one to n_rps to save column for legend
                ax_handle = subplot(n_co2,n_rps+leg_col,plot_idx);
                bar_handle = bar(plot_data(:,cap_type_table{t,6}),'stack');
                
                %color bar entries
                colormap(cell2mat(gen_order(cap_type_table{t,4},2))./255)
                
                grid('on')
                % Increase font size for labels
                set(gca,'FontSize',12)
                
                % Add text labels
                % Thanks NZTideMan from http://www.mathworks.com/matlabcentral/newsreader/view_thread/151280
                set(gca,'XTickLabel',ops_type_labels(cap_type_table{t,5}),'FontSize',12)

                %Scale x-axis to fit data
                xlim([0, length(cap_type_table{t,5})+1]) 
                %Set y-axis limits if desired
                if not(isempty(cap_type_table{t,3}))
                    ylim([0 cap_type_table{t,3}])
                end
                
                %Label any infeasible solutions
                for run_idx=1:length(cap_type_table{t,5})
                    run_offset_add = cap_type_table{t,5}(run_idx);
                    tot_idx=first_run_offset+run_offset_add;
                    if not(isempty(out(tot_idx).solved))...
                           && not(out(tot_idx).solved)...
                           && not(isempty(out(tot_idx).summary))...
                           && not(isempty(strfind(out(tot_idx).summary.run_modstat, 'Infeasible')))

                        yrange = ylim();
                        text(run_idx,0.1*yrange(2),'Infeasible ', 'Rotation', 90, 'FontSize',15)
                    end
                end
                
                %Add co2 limit labels to first column
                if r==1
                    ylabel(co2_limit{c},'FontWeight','bold','FontSize',15)
                end
                %Add rps lables as titles for the top row
                if c==n_co2
                    title(sprintf(' %d%% RPS ',rps_levels(r)),'FontWeight','bold','FontSize',15)
                end
                
                % Rotate tick labels
                % Requires rotate tick label from Matlab File Exchange
                %  This is included with the ADP toolbox
                % or get from: http://www.mathworks.com/matlabcentral/fileexchange/8722-rotate-tick-label
                rotateticklabel(ax_handle);

                %Add legend only once & position to right of overall figure
                if plot_idx == 1 && not(isscalar(cap_type_table{t,4}) && isnan(cap_type_table{t,4}))
                    % Note reverse order to match plot order
                    % Thanks  Paul Goulart from http://www.mathworks.com/matlabcentral/newsreader/view_thread/37537
                    if isempty(cap_type_table{t,4})
                        leg_mask = 1:gen.n;
                    else
                        leg_mask = cap_type_table{t,4};
                    end
                    leg_txt = strrep(gen_order(leg_mask,1),'_',' ');
                    legend(bar_handle(end:-1:1), leg_txt(end:-1:1),'Location',[.8 0.35 0.15 .3],'FontSize',12)
                end

            end
        end

        %Overall figure title & "axis" labels
        % Thanks Grzegorz Knor for the idea
        % from http://www.mathworks.com/matlabcentral/answers/29855
        axes('Units','Normal','OuterPosition',[-0.05 -0.05 1.1 1.1],'Visible','off'); %#ok<LAXES>
        set(get(gca,'Title'),'Visible','on')

        % pad with spaces to avoid truncation
        title(sprintf('  %s  ', cap_type_table{t,2}),'FontWeight','bold','FontSize',15)
        set(get(gca,'XLabel'),'Visible','on')
%         xlabel('  RPS level  ','FontWeight','bold','FontSize',15)
        set(get(gca,'YLabel'),'Visible','on')
        ylabel('  CO_2 limit (Mt)  ','FontWeight','bold','FontSize',15)

    end
end

%Use consistant figure numbering
fig = size(cap_type_table,1)+1;

%% Step 4: Draw area plots for scalar metrics
if opt.fig_diff
    %                   1-field_name                  2-title                                             3-run_set 4-in_summary 5-color_max 
    diff_metric_table = { 
%                          'renew_fraction'          'Actual Renewable Energy Fraction'                          1       true        []
%                          'CO2e_total_Mt'           'Total Carbon Emissions (Mt)'                               1       true        []
%                           'cost_total_Musd'         'Total Cost (M$)'                                           1       true        []
%                           'energy_non_served_GWh'   'Non-served Energy (GWh)'                                   1       true        [] 
%                           'cost_tot_actual'         'Actual Total Cost with simulated operations (M$)'                                    1       false       []
%                          'co2_pdiff'               'Difference in CO2 emission (percent)'                      2       false       []
                          'norm_e_mix_rms'          'Analyst: Energy Mix PREDICTION Error (Normalized RMS)'      2       false       []
                          'ops_norm_e_mix_rms'      'Utility: Energy Mix ACTUAL Error (Normalized RMS)'          1:4     false       []
%                          'new_cap_fract_madiff'    'Mean Absolute Difference in Capacity Fraction'             2       false       []
%                          'new_cap_type_madiff'     'Mean Absolute Difference in Capacity Type'                 2       false       []
                          'norm_new_cap_rms'        'New Capacity Difference (Normalized RMS)'                   2       false       []
%                          'adj_cost_pdiff'          'Adjusted Difference in Total Cost (percent)'               2       false       []
%                          'adj_cap_mix_madiff_norm' 'Adjusted Normalized New Capacity Difference'               2       false       0.1
%                          'adj_new_therm_cap_pdiff' 'Adjusted Normalized Difference in New Thermal Capacity'    2       false       0.1
%                          'abs_adj_new_therm_cap_pdiff' 'Abs. Adj. Norm. Difference in New Thermal Capacity'    2       false       0.1
%                           'adj_cap_mix_rms_norm'    'RMS Difference in Adjusted Normalized Capacity'            2       false       []
%                           'CO2e_price_usd_t'        'Carbon Price ($/Mt)'                                       1       true        []
%                           'CO2e_price_usd_t_predict_err' 'Carbon Price ($/Mt)'                                       1       true        []
                        };
    clear plot_data

    for m = 1:size(diff_metric_table,1)
        figure(fig)
        clf
        fig = fig+1;
        
        ops_set = diff_metric_table{m,3};
        n_ops_set = length(ops_set);
        
        %Collect all data first, so can use uniform color range
        this_max = -Inf;
        this_min = Inf;
        plot_data = cell(1,n_ops);
        for o = ops_set
            idx_list = o:run_group_offset:length(out);
            plot_data{o}=zeros(length(idx_list),1);
            for n = 1:length(idx_list)
                if diff_metric_table{m,4}
                    if isempty(out(idx_list(n)).summary)...
                            || isempty(out(idx_list(n)).summary.(diff_metric_table{m,1}))
                        plot_data{o}(n) = NaN;
                    else
                        plot_data{o}(n) = out(idx_list(n)).summary.(diff_metric_table{m,1});
                    end
                else
                    if isempty(out(idx_list(n)).(diff_metric_table{m,1}))
                        plot_data{o}(n) = NaN;
                    else                        
                        plot_data{o}(n) = out(idx_list(n)).(diff_metric_table{m,1});
                    end
                end
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
            table.(diff_metric_table{m,1}).(ops_type_f_names{o})=plot_data{o};
        end
        
        if not(isempty(diff_metric_table{m,5}))
            this_max = min(this_max, diff_metric_table{m,5});
        end
        
        %Now produce sub-plots
        for o_idx = 1:n_ops_set
            o = ops_set(o_idx);
            subplot(n_ops_set,4, (o_idx-1)*4+[1,3])
            %Plot as "image" using consistant scaling
            imagesc(plot_data{o},[this_min, this_max])
            title(ops_type_f_names{o})
            xlabel('RPS Level (%)')
            ylabel('CO2 limit (Mt)')
            
            %Add specified axis labels
            set(gca,'XTickLabel',rps_levels, 'XTick', 1:n_rps)
            set(gca,'YTickLabel',co2_limit(end:-1:1), 'YTick',1:n_co2)
            
            if o_idx == n_ops_set
                colorbar('Position', [.8 0.2 0.05 .6])
            end
        end
        
        %Overall figure title
        % Thanks Grzegorz Knor for the idea
        % from http://www.mathworks.com/matlabcentral/answers/29855
        axes('Units','Normal','OuterPosition',[-0.05 -0.05 1.1 1.1],'Visible','off'); %#ok<LAXES>
        set(get(gca,'Title'),'Visible','on')
        % pad with spaces to avoid truncation
        title(sprintf('  %s  ', diff_metric_table{m,2}),'FontWeight','bold','FontSize',15)

    end
end