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

vp_idx=vp0_idx;
vp=vertex_m(vp_idx,:);
isborder(v1idx)=0;
v1p=hv_u_matrix(v1idx,1);
vpp=hv_u_matrix(vp_idx,1);

% get vn1 vn2
% [vpn1idx,vpn2idx]=get_neighbor(vp_idx,vpp,adj_list_m,isborder,vertex_m,...
%     vertex_adj_face,face_m,hv_u_matrix);
vp_idx_ob=find(v_bli==vp_idx);
vpn1idx=v_bli(mod(vp_idx_ob,vn_bli)+1);
vpn2idx=v_bli(mod(vp_idx_ob-2,vn_bli)+1);
%   adj_list_m
adj_list_m{v1idx}=[adj_list_m{v1idx}, vp_idx];
adj_list_m{v2idx}=[adj_list_m{v2idx}, vp_idx];
adj_list_m{v3idx}=[adj_list_m{v3idx}, vp_idx];
adj_list_m{vp_idx}=unique([adj_list_m{vp_idx};v1idx v2idx v3idx]);

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
    
    if vpn2idx==v2idx
        %remove v2
        isborder(v2idx)=0;
        %search from vpn1
        border_label=vp_idx;
        border_vertex_idx=[v3idx; vp_idx; vpn1idx;];
        while vpn1idx ~= v3idx
            % get vn1 vn2
            vp_idx_ob=find(v_bli==vpn1idx);
            vpn1idx=v_bli(mod(vp_idx_ob,vn_bli)+1);
            if vpn1idx ~= v3idx
                border_vertex_idx=[border_vertex_idx;vpn1idx];
            else
                break;
            end
        end
        border_l(border_l==bli)=border_label;        
        hv_u_matrix(border_vertex_idx,1)=border_label;
        hv_u_matrix(border_label,2)=hv_u_matrix(vpp,2);
        hv_u_matrix(border_label,3)=length(border_vertex_idx);
    elseif vpn1idx==v3idx
        %remove v3
        isborder(v3idx)=0;        
        %search from vpn2
        border_label=vp_idx;
        border_vertex_idx=[vpn2idx; vp_idx; v2idx;];
        while vpn2idx ~= v2idx            
            % get vn2
            v2idx_ob=find(v_bli==v2idx);
            v2idx=v_bli(mod(v2idx_ob-2,vn_bli)+1);
            if vpn2idx ~= v2idx
                 border_vertex_idx=[border_vertex_idx;v2idx];
            else
                break;
            end
        end
        border_l(border_l==bli)=border_label;        
        hv_u_matrix(border_vertex_idx,1)=border_label;
        hv_u_matrix(border_label,2)=hv_u_matrix(vpp,2);
        hv_u_matrix(border_label,3)=length(border_vertex_idx);      
    else        
%         new_patch=[[vp_idx vpn1idx v3idx];
%             [vp_idx v2idx vpn2idx];];
%         face_patch=[face_patch;new_patch];
%         face_m=[face_m;new_patch];
%         fmn=size(face_m,1);
%         
%         %   adj_list_m
%         adj_list_m{v2idx}=[adj_list_m{v2idx}, vpn2idx];
%         adj_list_m{v3idx}=[adj_list_m{v3idx}, vpn1idx];
%         adj_list_m{vpn1idx}=[adj_list_m{v2idx}, v3idx];
%         adj_list_m{vpn2idx}=[adj_list_m{v3idx}, v2idx];
%         
%         vertex_adj_face{v2idx}=[vertex_adj_face{v2idx};fmn];
%         vertex_adj_face{v3idx}=[vertex_adj_face{v3idx};fmn-1];
%         vertex_adj_face{vpn1idx}=[vertex_adj_face{vpn1idx};fmn-1];
%         vertex_adj_face{vpn2idx}=[vertex_adj_face{vpn2idx};fmn];
%         vertex_adj_face{vp_idx}=[vertex_adj_face{vp_idx};fmn-1;fmn];
        
        %search from vpn1
        border_l(border_l==bli)=[]; 
        border_label=vpn2idx;
        i=0;                             %%!!!
        border_l=[border_l;border_label];
        border_vertex_idx=[v3idx; vp_idx; vpn1idx;];
        while vpn1idx ~= v3idx
            % get vn1 vn2
            vp_idx_ob=find(v_bli==vpn1idx);
            vpn1idx=v_bli(mod(vp_idx_ob,vn_bli)+1);
            if vpn1idx ~= v3idx
                border_vertex_idx=[border_vertex_idx;vpn1idx];
            else
                break;
            end
        end
        border_l(border_l==bli)=border_label;
        if length(border_vertex_idx)>2
            border_l=[border_l;border_label];
            hv_u_matrix(border_vertex_idx,1)=border_label;
            hv_u_matrix(border_label,2)=hv_u_matrix(vpp,2);
            hv_u_matrix(border_label,3)=length(border_vertex_idx);
        end
        %search from v2
        border_label=vpn2idx;
        border_vertex_idx=[vpn2idx; vp_idx; v2idx;];
        while vpn2idx ~= v2idx            
            % get vn1 vn2
            v2idx_ob=find(v_bli==v2idx);
            v2idx=v_bli(mod(v2idx_ob-2,vn_bli)+1);
            if vpn2idx ~= v2idx   
                border_vertex_idx=[border_vertex_idx;v2idx];
            else
                break;
            end
        end
        if length(border_vertex_idx)>2
            border_l(border_l==bli)=border_label;
            hv_u_matrix(border_vertex_idx,1)=border_label;
            hv_u_matrix(border_vertex_idx,2)=1;
            hv_u_matrix(border_vertex_idx,3)=length(border_vertex_idx);
        end
        
    end
    
else
    % v1 vp on the different border
    
    new_patch=[[vp_idx vpn1idx v3idx];
        [vp_idx v2idx vpn2idx];];
    face_patch=[face_patch;new_patch];
    face_m=[face_m;new_patch];
    fmn=size(face_m,1);    
    
    %   adj_list_m
    adj_list_m{v2idx}=[adj_list_m{v2idx}, vpn2idx];
    adj_list_m{v3idx}=[adj_list_m{v3idx}, vpn1idx];
    adj_list_m{vpn1idx}=[adj_list_m{v2idx}, v3idx];
    adj_list_m{vpn2idx}=[adj_list_m{v3idx}, v2idx];
    
    vertex_adj_face{v2idx}=[vertex_adj_face{v2idx};fmn];
    vertex_adj_face{v3idx}=[vertex_adj_face{v3idx};fmn-1];
    vertex_adj_face{vpn1idx}=[vertex_adj_face{vpn1idx};fmn-1];
    vertex_adj_face{vpn2idx}=[vertex_adj_face{vpn2idx};fmn];
    vertex_adj_face{vp_idx}=[vertex_adj_face{vp_idx};fmn-1;fmn];    
    
    isborder(vp_idx)=0;
    vppo=vpp;
    if vpp==vp_idx
        % vp is root !!!!!!
        other_border_vid=hv_u_matrix(:,1)==vppo;
        vpp=vpn2idx;
        hv_u_matrix(other_border_vid,1)=vpp;        
        hv_u_matrix(vpp,2)=1;        
        border_l(border_l==vppo)=vpp;
    end
    this_border_vid=hv_u_matrix(:,1)==v1p;
    hv_u_matrix(this_border_vid,1)=vpp;
    hv_u_matrix(vpp,3)=hv_u_matrix(vppo,3)+hv_u_matrix(v1p,3)-2;
    border_l(border_l==v1p)=[];
    hv_u_matrix(vp_idx,1)=vp_idx;  % vp no longer on border
    hv_u_matrix(vp_idx,2)=0;
    hv_u_matrix(vp_idx,3)=1;
end

hv_u_matrix(v1idx,1)=v1idx;  % v1 no longer on border
hv_u_matrix(v1idx,2)=0;
hv_u_matrix(v1idx,3)=1;