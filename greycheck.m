
%written by Tjerk Gutteling, 2013
%modified by isawag, 12-08-2013

function [check] = greycheck(grey_mask,curr_roi)

result = 0;

voxcount=length(curr_roi(:,1));

%check for all 137 (8mm SL) voxels, how many are GM

for i=1:length(curr_roi(:,1))
    
    x = curr_roi(i,1);
    
    y = curr_roi(i,2);
    
    z = curr_roi(i,3);
    
    if grey_mask(x,y,z)==0; gm = 1; else gm = 0; end
    
    result = result + gm;
    
    %less than 30 GM voxels in SL (more than 107 non-GM)
    if result >= (voxcount-30) 
        
        check = 1;
        
        break;
        
    end
    
    %other values in SL, but still more than 30 GM voxels in SL
    if result < (voxcount-30)  %not-GM voxels detected, but less than 107
        
        check=2;
        
    end
    
end

%all voxels are GM
if result==0 
    
    check=0;
end

end