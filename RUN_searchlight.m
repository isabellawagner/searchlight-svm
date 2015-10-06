
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%isawag, 2013                                 %
%run searchlight analysis                     %  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc
clear all
close all

global dirs

%% setup

%subjects
subjects = [1 2 4 5 7 9 10 11 12 14 15 17 20 24 25 26 27 29 32 33 35 36 37];

%basic dirs
dirs.root = fullfile('/home','memory','isawag','project_WP');

dirs.reports = fullfile(dirs.root,'jobreports');

if ~exist(dirs.reports,'dir'); mkdir(dirs.reports); end

dirs.scripts = fullfile(dirs.root,'scripts','mvpa_searchlight');

addpath(dirs.scripts)

addpath /home/common/matlab/fieldtrip/qsub

%% jobinputs

for subjnr = 1:numel(subjects)
    
    %PXY
    if subjects(subjnr) < 10; prefix = 'P0'; else prefix = 'P'; end
    subj = [prefix,num2str(subjects(subjnr))];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% DECODEDING OPTIONS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 'task'            -- spatian vs. non-spatial
    % 'visual'          -- visual patterns (12 vs. 34)
    % 'transfer-task'   -- generalize to other day/transfer
    % 'transfer-visual' -- generalize to other day/transfer
    decinfo = 'task';
    
    %session (where model should be trained on)
    ss = 2;
    
    %specify where model should be applied to (session 1, session 3)
    transferto = 1;
    
    %type of trial (retrieval)
    memory_type = 'rec';
    
    %SVM options (dont't show output)
    options = '-s 0 -c 1 -t 0 -q';
    
    %searchlight radius
    radius = 8;
    
    %what data
    datatype = 'spmT';
    
    %whole brain
    mask = 'whole-brain';
    
    %get image for every cv fold
    dectime = 'yes';
    
    %make jobinput
    jobinputs{subjnr,1} = subj;
    jobinputs{subjnr,2} = ss;
    jobinputs{subjnr,3} = memory_type;
    jobinputs{subjnr,4} = options;
    jobinputs{subjnr,5} = radius;
    jobinputs{subjnr,6} = datatype;
    jobinputs{subjnr,7} = decinfo;
    jobinputs{subjnr,8} = transferto;
    jobinputs{subjnr,9} = mask;
    jobinputs{subjnr,10} = dectime;
    
end


%% torque

mem = 15;       %in gb
time = 1200;    %time in minutes

cd(dirs.reports)

for jb = 1:size(jobinputs,1)
    
    jobid{jb} = qsubfeval(@searchlight,jobinputs(jb,:),'memreq',mem*(1024^3),'timreq',60*time);

end

