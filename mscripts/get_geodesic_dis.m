function [gd]=get_geodesic_dis(vbid,patch_v_idx,adj_list_aa,nv,nvr,gd_map)
visited=zeros(nv,1);
MAX_GEODESIC_DIS=1000000;         %MAX_GEODESIC_DIS
q=[];
q2=patch_v_idx;
fp=-1;
q=[q;vbid;fp];
cd=1;
while ~isempty(q2)
    v=q(1);
    q=q(2:end);
    if v==fp
        if isempty(q)
            break;
        else
            q=[q;fp];
            cd=cd+1;
            v=q(1);
            q=q(2:end);
        end
    end
    visited(v)=1;
    vn=adj_list_aa{v};
    for i=1:length(vn)
        if visited(vn(i))==0
            gd_map(vn(i),vbid)=cd;
            q=[q;vn(i)];
            visited(vn(i))=1;
            if vn(i)>nvr                
                q2(q2==vn(i))=[];
            end
        end
    end
end



gd=gd_map;
end