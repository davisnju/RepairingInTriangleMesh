function [idx]=find_by_cat(v,vertex,th)
% th=0.001;
idx=intersect(find(vertex(:,1)>v(1)-th),...
    find(vertex(:,1)<v(1)+th));
if isempty(idx)
    return;
end

idy=intersect(find(vertex(idx,2)>v(2)-th),...
    find(vertex(idx,2)<v(2)+th));
if isempty(idy)
    idx=[];
    return;
end
idx=idx(idy);
idz=intersect(find(vertex(idx,3)>v(3)-th),...
    find(vertex(idx,3)<v(3)+th));

idx=idx(idz);

end