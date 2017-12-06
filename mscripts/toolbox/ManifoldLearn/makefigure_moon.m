function makefigure_moon

% 2 Moons Figure
% For TSVM, uncomment some lines below after correctly installing
% SVM Light and a matlab interface to it
% See http://www.cis.tugraz.at/igi/aschwaig/software.html
% Also, you can uncomment some lines to make this code search for best 
% parameters.
%
% Author: Vikas Sindhwani (vikass@cs.uchicago.edu)

load 2moons.mat;

l=1; % number of labeled examples

pos=find(y==1);
neg=find(y==-1);
ipos=randperm(length(pos));
ineg=randperm(length(neg));
y1=zeros(length(y),1);
y1(pos(ipos(1:l)))=1;
y1(neg(ineg(1:l)))=-1;

% can run a search over best parameters below

% earlier version
% subplot(2,3,1); plot2D(x,y1,12);axis([-1.5 2.5 -1.5 2.5]);
% subplot(2,3,2); decision_surface(x,y1,xt,yt,'svm',-5:0); hold on;
%                 plot2D(x,y1,12);
% subplot(2,3,3); decision_surface(x,y1,xt,yt,'rlsc',-5:0);
%                 hold on;  plot2D(x,y1,10);
% subplot(2,3,4); decision_surface(x,y1,xt,yt,'tsvm',-5:0);
%                 hold on;  plot2D(x,y1,10);
% subplot(2,3,5); decision_surface(x,y1,xt,yt,'lapsvm',[-5:0]);
%                 hold on;  plot2D(x,y1,10);
% subplot(2,3,6); decision_surface(x,y1,xt,yt,'laprlsc',[-5:0]);
%                  hold on;  plot2D(x,y1,10);

                 % new version
 %subplot(1,3,1); plot2D(x,y1,12);axis([-1.5 2.5 -1.5 2.5]);
subplot(2,3,1); experiment_moon(x,y1,xt,yt,'svm',0.03125,0); hold on;
                plot2D(x,y1,12);
%subplot(2,3,3); decision_surface(x,y1,xt,yt,'rlsc',-5:0);
 %               hold on;  plot2D(x,y1,10);
 
 warning('For TSVM, Install SVMLight and a matlab interface to it. See http://www.cis.tugraz.at/igi/aschwaig/software.html');
 % Use below with Antons's code 
%subplot(2,3,2); experiment_moon(x,y1,xt,yt,'tsvm',0.125,0);
 %               hold on;  plot2D(x,y1,10);

                
                subplot(2,3,2); experiment_moon(x,y1,xt,yt,'lapsvm',0.03125,1);
                hold on;  plot2D(x,y1,10);
%subplot(2,3,6); decision_surface(x,y1,xt,yt,'laprlsc',[-5:0]);
 %                hold on;  plot2D(x,y1,10);
              
                 