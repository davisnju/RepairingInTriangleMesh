
function id=idx_of_edge(es,ea,eb)
id=-1;
sn=size(es,1);
if ea > eb
    t=ea;
    ea=eb;
    eb=t;
end
[~,ia,~]=intersect(es,[ea,eb],'rows');
if ia
    id=ia(1);
end
end