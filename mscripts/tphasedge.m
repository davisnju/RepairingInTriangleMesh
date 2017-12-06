function [r]=tphasedge(edge,tp)
%edge [pid1 pid2]
%tp [pid1 pid2 pid3]


r=isempty(find(tp(:)==edge(1)))||isempty(find(tp(:)==edge(2)));
r=~r;

end