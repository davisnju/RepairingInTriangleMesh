function [e_idx]=detect_edge(ne,edge_set,tpis)
edge_tp_adj_num=zeros(ne,1);
tpn=length(tpis);
for i=1:ne
    for j=1:tpn
        if tphasedge(edge_set(i,:),tpis(j,:))
           edge_tp_adj_num(i)=edge_tp_adj_num(i)+1;
        end
    end
end

e_idx=find(edge_tp_adj_num==1);

end