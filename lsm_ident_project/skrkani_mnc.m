function [y,phi] = skrkani_mnc(y,phi,param)
%SKRKANI "Chytre skrkani" - "smart scratching"
%   Vymaze vsechny radky matice Y, PHI a Z tam, kde je vypadek mereni
%   Deletes all rows of the matrix Y, PHI and Z when the measurment failure
%   occured
    y1 = [];
    phi1 = [];
    test_var = [length(find(y==0)),length(y)]; % comment
    while 1
        [row,~] = find(y(1:end,1)==0,1,"first");      
        if isempty(row)
            y = [y1; y];
            phi = [phi1; phi];
            test_var(1,1) = test_var(1,1) + length(y); % comment
            test_var_bool = test_var(1,1) == test_var(1,2); % comment
            fprintf("Num. of rows of the original Y same as the new" + ...
                " + scratched: %s",string(test_var_bool)); % comment
            break;
        end
        y1 = [y1; y(1:row-1)];
        phi1 = [phi1(:,:); phi(1:row-1,:)];
        y = y(row:end);
        phi = phi(row:end,:);
        [row,~] = find(y(1:end,1)~=0,1);
        if isempty(row)
            y = y1;
            phi = phi1;
            break;
        end
        y = y(row+param:end);
        phi = phi(row+param:end,:);
        test_var(1,1) = test_var(1,1) + param; % comment
    end
end

