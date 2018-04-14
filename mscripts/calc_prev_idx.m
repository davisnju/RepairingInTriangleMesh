function prev=calc_prev_idx(id,n)

prev=mod(id-1,n);
if ~prev
    prev=n;
end
end