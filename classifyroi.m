
function [acc] = classifyroi(ss,decinfo,transferto,dectime,data,labels,runfolds,ssfolds,options,ntrials,crossval)

% isawag, 07-03-2013

global subj 

acc = zeros(crossval,1);

if strcmp(decinfo(1:4),'tran') && strcmp(dectime,'yes')

    for c = 1:crossval
        
        if transferto==1 && strcmp(subj,'P02') && c==1
        elseif transferto==1 && strcmp(subj,'P02') && c==2
        elseif transferto==1 && strcmp(subj,'P05') && c==4
        elseif transferto==1 && strcmp(subj,'P05') && c==6
        elseif transferto==1 && strcmp(subj,'P10') && c==3
        elseif transferto==1 && strcmp(subj,'P15') && c==6
        elseif transferto==1 && strcmp(subj,'P27') && c==2
        else
            
            %take all trials that are within one c-fold as test
            clear testsize; testsize = find(ssfolds==transferto & runfolds==c);
            clear test_data; test_data = data(testsize,:);
            clear test_label; test_label = labels(testsize,:);
            
            %take data from other ss for training
            clear trainsize; trainsize = find(ssfolds==ss);
            clear train_data; train_data = data(trainsize,:);
            clear train_label; train_label = labels(trainsize,:);
            
            %classify
            clear model; model = svmtrain(train_label, train_data, options);
            
            clear accuracy; [~,accuracy,~] = svmpredict(test_label, test_data, model);
            
            acc(c) = accuracy(1);
            
        end
        
    end
    
else
    
    trialidx = (1:ntrials)';
    
    for c = 1:crossval
        
        if strcmp(decinfo(1:4),'tran')
            
            clear testsize; testsize = find(ssfolds==transferto);
            
        else

            clear testsize; testsize = find(runfolds==c);
            
        end
        
        clear test_data; test_data = data(testsize,:);
        clear test_label; test_label = labels(testsize,:);
        
        %take everything else for training
        clear trainsize; trainsize = setdiff(trialidx,testsize);
        clear train_data; train_data = data(trainsize,:);
        clear train_label; train_label = labels(trainsize,:);
        
        %classify
        clear model; model = svmtrain(train_label, train_data, options);
        
        clear accuracy; [~,accuracy,~] = svmpredict(test_label, test_data, model);
        
        acc(c) = accuracy(1);
    end
    
end

end