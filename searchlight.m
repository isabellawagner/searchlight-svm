
function searchlight(jobinputs)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% isawag, 06-03-2013                          %  
% based on 'Searchlight.m' by Tjerk Gutteling %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global dirs subj 

addpath /home/memory/isawag/tools/libsvm-3.16/matlab/
addpath /home/common/matlab/spm8

%job_inputs
subj = char(jobinputs(1));
ss = cell2mat(jobinputs(2));
memorytype = char(jobinputs(3));
svmoptions = char(jobinputs(4));
radius = cell2mat(jobinputs(5));
datatype = char(jobinputs(6));
decinfo = char(jobinputs(7));
transferto = cell2mat(jobinputs(8));
mask = char(jobinputs(9));
dectime = char(jobinputs(10));

%% get data and labels
[refvol,DAT,greymask] = getdata(subj,ss,memorytype,datatype,decinfo,transferto);

%get voxel size
tmp = spm_imatrix(refvol.mat);

vx_size = abs(tmp(7:9));

dim = refvol.dim;

% cross-validation
if strcmp(decinfo(1:4),'tran') && strcmp(dectime,'no')
    crossval = 1;
else
    crossval = 7; 
end

ntrials = length(DAT.label{1});

%% analysis 

name = ['searchlight_',...
    'train_',num2str(ss),'_',...
    'test_',num2str(transferto),'_',...
    'trltype_',memorytype,'_',...
    'decode_',decinfo,'_',...
    'time_',dectime,'_',...
    'sl_',num2str(radius),'_',...
    'cv_',num2str(crossval),'_',...
    'svm_',svmoptions,'_',...
    'mask_',datatype];

dirs.results = fullfile(dirs.root,name,['searchlight_',subj]);
if ~exist(dirs.results,'dir'); mkdir(dirs.results); end

%% empty volume

%make an empty volume for writing the output img
clear Vout dataOut 
clear volname; volname = [subj,'_map_searchlight_accuracy'];

%make one image per cv fold, or not
if strcmp(dectime,'yes')
    
    for i = 1:crossval
        
        Vout(i) = refvol;
        Vout(i).fname = [Vout(i).fname(1:find(Vout(i).fname == '/',1,'last')),volname,'_t[',num2str(i),'].nii'];
        dim = refvol.dim;
        dataOut(:,:,:,i) = nan(dim(1),dim(2),dim(3));
        
    end
    
else
    
    Vout = refvol;
    Vout.fname = [Vout.fname(1:find(Vout.fname == '/',1,'last')),volname,'.nii'];
    dim = refvol.dim;
    dataOut = nan(dim(1),dim(2),dim(3));
    
end

%% make a spherical searchlight
[roi] = createroi(0,0,0,radius,vx_size);

vox_proc = 0;
voxcount = 0;

%count all active rois and make a list of all possible coordinates 

clear check
disp('count rois ...')

for x = 1:dim(1)
    
    for y = 1:dim(2)
        
        for z = 1:dim(3)
            
            currRoi = roi + repmat([x,y,z],length(roi(:,1)),1);
            
            if min(currRoi(:) > 0) && max(currRoi(:,1)) < dim(1) && max(currRoi(:,2)) < dim(2) && max(currRoi(:,3)) < dim(3)
             
                check = greycheck(greymask,currRoi);
                
                %more than 30 GM voxels in volume (or all are GM)
                if check == 0 || check == 2 
                    
                    voxcount = voxcount + 1;
                    
                    disp(num2str(voxcount))
                    
                end
                
            end
            
        end
        
    end
    
end

%% searchlight

for x = 1:dim(1)

    for y = 1:dim(2)
        
        for z = 1:dim(3)
            
            %set up the current roi with the xyz coordinates

            currRoi = roi + repmat([x,y,z],length(roi(:,1)),1);
            
            % check whether the current roi is within the volume boundaries 
            if min(currRoi(:) > 0) && max(currRoi(:,1)) < dim(1) && max(currRoi(:,2)) < dim(2) && max(currRoi(:,3)) < dim(3)

                %check if enough GM in searchlight
                check = greycheck(greymask,currRoi);
                
                if check == 0 || check == 2
                    
                    indices = sub2ind(size(greymask),currRoi(:,1),currRoi(:,2),currRoi(:,3));
                    
                    [data,label,runfolds,ssfolds] = getroidata(DAT,currRoi,indices);
                    
                    % remove NaN rows from the pattern
                    data = data(:,~isnan(data(1,:)));
                    data(isnan(data)) = 0;
                    
                    %scale the data so that it's within [-1 1]
                    data = data/nanmax(abs(data(:)));
                    
                    %classifictaion
                    [acc] = classifyroi(ss,decinfo,transferto,dectime,data,label,...
                        runfolds,ssfolds,svmoptions,ntrials,crossval);
                    
                    %save the results to center voxel
                    if strcmp(dectime,'yes')
                        
                        for i = 1:crossval
                            
                            %do nothing if special case (left out runs)
                            if transferto==1 && strcmp(subj,'P02') && i==1
                            elseif transferto==1 && strcmp(subj,'P02') && i==2
                            elseif transferto==1 && strcmp(subj,'P05') && i==4
                            elseif transferto==1 && strcmp(subj,'P05') && i==6
                            elseif transferto==1 && strcmp(subj,'P10') && i==3
                            elseif transferto==1 && strcmp(subj,'P15') && i==6
                            elseif transferto==1 && strcmp(subj,'P27') && i==2   
                            else
                                
                                dataOut(x,y,z,i) = acc(i);

                            end
                            
                        end
                        
                    else
                        
                        %average acc across cv folds
                        dataOut(x,y,z) = mean(acc);
                        
                    end
                    
                    %count to next vox
                    vox_proc = vox_proc + 1;
                    
                end
                
            end
            
        end
        
    end
    
end

%% save results

cd(dirs.results)

if strcmp(dectime,'yes')
    
    for i = 1:crossval
        
        if transferto==1 && strcmp(subj,'P02') && i==1
        elseif transferto==1 && strcmp(subj,'P02') && i==2
        elseif transferto==1 && strcmp(subj,'P05') && i==4
        elseif transferto==1 && strcmp(subj,'P05') && i==6
        elseif transferto==1 && strcmp(subj,'P10') && i==3
        elseif transferto==1 && strcmp(subj,'P15') && i==6
        elseif transferto==1 && strcmp(subj,'P27') && i==2
        else
            
            Vout(i) = spm_write_vol(Vout(i),dataOut(:,:,:,i));
            
        end
        
    end
    
else
    
    Vout = spm_write_vol(Vout,dataOut);
    
end

save('workspace.mat');

end

