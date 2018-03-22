function [nb_idx]=find_border_neighbor(idx,adj,isborder)
    neighbor_idx=adj{idx};
    nb_idx=neighbor_idx(isborder(neighbor_idx)==1);
end