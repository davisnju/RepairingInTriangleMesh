% param in:
%   vp10_idx or vp20_idx
%   v1idx v2idx v3idx
%   vertex_m
%
%   hv_u_matrix
%   adj_list_t

% param out:
%   vp_idx
%   isborder
%   hv_u_matrix
%   adj_list_t
if vp10_idx>0 && vp20_idx>0
    if vp10_idx==vp20_idx
        vp0_idx=vp10_idx;
        merge_point
    else
        vp1_idx=vp10_idx;
        vp2_idx=vp20_idx;
        isborder(v1idx)=0;
        v1p=hv_u_matrix(v1idx,1);
        vpp1=hv_u_matrix(vp1_idx,1);
        vpp2=hv_u_matrix(vp2_idx,1);
        %   adj_list_m
        adj_list_m{v1idx}=[adj_list_m{v1idx}, vp1_idx, vp2_idx];
        adj_list_m{v2idx}=[adj_list_m{v2idx}, vp1_idx];
        adj_list_m{v3idx}=[adj_list_m{v3idx}, vp2_idx];
        adj_list_m{vp1_idx}=unique([adj_list_m{vp1_idx} v1idx v2idx]);
        adj_list_m{vp2_idx}=unique([adj_list_m{vp2_idx} v1idx v3idx]);
        
        new_patch=[[v1idx v2idx vp1_idx];
            [v1idx vp1_idx vp2_idx];
            [v1idx vp2_idx v3idx];];
        face_patch=[face_patch;new_patch];
        face_m=[face_m;new_patch];
        fmn=size(face_m,1);
        vertex_adj_face{v2idx}=[vertex_adj_face{v2idx};fmn-2];
        vertex_adj_face{v3idx}=[vertex_adj_face{v3idx};fmn];
        vertex_adj_face{vp1_idx}=[vertex_adj_face{vp1_idx};fmn-1;fmn];
        vertex_adj_face{vp2_idx}=[vertex_adj_face{vp2_idx};fmn-2;fmn-1];
        
        % if v1 vp on the same border
        vpp=vpp1;
        if vpp==v1p
            vp_idx_ob=find(v_bli==vp2_idx);
            vpn1idx=v_bli(mod(vp_idx_ob,vn_bli)+1);
            vp_idx_ob=find(v_bli==vp1_idx);
            vpn2idx=v_bli(mod(vp_idx_ob-2,vn_bli)+1);
            %search from v3
            border_l(i)=[];
            border_label=v3idx;
            border_vertex_idx=[ vp2_idx; vpn1idx;];
            while vpn1idx ~= v3idx
                % get vn1 vn2
                vp_idx_ob=find(v_bli==vpn1idx);
                vpn1idx=v_bli(mod(vp_idx_ob,vn_bli)+1);
                border_vertex_idx=[border_vertex_idx;vpn1idx];
            end
            if length(border_vertex_idx)>2
                border_l=[border_l border_label];
                border_vid{length(border_l)}=border_vertex_idx;
                hv_u_matrix(border_vertex_idx,1)=border_label;
                hv_u_matrix(border_label,2)=hv_u_matrix(vpp,2);
                hv_u_matrix(border_label,3)=length(border_vertex_idx);
            end
            %search from vpn2
            border_label=vpn2idx;
            border_vertex_idx=[ vp1_idx; v2idx;];
            while vpn2idx ~= v2idx
                % get vn1 vn2
                v2idx_ob=find(v_bli==v2idx);
                v2idx=v_bli(mod(v2idx_ob,vn_bli)+1);
                border_vertex_idx=[border_vertex_idx;v2idx];
            end
            if length(border_vertex_idx)>2
                border_l=[border_l border_label];
                border_vid{length(border_l)}=border_vertex_idx;
                hv_u_matrix(border_vertex_idx,1)=border_label;
                hv_u_matrix(border_vertex_idx,2)=hv_u_matrix(vpp,2);
                hv_u_matrix(border_vertex_idx,3)=length(border_vertex_idx);
            end
            
        else% if v1 vp on different border
            pbi=find(border_l==vpp);
            vo_bli=border_vid{pbi};
            von_bli=length(vo_bli);
            border_label=vp1_idx;
            border_l([i pbi])=[];
            %             border_vid{[i pbi]}=border_vertex_idx;
            % === search other border from vp2 to vp1
            vp_idx_ob=find(vo_bli==vp2_idx);
            vpn1idx=vo_bli(mod(vp_idx_ob,von_bli)+1);%next
            border_vertex_idx=[vp2_idx; vpn1idx;];
            while vpn1idx ~= vp1_idx
                % get vn1 vn2
                vp_idx_ob=find(vo_bli==vpn1idx);
                vpn1idx=vo_bli(mod(vp_idx_ob,von_bli)+1);
                border_vertex_idx=[border_vertex_idx;vpn1idx];
            end
            % === search this border from v2 to v3
            vp_idx_ob=find(v_bli==v2idx);
            vpn1idx=v_bli(mod(vp_idx_ob,vn_bli)+1);%next
            border_vertex_idx=[border_vertex_idx;v2idx;vpn1idx];
            while vpn1idx ~= v3idx
                % get vn1 vn2
                vp_idx_ob=find(v_bli==vpn1idx);
                vpn1idx=v_bli(mod(vp_idx_ob,vn_bli)+1);
                border_vertex_idx=[border_vertex_idx;vpn1idx];
            end
            
            if length(border_vertex_idx)>2
                border_l=[border_l border_label];
                border_vid{length(border_l)}=border_vertex_idx;
                hv_u_matrix(border_vertex_idx,1)=border_label;
                hv_u_matrix(border_label,2)=hv_u_matrix(vpp,2)+1;
                hv_u_matrix(border_label,3)=length(border_vertex_idx);
            end
            
            
            
            
        end
        
        hv_u_matrix(v1idx,1)=v1idx;  % v1 no longer on border
        hv_u_matrix(v1idx,2)=0;
        hv_u_matrix(v1idx,3)=1;
    end
    return
end

vp0_idx=vp10_idx;
merge_point
vp0_idx=vp20_idx;
merge_point