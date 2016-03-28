function [ out, excel_paste ] = OpsDiff(runs, use_old_names)
%OPDIFF compute difference metrics between clustered and separate unit commit outputs 
%
%   [ out, excel_paste ] = OpsDiff()
%     Assumes clustered results in ../ops/out2/UC2_ and separate results in
%     ../ops/runs/UC_...
%
%   [ out, excel_paste ] = OpsDiff(runs)
%     Allows the user to enter run information. RUNS can either be a struct
%     array with dir and prefix fields for each run, or a cell array with
%     dir information in the first column and output file name in the
%     second.
%
%   [ out, excel_paste ] = OpsDiff(runs, true)
%     Use the older, longer naming style for output files (with _out in
%     each name, etc.)
%
%  Note: the first runs is taken as a baseline & last runs is used for
%  clustering information

% HISTORY
% ver     date    time        who      changes made
% ---  ---------- -----  ------------- ---------------------------------------
%   1  2011-10-05 13:10  BryanP        Initial Code
%   2  2011-10-05 13:30  BryanP        Extracted common reads to OpsRead
%   3  2011-10-05 17:00  BryanP        Updated for arbitrary number of runs
%   4  2011-10-05 23:00  BryanP        Bugfix: add & use _as_clust for all non_baseline 
%   5  2011-10-05 23:45  BryanP        Added support for cell array dir & prefix   
%   6  2011-10-06 12:15  BryanP        Expanded xl_paste for more flag reporting 
%   7  2011-10-17 10:35  BryanP        Added demand_scale to xl_paste 
%   8  2011-10-18 09:35  BryanP        Skip missing datafiles 
%   9  2011-10-18 11:35  BryanP        Added ability to use type data for clusters  
%  10  2011-11-03 00:30  BryanP        Skip missing run_code entries 
%  11  2013-06-29 06:47  BryanP        Old name support 

%-- Setup defaults
if nargin < 1 || isempty(runs)
    runs = {'../ops/out/'       'UC_out_'
            '../ops/out2/'      'UC2_out_'
           };
end

if nargin < 2 || isempty(use_old_names)
    use_old_names = false;
end

% If our run list is provided as a cell matrix, convert it to a structure
if iscell(runs)
    runs = struct('dir', runs(:,1), 'run_code', runs(:,2));
end

power_tol = 0.5;

%-- Read in data
n_runs = length(runs);

for r = 1:n_runs
    %Only attempt to read non-blank codes
    if not(isempty(runs(r).run_code))
        raw_out = OpsRead(runs(r).dir, runs(r).run_code, [], use_old_names);  

        %Only store data if we read the input successfully. Skip NaN's to leave
        %a blank entry
        if isstruct(raw_out)
            if isfield(raw_out, 'g_names')
                out(r) = raw_out; %#ok<*AGROW>
                % Fix missing mip_gap
                if not(isfield(out(r).summary, 'run_mip_gap'))
                    out(r).summary.run_mip_gap = NaN;
                end
            end
        end
    end
end

fprintf('\nComputing difference statistics for %d runs...', n_runs)

%-- Establish (initial) alias for baseline
baseline = out(1);

for r = 1:n_runs

    if not(isempty(out(r).uc_raw))
        %-- Compute summary error metrics
        out(r).cost_pdiff = (out(r).summary.cost_total_Musd - baseline.summary.cost_total_Musd)...
                            /baseline.summary.cost_total_Musd;
        %Handle old units for CO2
        if isfield(out(r).summary, 'CO2e_total_Kt')
            out(r).co2_pdiff = (out(r).summary.CO2e_total_Kt - baseline.summary.CO2e_total_Kt)...
                                /baseline.summary.CO2e_total_Kt;
            out(r).summary.CO2e_total_Mt = out(r).summary.CO2e_total_Kt / 1000;
            
        else
            out(r).co2_pdiff = (out(r).summary.CO2e_total_Mt - baseline.summary.CO2e_total_Mt)...
                                /baseline.summary.CO2e_total_Mt;
        end
        out(r).speedup = baseline.summary.run_solver_time_sec/out(r).summary.run_solver_time_sec;
    end
end

%-- Compute time & gen based differences
if isfield(out,'g_types')
    clust_g_names = unique(out(n_runs).g_types);
else
    clust_g_names = out(n_runs).g_names;
end

n_hrs = size(baseline.uc,1);
n_clust = length(clust_g_names);

clust_table_size = [n_hrs n_clust];

% First compute aggregated data for non cluster runs
for r = 1:n_runs
    if not(isempty(out(r).uc_raw))
        out(r).uc_as_clust = int16(zeros(clust_table_size));
        out(r).pow_as_clust = zeros(clust_table_size);

        for n_idx = 1: n_clust
            name = clust_g_names{n_idx};
            if isfield(out,'g_types')
                cols = strncmpi(name, out(r).g_types, length(name));
            else
                cols = strncmpi(name, out(r).g_names, length(name));
            end
            out(r).uc_as_clust(:,n_idx) = sum(out(r).uc(:,cols),2);
            out(r).pow_as_clust(:,n_idx) = sum(out(r).pow(:,cols),2);
        end
        out(r).g_names_as_clust = clust_g_names;
    end
end

% Update baseline
baseline = out(1);

%normalization constants for each time period
uc_by_hr = sum(baseline.uc_as_clust, 2);
pow_by_hr = sum(baseline.pow_as_clust, 2);

uc_by_hr = repmat(uc_by_hr, 1, n_clust);
pow_by_hr = repmat(pow_by_hr, 1, n_clust);

for r = 1:n_runs
    if not(isempty(out(r).uc_raw))
        %array of differences
        uc_diff = double(baseline.uc_as_clust - out(r).uc_as_clust);
        pow_diff = baseline.pow_as_clust - out(r).pow_as_clust;


        uc_diff = uc_diff ./ uc_by_hr;
        pow_diff = pow_diff ./ pow_by_hr;

        %compute #diffs & avg abs error
        out(r).uc_diff_n = nnz(baseline.uc_as_clust ~= out(r).uc_as_clust);
        out(r).uc_diff_avg_abs = mean(mean(abs(uc_diff)));

        out(r).pow_diff_n = nnz(RoundTo(baseline.pow_as_clust, power_tol) ~=...
                                RoundTo(out(r).pow_as_clust, power_tol));
        out(r).pow_diff_avg_abs = mean(mean(abs(pow_diff)));
    end
end
%-- Compute energy mix
for r = 1:n_runs
    if not(isempty(out(r).uc_raw))
        out(r).e_mix = sum(out(r).pow);
        out(r).e_mix = out(r).e_mix/sum(out(r).e_mix);

        out(r).e_mix_as_clust = sum(out(r).pow_as_clust);
        out(r).e_mix_as_clust = out(r).e_mix_as_clust/sum(out(r).e_mix_as_clust);
    end
end

%update baseline
baseline = out(1);

%compute e-mix differences
for r = 1:n_runs
    if not(isempty(out(r).uc_raw))
        out(r).e_mix_diff_avg_abs = mean(abs(out(r).e_mix_as_clust - baseline.e_mix_as_clust));
    end
end
    
%-- Create variable for easy Excel cut and paste
if nargout > 1
    for r = 1: n_runs
        if not(isempty(out(r).uc_raw))
            excel_paste(r,:) = ...
              [ 
                out(r).summary.demand_scale
                length(baseline.g_names)
                size(out(r).uc,2)
                size(out(r).uc,1)
                out(r).summary.flag_min_up_down
                out(r).summary.valflag_uc_ignore_unit_min        
                out(r).summary.valflag_uc_int_unit_min
                strcmpi(out(r).summary.valflag_rsrv, 'separate')
                out(r).summary.flag_pwl_cost
                out(r).summary.valflag_rel_cheat
                out(r).summary.valflag_mip_gap
                out(r).summary.run_mip_gap
                out(r).summary.cost_total_Musd
                out(r).cost_pdiff
                out(r).summary.CO2e_total_Mt
                out(r).co2_pdiff
                out(r).uc_diff_n
                out(r).uc_diff_avg_abs
                out(r).pow_diff_n
                out(r).pow_diff_avg_abs
                out(r).summary.run_solver_time_sec
                out(r).speedup
                out(r).e_mix_as_clust' 
                out(r).e_mix_diff_avg_abs
                out(r).summary.model_num_eq
                out(r).summary.model_num_var
                out(r).summary.model_num_discrete_var
                out(r).summary.model_num_nonzero
              ]';
        else
            %Make sure we have a results row for all runs
            excel_paste(r,1) = 0;
        end
    end
end

fprintf('Done\n')

end