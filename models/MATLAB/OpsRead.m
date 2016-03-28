function out = OpsRead(dir, run_code, summary_only, old_out_names)
%OPSREAD Import operational output files from Advanced Power Models
%
%   out = OpsRead(dir, run_code)
%   out = OpsRead(dir, run_code, true) Only returns the summary
%   out = OpsRead(dir, run_code, [], true) Use old, longer output names (w/ _out & _table)
%
%  out is returned as a structure array
%
% Assumes generator names are consistent (uses unit_commit_table)

% HISTORY
% ver     date    time        who      changes made
% ---  ---------- -----  ------------- ---------------------------------------
%   1  2011-10-05 13:30  BryanP        Adapted from OpsDiff v1
%   2  2011-10-06 00:10  BryanP        Shifted 'out_' from run_code to here
%   3  2011-10-18 09:10  BryanP        Return NaN on file read error
%   4  2011-10-18 10:50  BryanP        Msg on read, add g_types
%   5  2011-10-27 00:15  BryanP        Ignore warnings for summary file data fields too long 
%   6  2011-10-28 16:45  BryanP        Added summary only option 
%   7  2011-10-28 17:00  BryanP        Use run code (rather than run_code) we now add '_out_...' 
%   8  2012-08-26 23:20  BryanP        Default to using new/shorter output file names (no more _out or _table) 
%   9  2012-08-27 17:15  BryanP        Read gen names from summary file with summary_only=true  

if nargin <3 || isempty(summary_only)
    summary_only = false;
end
if nargin <4 || isempty(old_out_names)
    old_out_names = false;
end

%Store file information
out.dir = dir;
out.run_code = run_code;

%Read in raw data
fprintf('Reading data files (summary')
if not(summary_only)
    fprintf(', unit commit, & power)')
else
    fprintf(' only)')
end
fprintf(' for %s...', run_code)
%TODO: suppress warning when trying to convert long memos to number... we
%ignore the results anyway (identifier: 'MATLAB:badsubscript')
% Warning: 'TX07_wk_Cefficiency_ud_afine_ch010_m01_run_time_compare_v234M_111017' 
%  exceeds the MATLAB maximum name length of 63 characters and will be truncated to 
%  'TX07_wk_Cefficiency_ud_afine_ch010_m01_run_time_compare_v234M_1'. 
% > In str2num>protected_conversion at 80
%   In str2num at 46
%   In csv2cell at 286
%   In OpsRead at 24
%   In OpsDiff at 47
warning('off', 'MATLAB:namelengthmaxexceeded')
try
    if old_out_names
        out.summary = csv2cell([dir run_code '_out_summary.csv']);
    else
        out.summary = csv2cell([dir run_code '_summary.csv']);
    end        
    %Parse summary... converts the cell array to a structure
    out.summary = CapPlanDpParseSummary(out.summary);
    %Fill missing required data
    if not(isfield(out.summary, 'valflag_uc_int_unit_min'))
        out.summary.valflag_uc_int_unit_min = NaN;
    end


    %Convert the solution status code string to a number using eval
    model_status = eval(out.summary.run_modstat(1:2));
    %If it solved to optimality for LP (1) or returned an Integer solution
    %for MIP (8), read and process other data
    if  (model_status == 1) || (model_status == 8)
        out.solved=true;
        if not(summary_only)
            if old_out_names
                out.uc_raw = csv2cell([dir run_code '_out_unit_commit_table.csv']);
                out.pow_raw = csv2cell([dir run_code '_out_power_table.csv']);
            else
                out.uc_raw = csv2cell([dir run_code '_uc.csv']);
                out.pow_raw = csv2cell([dir run_code '_power.csv']);
            end                
            fprintf('Success\n')

            %Extract numeric part of uc & power tables
            out.uc = RoundTo(cell2mat(out.uc_raw(2:end, 2:end)),1e-4);
            out.pow = cell2mat(out.pow_raw(2:end, 2:end));

            %Extract names of generators from Unit Commitment columns
            out.g_names = strtrim(out.uc_raw(1,2:end));
    %Also attempt to read in clustering information... no worries if we can't
            try
                if old_out_names
                    out.g_type_map = csv2cell([dir run_code '_out_gen_type.csv']);
                else
                    out.g_type_map = csv2cell([dir run_code '_gen_type.csv']);
                end
                out.g_types = strtrim(out.g_type_map(:,2))';
                fprintf('   Also imported generator type info for %s\n', run_code)
            catch      %#ok<CTCH>
                %Silently ignore the lack of clustering information
            end
        else
            fprintf('Success\n')
        end
    else
        out.solved=false;
        fprintf('Bad\n')
        warning('OpsRead:BadSolution', '\n Warning:%s did not solve. (Status = %s)',run_code, out.summary.run_modstat)
    end
    if summary_only
        %Extract names of generators from cap_total summary fields
        summary_fields = fieldnames(out.summary);
        total_cap_idx = strncmpi('cap_total_GW_',summary_fields,length('cap_total_GW_'));
        out.g_names = strrep(summary_fields(total_cap_idx),'cap_total_GW_','');
    end
catch err 
    if strcmp(err.identifier, 'csv2cell:FileReadError')
        fprintf('Fail\n')
        warning('OpsRead:FileReadError','Failed to open all data files for %s', run_code)
        out = NaN;
        return
    else
        rethrow(err);
    end
end
