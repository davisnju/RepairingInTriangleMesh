function [eso]=push_back_to_edge_set(es,edges)
en=size(edges,1);
for i=1:en
    e=sort(edges(i,:));
    if isempty(es)
        es=[es;e];
    elseif isempty(intersect(es,e,'rows'))
        es=[es;e];
    end
end
eso=es;
end