function classifier=ml_train(X,Y,options, method)

% ML_TRAIN Trains a classifier with some "options" using some "method"
% --------------------------------------------------------------------------------%
% Usage:
% classifier=ml_train(X,Y,options, method)
% 
% Input:
% X : n x d matrix (n examples of dimension d)
% Y : n x 1 column vector of labels for each example
%     Entries of Y can be -1 (negative example) +1 (positive example or
%     0 (unlabeled example). 
%
% options: Options structure returned by ml_options with suitable
%          parameter settings. type help ml_options
% method : 'svm', 'lapsvm', 'rlsc' , 'laprlsc'
% Note: For multiple runs, it might be better to run TSVM using the shell
%       script 'runtsvm' otherwise this code might be uselessly writing and
%       and reading stuff from the disk
%
%
% Output:
%    classifier: A structure containing details of a classifier
%
%    classifier.Name=name; -- string containing name of the classifier
%    classifier.Kernel=kerneltype; % type of kernel used  (i.e 'linear' etc)
%    classifier.KernelParam=kernelparam; -- parameters of the kernel
%    classifier.alpha=alpha; -- expansion coefficients
%    classifier.b=b;   -- bias
%    classifier.xtrain=xtrain; -- expansion vectors correponding to the alphas
%    classifier.gammas=[gamma_A gamma_I] -- regularization parameters used for training
%
%    Author: Vikas Sindhwani (vikass@cs.uchicago.edu)
%    June 2004
% --------------------------------------------------------------------------------%
n=length(Y);
l=length(find(Y));
u=n-l;
lab=find(Y);


if l==0 | strcmp(method,'clustering')% unsupervised case
    K=calckernel(options.Kernel,options.KernelParam,X);
    I=eye(size(K,1));
    L=laplacian(X,'nn',options);
    G=(options.gamma_A*I + options.gamma_I*L*K);
    [V,E]=eigs(G,K,6,'sm');
    ind=find(abs(diag(E))==0);
    alpha=V(:,2);
    classifier= ...
       saveclassifier('clustering',options.Kernel,options.KernelParam, ...
       alpha,X,0,[options.gamma_A options.gamma_I]);
    result=0;
    return;
end


switch method
    
case 'svm'
   K=calckernel(options.Kernel,options.KernelParam,X(lab,:));
   [alpha,b,svs]=svm(K,Y(lab),options.gamma_A);
   Xlab=X(lab,:);
   classifier= ...
       saveclassifier('svm',options.Kernel,options.KernelParam, ...
       alpha(svs+1),Xlab(svs+1,:),b,[options.gamma_A 0]);
   
case 'tsvm' % use with Antons code
    classifier=tsvm(X,Y,options.Kernel,options.KernelParam,options.gamma_A);
   
case 'lapsvm'
   K=calckernel(options.Kernel,options.KernelParam,X);
   if options.gamma_I~=0
       
        if u~=0
    % semi-supervised case   
            L=laplacian(X,'nn',options);
    % fully supervised case    
        else
            pos=find(Y==1); neg=find(Y==-1);
            L1=laplacian(X(pos,:),'nn',options);
            L2=laplacian(X(neg,:),'nn',options);
            L=zeros(n);
            L(pos,pos)=L1; L(neg,neg)=L2;
        end
      
        
    else
        L=[];
   end
   [alpha,b]=lapsvm(K,Y,L,options.gamma_A,options.gamma_I);
   classifier= ...
        saveclassifier('lapsvm',options.Kernel,options.KernelParam, ...
        alpha,X,b,[options.gamma_A options.gamma_I]);
    
case 'rlsc'
    K=calckernel(options.Kernel,options.KernelParam,X(lab,:));
    [alpha,b]=rlsc(K,Y(lab),options.gamma_A);
    classifier= ...
       saveclassifier('rlsc',options.Kernel,options.KernelParam,alpha,...
                        X(lab,:),b,[options.gamma_A 0]);
   
case 'laprlsc'
    
    K=calckernel(options.Kernel,options.KernelParam,X);
   if options.gamma_I~=0
       
       if u~=0
    % semi-supervised case   
            L=laplacian(X,'nn',options);
    % fully supervised case    
        else
            pos=find(Y==1); neg=find(Y==-1);
            L1=laplacian(X(pos,:),'nn',options);
            L2=laplacian(X(neg,:),'nn',options);
            L=zeros(n);
            L(pos,pos)=L1; L(neg,neg)=L2;
        end
       
       
       
   else
        L=[];
   end
  
  
   
   [alpha,b]=laprlsc(K,Y,L,options.gamma_A,options.gamma_I);
   classifier= ...
        saveclassifier('laprlsc',options.Kernel,options.KernelParam, ...
        alpha,X,b,[options.gamma_A options.gamma_I]);
        
end
        
        