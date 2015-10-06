
function [refvol,cat,grey_mask] = getdata(subj,ss,memorytype,datatype,decinfo,transferto)

% isawag, 06-03-2013

global dirs 

%add spm
addpath /home/common/matlab/spm8

%% get labels

cd(dirs.trialinfo)

load([subj,'_trialinfo.mat'],'my_trial')

[idx] = getlabels(ss,decinfo,memorytype,my_trial,transferto);

%% get data

cd(dirs.files)

cd([subj,'_files'])

%get all the volume names from the data type specified

clear F; F = dir([datatype,'*.img']);

clear v n

disp('get volume names...')

for i = 1:size(F,1)
    
    v(i) = spm_vol(F(i).name);
    
    n(i) = str2double(F(i).name(8:10));
    
end

%% read only the volumes in, that are specified according to idx

clear data labels refvol task runfolds ssfolds trl

a = 1;


for i = 1:size(F,1)
    
    %load the data only when filename matches the idx
    
    vol_nr = str2double(F(i).name(8:10));
    
    if ismember(vol_nr,idx.all)
        
        %get a reference volume for later empty volume
        
        if ~exist('refvol','var')
            
            refvol = v(i);
            
        end
        
        disp(['loading trial ',num2str(vol_nr),', ', num2str(a),'/',num2str(size(idx.all,2))])
        
        data(:,:,:,a) = spm_read_vols(v((i)));
        
        %get the label
        
        if strcmp(decinfo,'task') || strcmp(decinfo,'transfer-task')
            
            labels(a) = my_trial.block_cnd(vol_nr);
            
        elseif strcmp(decinfo,'visual') || strcmp(decinfo,'transfer-visual') 

            labels(a) = my_trial.pattern_cnd(vol_nr);
            
        end
        
        %get the crossval folds
        
        ssfolds(a) = my_trial.ss_nr(vol_nr);
        
        clear temprun
        
        if transferto==3 && my_trial.run(vol_nr)==8
            
            temprun = 1;
            
        elseif transferto==3 && my_trial.run(vol_nr)==9
            
            temprun = 2;
            
        else
            
            temprun = my_trial.run(vol_nr);
            
        end
        
        runfolds(a) = temprun;
        
        a = a + 1;
        
    end
    
end

disp('data loaded.')

%% get data in shape

disp('getting data in shape ...')

%loop through all items and create dat/label/fold for actual decoding, save
%in cat variable later

[dat,runfold,ssfold,label] = deal(cell(1,1));

for i = 1:length(labels)
    
    clear LA

    %if label is 1 = cat 1, if label is something else = cat -1
    
    if strcmp(decinfo,'visual') || strcmp(decinfo,'transfer-visual')
        
        if labels(i)==1 || labels(i)==2; LA = 1; else LA = -1; end
        
    else
        
        if labels(i)==1; LA = 1; else LA = -1; end
        
    end
    
    %get the values in shape
    
    if cellfun(@isempty, dat(1))
        
        dat{1} = data(:,:,:,i);
        runfold{1} = runfolds(i);
        ssfold{1} = ssfolds(i);
        label{1} = LA;

    else
        
        dat{1}(:,:,:,end+1) = data(:,:,:,i);
        runfold{1}(1,end+1) = runfolds(i);
        ssfold{1}(1,end+1) = ssfolds(i);
        label{1}(1,end+1) = LA;
        
    end
    
end

clear cat
cat.dat = dat;
cat.runfold = runfold;
cat.ssfold = ssfold;
cat.label = label;

%% grey matter mask

cd(dirs.root)

cd data_preprocessed

cd([subj,'_ss1_mprage'])

%get GM image, resliced to functional dimension, *C1 image*

file = ['r2ns_c1struc_',subj,'_SS1.nii'];

%load the coregistered c1/grey matter image

clear grey_v grey_mask

grey_v = spm_vol(file);

grey_mask = spm_read_vols(grey_v);

grey_mask(grey_mask >= 0.25) = 1;

grey_mask(grey_mask < 0.25) = 0;

end



