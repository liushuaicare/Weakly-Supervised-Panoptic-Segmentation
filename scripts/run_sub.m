% ------------------------------------------------------------------------ 
%  Copyright (C)
%  Torr Vision Group (TVG)
%  University of Oxford - UK
% 
%  Qizhu Li <liqizhu@robots.ox.ac.uk>
%  August 2018
% ------------------------------------------------------------------------ 
% This file is part of the weakly-supervised training method presented in:
%    Qizhu Li*, Anurag Arnab*, Philip H.S. Torr,
%    "Weakly- and Semi-Supervised Panoptic Segmentation,"
%    European Conference on Computer Vision (ECCV) 2018.
% Please consider citing the paper if you use this code.
% ------------------------------------------------------------------------
% This function is the main function of iterative GT generation. It 
% processes all entries of the list file found at opts.list_path
%  INPUT:
%  - opts : options generated by get_opts.m
%
%  DEMO:
%  - See demo_make_iterative_gt.m
% ------------------------------------------------------------------------

function run_sub(opts)
% list
opts.list = importdata(fullfile(opts.data_root, opts.list_path));
% cmap
temp = load(opts.colormap_path);
opts.cmap = temp.cmap;
% objectNames
temp = load(opts.objectNames_path);
opts.objectNames = temp.objectNames;

% make dirs
if ~exist(fullfile(opts.pred_root, opts.sem_save_dir), 'dir')
    mkdir(fullfile(opts.pred_root, opts.sem_save_dir));
end
if ~exist(fullfile(opts.pred_root, opts.ins_save_dir), 'dir')
    mkdir(fullfile(opts.pred_root, opts.ins_save_dir));
end

% main process
fprintf('[%s] Processing %d image(s)...\n', char(datetime), length(opts.list));
for k = 1:length(opts.list)
    % skip if output exists and not foce overwrite
    if save_results(opts, k)
        continue;
    end
    % load required data
    results = load_data(opts, k);
    % semantic label cleaning
    results = clean_label(opts, results);
    % make instance label
    results.ins_pred = ins_box_process(results.final_pred, results.gt_bboxes, opts.ignore_label);
    % save results
    save_results(opts, k, results);
    if mod(k,100) == 0
        fprintf('[%s] Processed %d/%d\n', char(datetime), k, length(opts.list));
    end
end

end