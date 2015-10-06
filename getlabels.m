
function [idx] = getlabels(ss,decinfo,memorytype,mytrial,transferto)

%isawag, 2013

clear idx

if strcmp(decinfo,'task')||strcmp(decinfo,'visual')
    
    if ss==2
        
        %training set: use only correct and high confident trials
        %no control trials
        
        idx.all = find(mytrial.ss_nr==ss & mytrial.corr==1 & mytrial.conf==2 & mytrial.ctrlTrl==0);
    end
    
elseif strcmp(decinfo,'transfer-task') || strcmp(decinfo,'transfer-visual') 
    
    if ss==2

        %training set: use only correct and high confident trials
        %no control trials
        
        idx.all = find(mytrial.ss_nr==ss & mytrial.corr==1 & mytrial.conf==2 & mytrial.ctrlTrl==0);
        
        %add all other trials from sessions where model should be applied
        %to, choose all trials, irrespective of correctness/confidence
        %no control trials
        
        if strcmp(memorytype,'rec')
            
                idx.all = [idx.all, find(mytrial.ss_nr==transferto & mytrial.ctrlTrl==0 & mytrial.trlType==2)];

        elseif strcmp(memorytype,'all')
            
                idx.all = [idx.all, find(mytrial.ss_nr==transferto & mytrial.ctrlTrl==0)];
        end
        
    end
    
end

end
