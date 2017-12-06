%计算水平面参数
%%
ground = large_u;
ground_x = ground(:,1);
ground_y = ground(:,2);
ground_z = ground(:,3);
len = length(ground_x);

possible_idx=ground_z<quantile(ground_z,0.25);
[fitresult, gof] = createFitGround(ground_x(possible_idx),...
    ground_y(possible_idx),ground_z(possible_idx));
p00 = fitresult.p00;
p10 = fitresult.p10;
p01 = fitresult.p01;
ng = [-p10,-p01,1];

%plane z=p00+p10*x+p01*y
inner_dis=distance2plane(large_u(possible_idx,:),[p00,p10,p01]);

%%
%筛去地面点
dis_e_theta = 0.1;
dis_e=max(dis_e_theta,quantile(inner_dis,0.8));
u_dis=distance2plane(vertex_set,[p00,p10,p01]);
groud_v=vertex_set(u_dis<dis_e,:);
model_v=vertex_set(u_dis>=dis_e,:);

for i=1:length(model_v)
    
    
    
end

%%
%PCA
% 
% [coeff,score,latent,tsquared,explained] = pca(ground);
% figure;
% biplot(coeff(:,1:2),'scores',score(:,1:2),'varlabels',{'v_1','v_2','v_3'});
% 
% % figure;
% % hold on;
% % for i=0:1:len/3-1
% %     if score
% %     plot3(ground_x([3*i+1:3*i+3,3*i+1]),ground_y([3*i+1:3*i+3,3*i+1]),...
% %         ground_z([3*i+1:3*i+3,3*i+1]),[color,'.']); 
% %     end
% % end
% % xlabel([num2str(u(5,1)),',',num2str(u(5,2)),',',num2str(u(5,3))]);
% % grid on;
% %%
% theta_g = 0.7;
% nz = u(idx,:);
% if nz(3)<0
%     nz=-nz;
% end
% ng=-nz;
% while vec3theta(nz,ng)>theta_g
%     [fitresult, gof] = createFitGround(ground_x,ground_y,ground_z);
%     p00 = fitresult.p00;
%     p10 = fitresult.p10;
%     p01 = fitresult.p01;
%     ng = [-p10,-p01,1];
%     len = length(ground_x);
%     if vec3theta(nz,ng)<=theta_g || len < length(ground)/5
%         break; 
%     end
%     
%     next_idx=find(ground_z<mean(ground_z));
% 
%     ground_x = ground_x(next_idx);
%     ground_y = ground_y(next_idx);
%     ground_z = ground_z(next_idx);
%     figure;
%     hold on;
%     plot3(ground_x,ground_y,ground_z,'bs'); 
%     xlabel([num2str(u(5,1)),',',num2str(u(5,2)),',',num2str(u(5,3))]);
%     grid on;
% end
% %%
% len = length(ground_x);
% un=[0,0];
% next_idx=[];
% for i=1:len
%     if (p00+p10*ground_x(i)+p01*ground_y(i)-ground_z(i))>=0
%         un(1)=un(1)+1;
%         next_idx=[next_idx;i];
%     else
%         un(2)=un(2)+1; 
%     end
% end
% 
% ground_x = ground_x(next_idx);
% ground_y = ground_y(next_idx);
% ground_z = ground_z(next_idx);
% figure;
% hold on;
% plot3(ground_x,ground_y,ground_z,'bs');
% xlabel([num2str(u(5,1)),',',num2str(u(5,2)),',',num2str(u(5,3))]);
% grid on;
% 
% [fitresult, gof] = createFitGround(ground_x,ground_y,ground_z);
% p00 = fitresult.p00;
% p10 = fitresult.p10;
% p01 = fitresult.p01;
% ng = [-p10,-p01,1];
% len = length(ground_x);
%  vec3theta(nz,ng)