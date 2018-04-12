% tests

n=10;
for i=1:n
    disp([num2str(i) ' prev:' num2str(calc_prev_idx(i,n)) ...
        ' next:' num2str(calc_next_idx(i,n))]);
    
end