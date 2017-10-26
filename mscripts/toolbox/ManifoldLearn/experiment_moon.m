function [X,Y1]=experiment_moon(X,Y,XT,YT,method,q,s);

% 2 Moons Experiment
% Author: Vikas Sindhwani (vikass@cs.uchicago.edu)

options=ml_options('gamma_A',0.1, 'NN',6, 'Kernel','rbf','KernelParam',0.35);

 
%q=-1:5;
if nargin==6 % perform a search over lambda1 and lambda2
    lambda1=2.^q;
    lambda2=2.^q;
else % interpret q as lambda1 and s as lambda2

    lambda1=q;
    lambda2=s;
    
end

% best SVM
min_err=100;

if strcmp(method,'svm') | strcmp(method,'tsvm')  strcmp(method,'rlsc') 
% optimize over just 1 parameter
for i=1:length(q)
    options.gamma_A=lambda1(i);
    options.gamma_I=0;
    classifier=ml_train(X,Y,options, method);
    [f,labels,error]=ml_test(classifier,XT,YT);
    [lambda1(i) error min_err]
    if error < min_err
         min_err=error;
         best_classifier=classifier;
    end
    
end

   

else % optimize over both
    
   for i=1:length(q)
      for j=1:length(q)
            options.gamma_A=lambda1(i);
            options.gamma_I=lambda2(j);
            classifier=ml_train(X,Y,options, method);
            [f,labels,error]=ml_test(classifier,XT,YT);
            [lambda1(i) error min_err]
    if error < min_err
         min_err=error;
         best_classifier=classifier;
    end
end 
end

end
lab=find(Y); 
xmin=min(X(:,1)); ymin=min(X(:,2)); rmin=min(xmin,ymin)-0.2;
xmax=max(X(:,1)); ymax=max(X(:,2)); rmax=max(xmax,ymax)+0.2;
steps=(rmax-rmin)/100;
xrange=rmin:steps:rmax;
yrange=rmin:steps:rmax;
plotclassifiers(best_classifier, xrange, yrange); 

    
  
    
    




% i=0; j=0; 
% 
% for lgl2=1:nq
%  i=i+1; j=0;
%  
%     for lgl1=1:nq
%  j=j+1;
%  p=p+1;       
% options.lambda1=10^(q(lgl1)); 
% options.lambda2=10^(q(lgl2)); 
% classifier=Train(X,Y1,options,method);
% [fT,labels,error_rate]=Test(classifier, XT,YT);
% subplot(nq,nq,p); plotclassifiers(XT,YT,classifier);plot2D(X(lab,:),Y(lab),6);
% e(i,j)=error_rate;
% 
% end
% end
