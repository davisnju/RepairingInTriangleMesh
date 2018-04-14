function dir=compute_growdir(vid,vertex,border_id,border_vid,mesh_area)
%%
% dir=compute_growdir(vid,vertex,border_id,border_vid,mesh_area)
dir=zeros(1,3);
N=5;
for i=border_id
    diri=zeros(1,3);
    vjid=border_vid{i};    
    vjn=length(vjid);
    for j=1:vjn
        vj=vjid(j);
        dji=vertex(vj,:)-vertex(vid,:);
        d=norm(dji);d=max(d,eps);
        diri=diri+dji/(d^N);
    end
    dir=dir+diri*mesh_area(i);
end
d=norm(dir);d=max(d,eps);
dir=dir/d;
end