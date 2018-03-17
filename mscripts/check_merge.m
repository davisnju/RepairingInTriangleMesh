function [merge_to_idx, dis]=check_merge(v,vs,cb_idx,th)

merge_to_idx=0;
dis=Inf;

n=size(cb_idx,1);
for i=1:n
    d=norm(vs(cb_idx(i),:)-v);
    if d < th && d < dis
         merge_to_idx=cb_idx(i);
    end
end

end