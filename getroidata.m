
function [data,labels,runfolds,ssfolds] = getroidata(cat,currroi,indices)

% isawag, 07-03-2013

%get vox patterns of curr_roi from the respective volumes and save the data
%in pattern vecs for later classification

ntrials = length(cat.label{1});

data = zeros(ntrials,length(currroi));

for i = 1:length(cat.label{1})
    
    clear temp
    
    temp = cat.dat{1}(:,:,:,i);
    
    data(i,:) = temp(indices)';
    
end

labels = cat.label{1}';
runfolds = cat.runfold{1}';
ssfolds = cat.ssfold{1}';

end
