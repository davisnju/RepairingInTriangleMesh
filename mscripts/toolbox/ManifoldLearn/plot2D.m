function plot_data(X,Y,markersize)

% plot2D(X,Y)
% plots a binary classification dataset of 2 dimensions 

pos=find(Y==1);
neg=find(Y==-1);
unlab=find(Y==0);

%if ~isempty(unlab)
plot(X(unlab,1),X(unlab,2),'ks'); hold on;     
plot(X(pos,1),X(pos,2),'rd','MarkerSize',markersize,'MarkerFaceColor','r','MarkerEdgeColor','k'); hold on;
plot(X(neg,1),X(neg,2),'bo' ,'MarkerSize',markersize,'MarkerFaceColor','b','MarkerEdgeColor','k'); hold on;
%legend('class +1 ','class -1', 'unlabeled');

%else
 %  plot(X(pos,1),X(pos,2),'rd'); hold on;
  % plot(X(neg,1),X(neg,2),'bo'); hold on; 
   % legend('class +1', 'class -1');
   %end