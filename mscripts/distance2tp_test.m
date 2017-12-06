% distance2tp test OK!

test1=distance2tp([0,0,0],[1,2,1;1,4,1;2,2,1]);
assert(float_eq(test1,norm([1,2,1]),0.000001));

test1=distance2tp([1,2,0],[1,2,1;1,4,1;2,2,1]);
assert(test1==1);


bb=[];
for x=-14:0.1:14
    for y=-14:0.1:14
        z=distance2tp([x,y,0],[0,8,0;-sqrt(3)*4,-4,0;sqrt(3)*4,-4,0]);
        bb=[bb;x,y,z];
    end
end
xx = linspace(min(bb(:,1)),max(bb(:,1)),64);
yy = linspace(min(bb(:,2)),max(bb(:,2)),64);
yy = yy';
for jj = 1:64
    xx(jj,:) = xx(1,:);
end
for jj = 1:64
    yy(:,jj) = yy(:,1);
end
zz = griddata(bb(:,1),bb(:,2),bb(:,3),xx,yy);
figure;
contourf(xx,yy,zz,20);
hold on
plot([0 -sqrt(3)*4 sqrt(3)*4 0],[8 -4 -4 8],'r-');



%%

%2d for display
clc;
X=[0,8,0;-sqrt(3)*4,-4,0;sqrt(3)*4,-4,0];
A=X(1,:);
B=X(2,:);
C=X(3,:);
bb=[];
for x=-14:0.1:14
    for y=-14:0.1:14
        z=distance2tp2d([x,y,0],X);
        bb=[bb;x,y,z];
    end
end
xx = linspace(min(bb(:,1)),max(bb(:,1)),64);
yy = linspace(min(bb(:,2)),max(bb(:,2)),64);
yy = yy';
for jj = 1:64
    xx(jj,:) = xx(1,:);
end
for jj = 1:64
    yy(:,jj) = yy(:,1);
end
zz = griddata(bb(:,1),bb(:,2),bb(:,3),xx,yy);
%%
figure;
contourf(xx,yy,zz,20,'lines','no');
hold on
plot([0 -sqrt(3)*4 sqrt(3)*4 0],[8 -4 -4 8],'r-');



