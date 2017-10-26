function id=idx_of_vertex(vs,v)
sn=length(vs);
id=-1;
for i=1:sn
    if sum(abs(vs(i,:)-v(:,:)))<0.0008
        id=i;
        break;
    end
end
end