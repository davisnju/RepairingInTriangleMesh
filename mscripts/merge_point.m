% param in:
%   vp0_idx
%   v1idx v2idx v3idx
%   vertex_m
%   border_l  bli
%   hv_u_matrix
%   adj_list_m

% param out:
%   vp_idx
%   isborder
%   hv_u_matrix
%   adj_list_m

if vp0_idx <= 0
    return
end

if vp0_idx==v3idx || vp0_idx==v2idx
    connect2vertex
    
    return;
end

vp_idx=vp0_idx;
vp=vertex_m(vp_idx,:);
isborder(v1idx)=0;
v1p=hv_u_matrix(v1idx,1);
vpp=hv_u_matrix(vp_idx,1);

%   adj_list_m
adj_list_m{v1idx}=[adj_list_m{v1idx}, vp_idx];
adj_list_m{v2idx}=[adj_list_m{v2idx}, vp_idx];
adj_list_m{v3idx}=[adj_list_m{v3idx}, vp_idx];
adj_list_m{vp_idx}=unique([adj_list_m{vp_idx} v1idx v2idx v3idx]);

new_patch=[[v1idx v2idx vp_idx];
    [v1idx vp_idx v3idx];];
face_patch=[face_patch;new_patch];
face_m=[face_m;new_patch];
fmn=size(face_m,1);
vertex_adj_face{v2idx}=[vertex_adj_face{v2idx};fmn-1];
vertex_adj_face{v3idx}=[vertex_adj_face{v3idx};fmn];
vertex_adj_face{vp_idx}=[vertex_adj_face{vp_idx};fmn-1;fmn];

%  update borders
% if v1 vp on the same border
if vpp==v1p
    
    % get vn1 vn2
    % [vpn1idx,vpn2idx]=get_neighbor(vp_idx,vpp,adj_list_m,isborder,vertex_m,...
    %     vertex_adj_face,face_m,hv_u_matrix);
    vp_idx_ob=find(v_bli==vp_idx);
    vpn1idx=v_bli(calc_next_idx(vp_idx_ob,vn_bli));
    vpn2idx=v_bli(calc_prev_idx(vp_idx_ob,vn_bli));
    
    %search from v3
    border_l(i)=[];
    border_vid_num=size(border_vid,1);
    for j=i:border_vid_num-1
        border_vid{j}=border_vid{j+1};
    end
    border_label=v3idx;
    border_vertex_idx=[ vp_idx; vpn1idx;];
    while vpn1idx ~= v3idx
        % get vn1 vn2
        vp_idx_ob=find(v_bli==vpn1idx);
        vpn1idx=v_bli(calc_next_idx(vp_idx_ob,vn_bli));
        border_vertex_idx=[border_vertex_idx;vpn1idx];
    end
    if length(border_vertex_idx)>2
        border_l=[border_l border_label];
        border_vid{length(border_l)}=border_vertex_idx;
        hv_u_matrix(border_vertex_idx,1)=border_label;
        hv_u_matrix(border_label,2)=hv_u_matrix(vpp,2);
        hv_u_matrix(border_label,3)=length(border_vertex_idx);
    end
    %search from v2
    border_label=vpn2idx;
    border_vertex_idx=[ vp_idx; v2idx;];
    while vpn2idx ~= v2idx
        % get vn1 vn2
        v2idx_ob=find(v_bli==v2idx);
        v2idx=v_bli(calc_next_idx(v2idx_ob,vn_bli));
        border_vertex_idx=[border_vertex_idx;v2idx];
    end
    if length(border_vertex_idx)>2
        border_l=[border_l border_label];
        border_vid{length(border_l)}=border_vertex_idx;
        hv_u_matrix(border_vertex_idx,1)=border_label;
        hv_u_matrix(border_vertex_idx,2)=hv_u_matrix(vpp,2);
        hv_u_matrix(border_vertex_idx,3)=length(border_vertex_idx);
    end
    
else
    % v1 vp on the different border , no border merge            
    
    % test3c island hole
    pbli=find(border_l==vpp);
    vpb_id=border_vid{pbli};
    vpn_bli=length(vpb_id);
    vp_idx_ob=find(vpb_id==vp_idx);
    vpn1idx=vpb_id(calc_next_idx(vp_idx_ob,vpn_bli));
    vpn2idx=vpb_id(calc_prev_idx(vp_idx_ob,vpn_bli));
    if ~isempty(intersect([vpn1idx vpn2idx],[v2idx v3idx]))
        disp('merge border');
        v2idx_idx=find(v_bli==v2idx);
        v3idx_idx=find(v_bli==v3idx);
        vb_id=[v_bli(v2idx_idx:end);v_bli(1:v3idx_idx)];
        
        flip_p=0;
        if vpn1idx==v2idx
            
        elseif vpn1idx==v3idx
            vp_id=[];
            while vpn1idx~=vp_idx
                vp_id=[vp_id;vpn1idx];
                vpn1idx=vpb_id(calc_next_idx(find(vpb_id==vpn1idx),vpn_bli));
            end
            vp_id=[vp_id;vpn1idx];
        elseif vpn2idx==v3idx
            flip_p=0;
        else
            
        end
        vp_id(1)=[];
        vnb_idx=[vb_id;vp_id];
        nbli=vnb_idx(1);
        border_l([pbli i])=[];  
        border_vid_num=size(border_vid,1);
        for j=i:border_vid_num-1
            border_vid{j}=border_vid{j+1};
        end
        if pbli<i            
            border_vid_num=size(border_vid,1);
            for j=pbli:border_vid_num-1
                border_vid{j}=border_vid{j+1};
            end
        else   
            border_vid_num=size(border_vid,1);
            for j=pbli-1:border_vid_num-1
                border_vid{j}=border_vid{j+1};
            end            
        end
        border_l=[border_l nbli];
        border_vid_num=length(border_l);
        border_vid{border_vid_num}=vnb_idx;
        
        hv_u_matrix(vnb_idx,1)=nbli;
        hv_u_matrix(nbli,2)=hv_u_matrix(v1idx,2);
        hv_u_matrix(nbli,3)=length(vnb_idx);
        
        hv_u_matrix(v1idx,1)=v1idx;  % v1 no longer on border
        hv_u_matrix(v1idx,2)=0;
        hv_u_matrix(v1idx,3)=1;
        return;
    end
    
    %   hv_u_matrix
    if v1p==v1idx
        % v1 is root !!!!!!
        this_border_vid=border_vid{i};
        v1p=vp_idx;
        hv_u_matrix(this_border_vid,1)=v1p;
        hv_u_matrix(v1p,2)=hv_u_matrix(v1idx,2);
        hv_u_matrix(v1p,3)=hv_u_matrix(v1idx,3);
        
        border_l(border_l==v1idx)=v1p;
    end
    
    border_vid{i}(border_vid{i}==v1idx)=vp_idx;
end

hv_u_matrix(v1idx,1)=v1idx;  % v1 no longer on border
hv_u_matrix(v1idx,2)=0;
hv_u_matrix(v1idx,3)=1;