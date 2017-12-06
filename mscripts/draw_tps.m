function draw_tps(vertex_set,tps)
%draw_tps(vertex_set,tps)
% vertex_set
% tps  table
n=height(tps);
figure;
hold on;
for i=1:n    
    v=[vertex_set(tps.v1(i),:);
       vertex_set(tps.v2(i),:);
       vertex_set(tps.v3(i),:)];
    plot3(v([1:end,1],1),v([1:end,1],2),v([1:end,1],3),'.-'); 
end
grid on;
end