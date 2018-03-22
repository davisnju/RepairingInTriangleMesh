DT = delaunayTriangulation(profile);
fe = freeBoundary(DT)';
figure(1);
subplot(2,2,1)
hold off;
triplot(DT);
hold on;
% plot(profile(fe,1),profile(fe,2),'-g','LineWidth',2) ; 
% hold off;
axis equal  
axis([-8 8 -6 6]);
vertex=DT.Points;
nv=size(vertex,1);
face=DT.ConnectivityList(:, :);
fn=size(face,1);
inside=ones(fn,1);
% idx=[];
% for i=1:nv
%     
% end

ti = vertexAttachments(DT,66);
inside(ti{1})=0;
ti = vertexAttachments(DT,64);
inside(ti{1})=0;
ti = vertexAttachments(DT,67);
inside(ti{1})=0;
ti = vertexAttachments(DT,61);
inside(ti{1})=0;
ti = vertexAttachments(DT,70);
inside(ti{1})=0;

subplot(2,2,2)
hold off
triplot(face(inside==1, :),vertex(:,1),vertex(:,2))  
axis equal  
axis([-8 8 -6 6]);

fn=size(face,1);
E = edges(DT);
BEidx=[];
en=size(E,1);
for i=1:en
    ti = edgeAttachments(DT,E(i,1),E(i,2));
    if length(ti{1})==2 && sum(inside(ti{1})) == 1
        BEidx=[BEidx;E(i,:)];
    end
end
hold on
BVn=size(BEidx,1);
for i=1:BVn
plot(vertex(BEidx(i,:),1),vertex(BEidx(i,:),2),'-r','LineWidth',2) ; 
end
plot(profile(fe,1),profile(fe,2),'-g','LineWidth',2) ; 


ti = vertexAttachments(DT,6);
inside(ti{1})=0;



subplot(2,2,4)
hold off
triplot(face(inside==1, :),vertex(:,1),vertex(:,2))  
axis equal  
axis([-8 8 -6 6]);

fn=size(face,1);
E = edges(DT);
BEidx=[];
en=size(E,1);
for i=1:en
    ti = edgeAttachments(DT,E(i,1),E(i,2));
    if length(ti{1})==2 && sum(inside(ti{1})) == 1
        BEidx=[BEidx;E(i,:)];
    end
end
hold on
border_label=ones(size(BEidx,1),1);

queueE=BEidx;
e=queueE(1,:);
queueE=queueE(2:end,:);
listE=e;
listHole=cell(0,0);
while size(queueE,1)>0
    idx=intersect(find(BEidx(:,1)==e(2)),find(BEidx(:,2)==e(2)));
    if length(idx)==0
        [rc,listE,listHole]=check_edge(listE,listHole);
        if rc<0
            disp('error');
            break;
        end
    else
        e2=BEidx(idx(1),:);
        e=e2;
        if length(idx)==1
            [~,id,~]=intersect(queueE,e2,'rows');
            queueE(id,:)=[];
        end
        listE=[listE;e];
    end
end
[rc,listE,listHole]=check_edge(listE,listHole);
if rc<0
    disp('error');
end


color=['r','y','b','y','m','c','w','k'];
border_label([1 2 6 7 ])=2;
for i=1:size(BEidx,1)
    plot(vertex(BEidx(i,:),1),vertex(BEidx(i,:),2), ...
            color(border_label(i)),'LineWidth',2)
end

% for i=1:size(BEidx,1)
%     vidx=BEidx(i,:);
%     plot(vertex(BEidx(i,:),1),vertex(BEidx(i,:),2),'-r','LineWidth',2) ;
% end
plot(profile(fe,1),profile(fe,2),'-g','LineWidth',2) ; 

subplot(2,2,3)
hold off
triplot(face(inside==1, :),vertex(:,1),vertex(:,2))  
hold on
axis equal  
axis([-8 8 -6 6]);
border_label([1 2 6 7 ])=3;
width=ones(size(border_label))*2;
width([1 2 6 7 ])=1;
for i=1:size(BEidx,1)
    plot(vertex(BEidx(i,:),1),vertex(BEidx(i,:),2), ...
            color(border_label(i)),'LineWidth',width(i))
end
plot(profile(fe,1),profile(fe,2),'-g','LineWidth',2) ; 

