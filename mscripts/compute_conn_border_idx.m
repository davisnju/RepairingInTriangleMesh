function conn_border_idx=compute_conn_border_idx(border_label,border_labels,border_vid,hv_u_matrix,adj_list)
%%
%  conn_border_idx=compute_conn_border_idx(border_label,border_vid,hv_u_matrix,adj_list)

conn_border_idx=[];
bn=length(border_labels);

my_border_vid=border_vid{border_labels==border_label};

for bi=1:bn
    bli=border_labels(bi);
    if bli==border_label
        continue
    else
        their_border_vid=border_vid{border_labels==bli};
        if isconnected(my_border_vid(1),their_border_vid(1),...
                hv_u_matrix,adj_list)
            conn_border_idx=[conn_border_idx;bi];
            continue
        end
    end
    
end
end


function [r]=isconnected(a,b,hv_u_matrix,adj_list)
r=0;
q=[a;-1];
c=1;
l=hv_u_matrix(b,1);
vs=zeros(size(hv_u_matrix,1),1);
while ~isempty(q) && c<15
    v=q(1);
    q(1)=[];
    if v<0
        if isempty(q)
            break;
        else
            q=[q;-1];
            c=c+1;
            v=q(1);
            q(1)=[];
        end
    end
    vs(v)=1;
    vnei=adj_list{v};
    vnei_num=length(vnei);
    for i=1:vnei_num
        vj=vnei(i);
        if(vs(vj))
            continue
        else
            if hv_u_matrix(vj,1)==l
                r=1;
                return;
            else
                q=[q;vj];
            end
        end
    end
end
end