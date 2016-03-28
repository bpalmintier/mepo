function [ out, gen, excel_paste ] = PlanDiff(runs)
%PLANDIFF compute difference metrics between clustered an separate unit commit outputs
%
%   [ out, gen, excel_paste ] = PlanDiff(runs)
%     Allows the user to enter run information. RUNS can either be a struct
%     array with dir and prefix fields for each run, or a cell array with
%     dir information in the first column and output file name in the
%     second. Blank entries in RUNS are used to divide comparision groups.
%     The first run in each group is used as the baseline
%
%  Note: only summary output file is required for comparison
%
%  IMPORTANT: Scenarios within a group are assumed to have identical
%  generator lists & for these lists to appear in the same order in the
%  summary file

% HISTORY
% ver     date    time        who      changes made
% ---  ---------- -----  ------------- ---------------------------------------
%   1  2012-08-26 23:30  BryanP        Adapted from OpsDiff v10
%   2  2012-08-28 22:40  BryanP        Prevent negative adjusted peaker capacity
%   3  2012-08-29 01:40  BryanP        Clean selected non-numeric data
%   4  2012-08-29 23:10  BryanP        Exclude non-expandable gens from new gen metrics
%   5  2012-09-03 12:15  BryanP        Update excel_paste. Fix handling of missing/bad entries
%   6  2012-09-03 18:15  BryanP        Added support for operations only runs by UnitCommit
%   7  2012-09-06 21:45  BryanP        Also read in raw ops data
%   8  2012-09-17 18:15  BryanP        Compute effective planning marg, Expand to Excel paste data
%   9  2012-10-06 19:25  BryanP        Add par_threads to Excel data
%  10  2013-06-10 16:00  BryanP        Ignore run codes starting with _
%  11  2013-12-31 14:50  BryanP        Add missing summary fields for LP only runs 

%-- Setup defaults
if nargin < 1 || isempty(runs)
    runs = {'../capplan/out/'       'SCP_'
            '../capplan/out2/'      'SCP_'
           };
end

% If our run list is provided as a cell matrix, convert it to a structure
if iscell(runs)
    runs = struct('dir', runs(:,1), 'run_code', runs(:,2));
end

%-- Read in scenario data
n_runs = length(runs);
r = 1;
baseline=1;
gen_data_is_read = false;

for r =1:n_runs
    %Advance to the next valid run (non-blank code)
    if isempty(runs(r).run_code)
        if baseline~=r
            %Compute statistics for last group
            out(baseline:(r-1)) = PlanDiffHelper(in(baseline:(r-1)), gen);
        end
        baseline = r+1;
        continue
    end
    
    if runs(r).run_code(1) == '_'
        %Skip run codes beginning with _, typically those with blank real data
        %but a non-blank modifier such as Y for ops, resulting in _ops
        baseline = r+1;
        continue
    end

    %Read output files. Note: true indicates summary only
    raw_in = OpsRead(runs(r).dir, runs(r).run_code, true);

    %Only store data if we read the input successfully. Skip NaN's to leave
    %a blank entry
    if isstruct(raw_in)
        if isempty(strfind(runs(r).run_code,'_ops'))
            fprintf('     Ops: ')
            raw_in.ops = OpsRead(runs(r).dir, [runs(r).run_code '_ops'], true);
        else
            raw_in.ops = NaN;
        end
        in(r) = raw_in;

        %Read in generator data on first successful data read
        if not(gen_data_is_read)
            gen = GenDataHelper(in(r).summary);
            gen_data_is_read = true;
            if not(isequal(sort(in(r).g_names), sort({gen.list.name}'))) %#ok<TRSRT> transpose needed to convert to column vector
                error('advPwr:PlanDiff:gen_mismatch', ...
                        'Generator names from datafile don''t match those in summary')
            end
            %Reorder gen_data from data file to match that from summary
            % This is required to handle GAMS reordering of wind
            [~, gen_summary_order] = sort(in(r).g_names);
            [~, gen_data_order] = sort({gen.list.name}');  %#ok<TRSRT> transpose needed to convert to column vector
            gen.list(gen_summary_order) = gen.list(gen_data_order);


            %-- And identify handy generator masks (using the new order)
            %Identify renewables
            gen.renew_mask = strcmpi('wind', horzcat({gen.list.fuel})) ...
                        | strcmpi('solar', horzcat({gen.list.fuel}));
            gen.therm_mask = not(gen.renew_mask);

            gen.expand_mask = [gen.list.cap_cur] < [gen.list.cap_max];
            gen.n_expand = nnz(gen.expand_mask);

            gen.g_expand_names = in(r).g_names(gen.expand_mask);
            gen.renew_expand_mask = gen.renew_mask(gen.expand_mask);
            gen.therm_expand_mask = gen.therm_mask(gen.expand_mask);

            if not(gen.expand_mask(gen.peaker.idx))
                error('AdvPwr:PlanDiff:PeakerNotExpand','The identified peaker is not elligable for expansion')
            end
            gen.peaker.expand_idx = nnz(gen.expand_mask(1:gen.peaker.idx));

        end
    else
        if exist('in','var') && not(isempty(in))
            in(r).run_code = runs(r).run_code;
        end
    end
end

% Avoid cryptic error messages when data not read. In this case "in" will
% only have the 'run_code' field, and hence length of 1.
if length(fields(in)) == 1
    error('Unable to read any results. Check paths (includig trailing /) and try again... quitting')
end

%Compute difference statistics for final (or only) group
out(baseline:r) = PlanDiffHelper(in(baseline:r), gen);

%-- Create variable for easy Excel cut and paste
if nargout > 2
    excel_paste = {};
    fprintf('Creating Excel Paste data...')

    %work backwards to init size with first assignment
    for r = 1:n_runs
        if not(isempty(out(r).summary))
            %Hack to add in missing fields for LP only solves
            if not(isfield(out(r).summary, 'run_mip_gap'))
                out(r).summary.run_mip_gap = 0;
            end
            
            excel_paste(r,:) = ...
              horzcat(...
              {
                out(r).summary.run_model_name
                out(r).summary.RPS_target_fraction
                out(r).summary.renew_fraction
                out(r).summary.in_CO2e_cap_Kt
                out(r).summary.CO2e_total_Mt
                out(r).summary.in_CO2e_cost_usd_ton
                out(r).summary.CO2e_price_usd_t
                out(r).summary.run_mip_gap
                out(r).summary.run_modstat
                out(r).summary.run_solstat
                out(r).summary.run_solver_time_sec
                out(r).summary.valflag_par_threads
                gen.n
                gen.n_expand

                out(r).summary.valflag_uc_ignore_unit_min
                out(r).summary.valflag_uc_int_unit_min
                out(r).summary.demand_max_GW
                out(r).summary.flag_maint
                out(r).summary.valflag_rsrv
                out(r).summary.flag_ramp
                out(r).summary.flag_unit_commit
                out(r).summary.flag_startup
                out(r).summary.flag_min_up_down
                out(r).summary.flag_derate
                out(r).summary.flag_derate_to_maint
                out(r).summary.valflag_plan_margin
                out(r).summary.valflag_rel_cheat
                out(r).summary.valflag_mip_gap
                out(r).summary.flag_adj_rsrv_for_nse

                out(r).summary.cost_capital_Musd
                out(r).summary.cost_ops_Musd
                out(r).summary.cost_total_Musd
                out(r).cost_tot_actual
                out(r).norm_e_mix_rms
                out(r).ops_norm_e_mix_rms
                out(r).norm_new_cap_rms
              }', ...
              num2cell(out(r).new_cap), ...
              {
              out(r).eff_plan_marg
              }', ...
              num2cell(out(r).energy), ...
              {
                out(r).summary.energy_non_served_GWh
                out(r).summary.shed_GWh_wind

                out(r).summary.model_num_eq
                out(r).summary.model_num_var
                out(r).summary.model_num_discrete_var
                out(r).summary.model_num_nonzero
                out(r).summary.memo
              }'); %#ok<AGROW>
        else
            if size(excel_paste,2)>1 || r==n_runs
                %Make sure we have a results row for all runs
                excel_paste{r,1} = 0; %#ok<AGROW>
            end
        end
    end
end

fprintf('Done\n')

end


%% =========== Helper functions ==========

%----------------
% GenDataHelper
%----------------
function gen = GenDataHelper(first_data)
%Read in and process required generator data

    %-- Read in generator parameters
    %setup structure with filenames
    gen.data_file = first_data.data_gens;
    gen.add_data_file = first_data.data_gparams;
    %Read data from file. true indicates verbose
    gen = CpDpReadGenData(gen, first_data.data_dir, true);

    %-- Find peaker
    % compute per gen fixed costs
    for g = 1:gen.n
        %Fixed operating costs and payments on capital (M$/GW-yr)
        gen.list(g).c_fix = ...
                gen.list(g).c_fix_om ...
                    + gen.list(g).c_cap ...
                        * CapitalRecoveryFactor(first_data.WACC, gen.list(g).life);
    end
    gen.peaker.c_fix = min(vertcat(gen.list.c_fix));
    %If there is more than one with same lowest cost, pick last generator
    %assuming it is the new
    gen.peaker.idx = find(vertcat(gen.list.c_fix) == gen.peaker.c_fix, 1, 'last');
    gen.peaker.name = gen.list(gen.peaker.idx).name;
end

%----------------
% PlanDiffHelper
%----------------
function data = PlanDiffHelper(data, gen)
%Compute the differences for one group of runs
    n_runs = length(data);
    baseline = 1;

    if n_runs == 0
        return
    end

    fprintf('  Computing difference statistics for %d runs...', n_runs)

    %-- Compute values per scenario
    for r = 1:n_runs

        if isempty(data(r).summary)
            if r == baseline
                warning('AdvPwr:PlanDiff:BadBaseline','Bad data for baseline, using next run as baseline')
                baseline=r+1;
            end
            continue
        end

        % Add any missing fields
        if not(isfield(data(r).summary,'flag_derate_to_maint'))
            data(r).summary.flag_derate_to_maint = 0;
        end
        if not(isfield(data(r).summary,'flag_adj_rsrv_for_nse'))
            data(r).summary.flag_adj_rsrv_for_nse = 0;
        end
        if not(isfield(data(r).summary,'cost_capital_Musd'))
            data(r).summary.cost_capital_Musd = '';
        end

        % Extract per generator quantities
        % New capacity only for those eligiable for expansion
        for g = gen.n_expand:-1:1
            f_name = ['cap_new_GW_',gen.g_expand_names{g}];
            if isfield(data(r).summary, f_name)
                data(r).new_cap(g) = data(r).summary.(f_name);
            else
                data(r).new_cap(g) = NaN;
            end

        end
        % Total capacity and energy for all gens
        for g = gen.n:-1:1
            data(r).tot_cap(g) = data(r).summary.(['cap_total_GW_',data(r).g_names{g}]);
            data(r).energy(g) = data(r).summary.(['energy_TWh_',data(r).g_names{g}]);
        end
        data(r).nonserved = data(r).summary.energy_non_served_GWh/1000; %Convert to TWh

%         % energy fraction
%         data(r).e_fract = data(r).energy/sum(data(r).energy);
        % new capacity fraction
        data(r).new_cap_fract = data(r).new_cap/sum(data(r).new_cap);

%         % variations on total capacity
%         data(r).new_therm_cap = data(r).new_cap(not(gen.renew_expand_mask));
%         data(r).new_renew_cap = data(r).new_cap(gen.renew_expand_mask);
%         data(r).sum_new_therm_cap = sum(data(r).new_therm_cap);
%         data(r).sum_new_renew_cap = sum(data(r).new_renew_cap);

        data(r).tot_firm_cap = sum(data(r).tot_cap .* [gen.list.cap_credit]);
        data(r).eff_plan_marg = (data(r).tot_firm_cap - data(r).summary.demand_max_GW)/data(r).summary.demand_max_GW;

        if isstruct(data(r).ops) && not(isempty(data(r).ops.summary))...
               && data(r).ops.solved...
               && isempty(strfind(data(r).ops.summary.run_modstat, 'Infeasible'))

            data(r).cost_tot_actual = ...
                data(r).summary.cost_capital_Musd...
                + data(r).ops.summary.cost_ops_Musd;
            for g = gen.n:-1:1
                data(r).ops.energy(g) = data(r).ops.summary.(['energy_TWh_',data(r).g_names{g}]);
            end

        elseif not(isempty(strfind(data(r).run_code,'_full')))...
                && isempty(strfind(data(r).run_code,'_ops'))
                % Use full results as their own ops results
            data(r).cost_tot_actual = ...
                data(r).summary.cost_total_Musd;
        else
            data(r).cost_tot_actual = NaN;
        end

    end

    %-- compute relative metrics
    for r = 1:n_runs

        if isempty(data(r).summary)
            continue
        end

        % Scalar quantities from summary
        f_list = {  'cost_total_Musd'
                    'CO2e_total_Mt'
                    'CO2e_price_usd_t'
                    'energy_non_served_GWh'
                    'renew_fraction'
                  };
        for f = 1:size(f_list)
            f_name = f_list{f};
            % Clean up non-numeric values
            if not(isnumeric(data(r).summary.(f_name)))
                data(r).summary.(f_name) = NaN;
            end

            %Comparisons with baseline
            data(r).([f_name, '_diff']) = data(r).summary.(f_name) - data(baseline).summary.(f_name);
            data(r).([f_name, '_predict_err']) = abs(data(r).([f_name, '_diff']))...
                                                    / data(r).summary.(f_name);
            data(r).([f_name, '_pdiff']) = abs(data(r).([f_name, '_diff']))...
                                                    / data(baseline).summary.(f_name);
            %Comparisons with our own operations run
            if isstruct(data(r).ops) && not(isempty(data(r).ops.summary))
                data(r).([f_name, '_ops_diff']) = data(r).summary.(f_name) - data(r).ops.summary.(f_name);
                data(r).([f_name, '_ops_predict_err']) = abs(data(r).([f_name, '_ops_diff']))...
                                                        / data(r).summary.(f_name);
                data(r).([f_name, '_ops_pdiff']) = abs(data(r).([f_name, '_ops_diff']))...
                                                        / data(baseline).summary.(f_name);
            else
                data(r).([f_name, '_ops_diff']) = NaN;
                data(r).([f_name, '_ops_predict_err']) = NaN;
                data(r).([f_name, '_ops_pdiff']) = NaN;

            end

        end

        %Mean absolute difference metrics
%         data(r).e_fract_madiff = mean(abs(data(r).e_fract - data(baseline).e_fract));
%         data(r).new_cap_fract_madiff = mean(abs(data(r).new_cap_fract - data(baseline).new_cap_fract));
%         data(r).new_cap_type_madiff = mean(abs(data(r).new_cap - data(baseline).new_cap));

        %% ----- RMS Diff metrics -----
        % Policy analyst: Energy vs baseline (first run) operations...
        if isstruct(data(baseline).ops) ...
                && not(isempty(data(baseline).ops.summary)) ...
                && data(baseline).ops.solved
            data(r).e_mix_rms = rms(data(r).energy - data(baseline).ops.energy);
            data(r).norm_e_mix_rms = data(r).e_mix_rms/mean(data(baseline).ops.energy);
        else
            data(r).e_mix_rms = NaN;
            data(r).norm_e_mix_rms = NaN;
        end

%         data(r).e_fract_rms = rms(data(r).e_fract - data(baseline).e_fract);
%         data(r).new_cap_fract_rms = rms(data(r).new_cap_fract - data(baseline).new_cap_fract);

        % Utility: Ops Energy vs plan energy...
        if isstruct(data(r).ops) ...
                && not(isempty(data(r).ops.summary)) ...
                && data(r).ops.solved
            data(r).ops_e_mix_rms = rms(data(r).energy - data(r).ops.energy);
            data(r).ops_norm_e_mix_rms = data(r).ops_e_mix_rms/mean(data(r).energy);
        else
            data(r).ops_e_mix_rms = NaN;
            data(r).ops_norm_e_mix_rms = NaN;
        end


        % Capacity vs baseline
        data(r).new_cap_type_rms = rms(data(r).new_cap - data(baseline).new_cap);
        data(r).norm_new_cap_rms = data(r).new_cap_type_rms/mean(data(baseline).new_cap);

        %Additional metrics
%         data(r).norm_new_cap_madiff = data(r).new_cap_type_madiff/sum(data(baseline).new_cap);
%         data(r).new_therm_cap_pdiff = (data(r).new_therm_cap - data(baseline).new_therm_cap)...
%                                         / data(baseline).new_therm_cap;
%         data(r).new_renew_cap_pdiff = (data(r).new_renew_cap - data(baseline).new_renew_cap)...
%                                         / data(baseline).new_renew_cap;


        %% Planning margin capacity adjustment calculations (affects peaker capacity)
        % Not used... run GAMS with adjusted planning margin instead!
%         data(r).firm_diff = data(baseline).tot_firm_cap - data(r).tot_firm_cap;
%         data(r).peaker_cap_adj = data(r).firm_diff / gen.list(gen.peaker.idx).cap_credit;
%
%         data(r).adj_new_cap = data(r).new_cap;
%         data(r).adj_new_cap(gen.peaker.expand_idx) = max(0, data(r).adj_new_cap(gen.peaker.expand_idx) ...
%                                                 + data(r).peaker_cap_adj);
%         %Adjusted Metrics
%         data(r).adj_cost_total_Musd_pdiff = data(r).cost_total_Musd_pdiff ...
%                                     + data(r).peaker_cap_adj * gen.peaker.c_fix;
%         data(r).adj_cap_mix_madiff = mean(abs(data(r).adj_new_cap - data(baseline).new_cap));
%         data(r).adj_cap_mix_madiff_norm = data(r).adj_cap_mix_madiff / sum(data(baseline).new_cap);
%
%         data(r).adj_cap_mix_rms = sqrt(mean((data(r).adj_new_cap - data(baseline).new_cap).^2));
%         data(r).adj_cap_mix_rms_norm = data(r).adj_cap_mix_rms / sum(data(baseline).new_cap);
%
%         data(r).adj_new_therm_cap = data(r).adj_new_cap(gen.therm_expand_mask);
%         data(r).adj_new_therm_cap_pdiff = (sum(data(r).adj_new_therm_cap) - sum(data(baseline).adj_new_therm_cap))...
%                                         / sum(data(baseline).adj_new_therm_cap);
%         data(r).abs_adj_new_therm_cap_pdiff = abs(data(r).adj_new_therm_cap_pdiff);
    end
    fprintf('Done\n\n')
end
