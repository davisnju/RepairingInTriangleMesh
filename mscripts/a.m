%%
clear
clc
load m.mat

% 聚类分析
%k-means聚类
data = normals;
[u re]=KMeans(data,5);  
[m n]=size(re);

%最后显示聚类后的法向量数据
figure;
hold on;
for i=1:m 
    if re(i,4)==1   
         plot3(re(i,1),re(i,2),re(i,3),'ro'); 
    elseif re(i,4)==2
         plot3(re(i,1),re(i,2),re(i,3),'go'); 
    elseif re(i,4)==3
         plot3(re(i,1),re(i,2),re(i,3),'bo'); 
    elseif re(i,4)==4
         plot3(re(i,1),re(i,2),re(i,3),'yo'); 
    else 
         plot3(re(i,1),re(i,2),re(i,3),'ms'); 
    end
end
grid on;
%%
l = re(:,4);
figure;
hist(l,5);
%%
Z_AXIS = [0,0,1];
Y_AXIS = [0,1,0];
X_AXIS = [1,0,0];

theta_e = 0.2;
theta_z = [0.,0.,0.,0.,0.];
for i=1:length(u)
    theta_z(i) = vec3theta(u(i,:),Z_AXIS);
end
[~,idx]=min(theta_z(:));

%%
%聚类中心法向量
figure;
hold on;
for i=1:length(u)   
    q = quiver3(0,0,0,u(i,1),u(i,2),u(i,3),1); 
    if i~=idx
        q.Color = 'm';
    else
        q.Color = 'g';
    end
end

grid on;
%%
%最后显示聚类后的顶点数据
figure;
hold on;
for i=0:1:m - 1 
    if re(i+1,4)==1 && 1~=idx          
        subplot(2,2,1);
        hold on;
         plot3(x([3*i+1:3*i+3,3*i+1]),y([3*i+1:3*i+3,3*i+1]),...
             z([3*i+1:3*i+3,3*i+1]),'r.-'); 
         xlabel([num2str(u(2,1)),',',num2str(u(2,2)),',',num2str(u(2,3))]);
    elseif re(i+1,4)==2 && 2~=idx  
        subplot(2,2,2);
        hold on;
         plot3(x([3*i+1:3*i+3,3*i+1]),y([3*i+1:3*i+3,3*i+1]),...
             z([3*i+1:3*i+3,3*i+1]),'g.-'); 
         xlabel([num2str(u(2,1)),',',num2str(u(2,2)),',',num2str(u(2,3))]);
    elseif re(i+1,4)==3 && 3~=idx  
        subplot(2,2,3);
        hold on;
         plot3(x([3*i+1:3*i+3,3*i+1]),y([3*i+1:3*i+3,3*i+1]),...
             z([3*i+1:3*i+3,3*i+1]),'m.-'); 
         xlabel([num2str(u(3,1)),',',num2str(u(3,2)),',',num2str(u(3,3))]);
    elseif re(i+1,4)==4 && 4~=idx  
        subplot(2,2,4);
        hold on;
         plot3(x([3*i+1:3*i+3,3*i+1]),y([3*i+1:3*i+3,3*i+1]),...
             z([3*i+1:3*i+3,3*i+1]),'c.-'); 
         xlabel([num2str(u(4,1)),',',num2str(u(4,2)),',',num2str(u(4,3))]);
    elseif  5~=idx  
        hold on;
         plot3(x([3*i+1:3*i+3,3*i+1]),y([3*i+1:3*i+3,3*i+1]),...
             z([3*i+1:3*i+3,3*i+1]),'bs-'); 
         xlabel([num2str(u(5,1)),',',num2str(u(5,2)),',',num2str(u(5,3))]);
    end
end
grid on;


 
 