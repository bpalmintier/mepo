function table = plotCpUcCo2Policy(out, gen, varargin)
% Chapter 4: Carbon Policy example figure scratchpad
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
            'plot_aspect_ratio'     [1 2.6 1]   %Scale subplots for this aspect ratio
            'co2'           (0:15:120)'   %Ex 1: Carbon cost range
%            'co2'           ['No Cap';'141 Mt';' 94 Mt';' 47 Mt']    %Ex 2: carbon limit range
            'co2_form_str'  '$%d/ton'  %Ex 1     
%            'co2_form_str'  '%s'     %Ex 2 
            'col4leg'       2       %Add this many columns for legend
            };
opt = SetDefaultOpts(struct(varargin{:}), defaults);

table = [];

%% Step 0: Initialization
rps_levels = 0.2;

n_rps = length(rps_levels);
n_co2 = size(opt.co2,1);

run_group_offset = 6; %number of rows between start of one run group and next

mix_type_labels = {'Adv (& Actual)', 'Std-Actual', 'Advanced', 'Std-Predict'};
n_types = length(mix_type_labels);

fig = 1;

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

%               1-field_name                 2-title                                    3-max   4-legend order                     5-run_set  6-plot_order  
cap_type_table = { 
%                   'adj_new_cap'        'Adjusted New Capacity (GW)'                     []      []                                  3:4
%                   'adj_new_cap'        'Adjusted New Capacity (GW, constant Y-scale)'	325     []                                    3:4
                   'new_cap'            'New Capacity (GW)'                              68      leg_ord_expand                      3:4       plot_ord_expand
%                   'new_cap'            'New Capacity (GW, constant Y-scale)'           325      []                                  3:4
%                   'new_therm_cap'      'New Thermal Capacity (GW)'                      40      gen.expand_mask & gen.therm_mask     3:4
%                   'adj_new_therm_cap'  'Adjusted New Thermal Capacity (GW)'             []      gen.expand_mask & gen.therm_mask     3:4
                   'energy'             'Energy Production (TWh)'                        325      leg_ord_all                        [1,4,2]   plot_ord_all
                 };


%% Step 3: Draw grids of stacked bar plots
if opt.fig_cap
    for t = 1:size(cap_type_table,1)
        clear plot_data
        figure(fig)
        clf
        fig = fig+1;

        for c = 1:n_co2
            for r = 1:n_rps
                % Add one to n_rps to save column for legend
                %  Note: for single plots, will equal 1 so no need to
                %  change
                plot_idx = (n_rps-r)*(n_co2+opt.col4leg)+c;
                first_run_offset = ((r-1)*n_co2+(c-1))*run_group_offset;

                %extract data and zero out any bad runs
                for run_idx=1:length(cap_type_table{t,5})
                    run_offset_add = cap_type_table{t,5}(run_idx);
                    if out(first_run_offset+run_offset_add).solved == 1
                        plot_data(run_idx,:) = out(first_run_offset+run_offset_add).(cap_type_table{t,1}); %#ok<AGROW>
                    else
                        plot_data(run_idx,:) = 0; %#ok<AGROW>
                    end
                end


                if n_co2*n_rps==1
                    % For only one plot, no need for subplots
                    ax = axes('Units','Normal','OuterPosition',[.05 0 .7 1]); %#ok<LAXES>
                else
                    % Add one to n_rps to save column for legend
                    ax = subplot(n_rps,n_co2+opt.col4leg,plot_idx);
                end
                bar_handle = bar(plot_data(:,cap_type_table{t,6}),'stack');
                
                %color bar entries
                colormap(cell2mat(gen_order(cap_type_table{t,4},2))./255)
                
                % Scale bar to reasonably include our data
                xlim([0 length(cap_type_table{t,5})+1])
                
                grid('on')
                % Add text labels
                % Thanks NZTideMan from http://www.mathworks.com/matlabcentral/newsreader/view_thread/151280
                set(gca,'XTickLabel',mix_type_labels(cap_type_table{t,5}))

                if not(isempty(cap_type_table{t,3}))
                    ylim([0 cap_type_table{t,3}])
                end
                %Add co2cost as title to first row (Except for single plots) 
                if r==n_rps && not(n_rps*n_co2 == 1)
                    title(sprintf(opt.co2_form_str,opt.co2(c,:)),'FontWeight','bold','FontSize',15)
                end
                % Rotate tick labels
                % Requires rotate tick label from Matlab File Exchange
                %  This is included with the ADP toolbox
                % or get from: http://www.mathworks.com/matlabcentral/fileexchange/8722-rotate-tick-label
                rotateticklabel(ax);
                %Add legend only once & position to right of overall figure
                if plot_idx == 1
                    % Note reverse order to match plot order
                    % Thanks  Paul Goulart from http://www.mathworks.com/matlabcentral/newsreader/view_thread/37537
                    if isempty(cap_type_table{t,4})
                        leg_mask = 1:gen.n;
                    else
                        leg_mask = cap_type_table{t,4};
                    end
                    leg_txt = strrep(gen_order(leg_mask,1),'_',' ');
                    legend(bar_handle(end:-1:1), leg_txt(end:-1:1),'Location',[.8 0.35 0.1 .3])
                end
                
                if not(isempty(opt.plot_aspect_ratio))
                    %Reshape subplot as work around for MATLAB poor plot
                    %location
                    set(ax,'PlotBoxAspectRatio',opt.plot_aspect_ratio)
                end
            end
        end

        %Overall figure title & "axis" labels
        % Thanks Grzegorz Knor for the idea
        % from http://www.mathworks.com/matlabcentral/answers/29855
        axes('Units','Normal','OuterPosition',[0 0 1 1],'Visible','off'); %#ok<LAXES>
        set(get(gca,'Title'),'Visible','on')

        my_title = cap_type_table{t,2};
        if n_co2*n_rps==1
            my_title = [my_title, sprintf(' (RPS=%d%%, CO2=',rps_levels(r)*100),...
                        sprintf(opt.co2_form_str,opt.co2(c,:)),...
                        ')']; %#ok<AGROW> No actually it doesn't
        end

        % pad with spaces to avoid truncation
        title(sprintf('  %s  ', my_title),'FontWeight','bold','FontSize',15)
        set(get(gca,'YLabel'),'Visible','on')
        ylabel(sprintf('  %s  ', cap_type_table{t,2}))

        %Add legend
        %Phantom plot to get plot order/colors

    end
end

%Use consistant figure numbering
fig = size(cap_type_table,1)+1;

%% Step 4: Draw area plots for scalar metrics
if opt.fig_diff
    %                   field_name                  title                                                   first_type in_summary  color_max 
    diff_metric_table = { 
%                          'renew_fraction'          'Actual Renewable Energy Fraction'                          1       true        []
%                          'CO2e_total_Mt'           'Total Carbon Emissions (Mt)'                               1       true        []
%                          'cost_total_Musd'         'Total Cost (M$)'                                           1       true        []
%                          'energy_non_served_GWh'   'Non-served Energy (GWh)'                                   1       true        [] 
                          'cost_pdiff'              'Difference in Total Cost (percent)'                        2       false       []
                          'co2_pdiff'               'Difference in CO2 emission (percent)'                      2       false       []
                          'e_mix_rms'               'RMS Difference in Energy Mix'                              2       false       []
%                          'new_cap_fract_madiff'    'Mean Absolute Difference in Capacity Fraction'             2       false       []
%                          'new_cap_type_madiff'     'Mean Absolute Difference in Capacity Type'                 2       false       []
%                          'norm_new_cap'            'Normalized New Capacity Difference'                        2       false       []
                          'adj_cost_pdiff'          'Adjusted Difference in Total Cost (percent)'               2       false       []
%                          'adj_cap_mix_madiff_norm' 'Adjusted Normalized New Capacity Difference'               2       false       0.1
%                          'adj_new_therm_cap_pdiff' 'Adjusted Normalized Difference in New Thermal Capacity'    2       false       0.1
 %                         'abs_adj_new_therm_cap_pdiff' 'Abs. Adj. Norm. Difference in New Thermal Capacity'    2       false       0.1
                          'adj_cap_mix_rms_norm'    'Adjusted Normalized RMS New Capacity Mix'                  2       false       []
                          'CO2e_price_usd_t'        'Carbon Price ($/ton)'                                       1       true        []
                        };
    clear plot_data

    for m = 1:size(diff_metric_table,1)
        figure(fig)
        clf
        fig = fig+1;
        
        o_start = diff_metric_table{m,3};
        
        %Collect all data first, so can use uniform color range
        this_max = -Inf;
        this_min = Inf;
        for o = o_start:n_types
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
            table.(diff_metric_table{m,1}).(mix_type_labels{o})=plot_data{o};
        end
        
        if not(isempty(diff_metric_table{m,5}))
            this_max = min(this_max, diff_metric_table{m,5});
        end
        
        %Now produce sub-plots
        for o = o_start:n_types
            subplot(n_types-o_start+1,4, (o-o_start)*4+[1,3])
            %Plot as "image" using consistant scaling
            imagesc(plot_data{o},[this_min, this_max])
            title(mix_type_labels{o})
            
            %Add specified axis labels
            set(gca,'XTickLabel',rps_levels, 'XTick', 1:n_rps)
            set(gca,'YTickLabel',opt.co2(end:-1:1), 'YTick',1:n_co2)
            
            if o == o_start
                colorbar('Position', [.8 0.2 0.05 .6])
            end
        end
        
        %Overall figure title
        % Thanks Grzegorz Knor for the idea
        % from http://www.mathworks.com/matlabcentral/answers/29855
        axes('Units','Normal','Position',[.075 .075 .85 .86],'Visible','off'); %#ok<LAXES>
        set(get(gca,'Title'),'Visible','on')
        % pad with spaces to avoid truncation
        title(sprintf('  %s  ', diff_metric_table{m,2}),'FontWeight','bold','FontSize',15)

    end
end