function [idx]=find_cp(vertex,thmin,thmax)
n=size(vertex,1);
idx=[];
for i=1:n
    [th,~]=cart2pol(vertex(i,1),vertex(i,2));
    if th>=thmin && th<thmax
        idx=[idx;i];
    end
end
end