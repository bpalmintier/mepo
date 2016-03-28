function [ out, excel_paste ] = OpsSummary(runs, dir_prefix)
%OPSSUMMARY extract run summary information for pasting into Excel
%
%   [ out, excel_paste ] = OpsSummary()
%     Assumes clustered results in ../ops/out2/UC2 and baselinearate results in
%     ../ops/runs/UC...
%
%   [ out, excel_paste ] = OpsSummary(runs)
%     Allows the user to enter run information. RUNS can either be a struct
%     array with dir and prefix fields for each run, or a cell array with
%     dir information in the first column and output file name in the
%     second.
%
%   [ out, excel_paste ] = OpsSummary(runs, dir_prefix)
%     Specifies ther relative run results path (from the current directory)
%     to prefix all of the run_path information.

% HISTORY
% ver     date    time        who      changes made
% ---  ---------- -----  ------------- ---------------------------------------
%   1  2011-10-28 16:50  BryanP        Adapted from OpsDiff v9

%-- Setup defaults
if nargin < 1 || isempty(runs)
    runs = {'../ops/out/'       'UC_out_'
            '../ops/out2/'      'UC2_out_'
           };
end

% If our run list is provided as a cell matrix, convert it to a structure
if iscell(runs)
    runs = struct('dir', runs(:,1), 'run_code', runs(:,2));
end

%-- Read in data
n_runs = length(runs);

for r = 1:n_runs
    %Only attempt to read non-blank codes
    if not(isempty(runs(r).run_code))
        %true as 3rd parameter implies Only read summary information
        raw_out = OpsRead([dir_prefix, runs(r).dir], runs(r).run_code, true);  

        %Only store data if we read the input successfully. Skip NaN's to leave
        %a blank entry
        if isstruct(raw_out)
            out(r) = raw_out; %#ok<*AGROW>
            % Fix missing mip_gap
            if not(isfield(out(r).summary, 'run_mip_gap'))
                out(r).summary.run_mip_gap = NaN;
            end
        end
    end
end

    
%-- Create variable for easy Excel cut and paste
if nargout > 1
    for r = 1: n_runs
        if isstruct(out(r).summary)
            excel_paste(r,:) = ...
              { 
                out(r).summary.run_modstat
                out(r).summary.run_solver_time_sec
                out(r).summary.run_mip_gap
                out(r).summary.cost_total_Musd
              }';
        else
            %Make sure we have a results row for all runs
            excel_paste(r,:) = {' '};
        end
    end
end

fprintf('Done\n')

end