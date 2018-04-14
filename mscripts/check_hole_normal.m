function [r]=check_hole_normal(vertex,v_bli,adj,isborder,normal_border)
% [r]=check_hole_normal(vertex,v_bli,adj,isborder,normal_border)
r=0;
vn=length(v_bli);
s=zeros(vn,1);
for vi=1:vn
    vid=v_bli(vi);
    nvid=find_nonborder_neighbor(vid,adj,isborder);
    if isempty(nvid)
        continue
    end
    vec=vertex(nvid(1),:)-vertex(vid,:);
    s(vi)=vec*normal_border';
    
end

if sum(s>0)>sum(s<0)
    r=1;
end

end