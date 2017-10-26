function [alpha,b,svs]=svm(K,Y,lambda)
% SVM Support Vector Machines Training Routine
% [alpha,b,svs]=svm(K,Y,Kernel,KernelParam,C)
% 
% Inputs: 
% K : A gram matrix
% Y corresponding labels [-1,+1] column vector
% Kernel = 'linear' | 'poly' | 'rbf'
% KernelParam = 0 | degree | gamma
% C : SVM C parameter
%
% Outputs:
%
% alpha : expansion coefficients (column vector)
% b     : bias term
% svs   : indices to support vectors (not support vectors themselves !)
%
%  Author:  Vikas Sindhwani vikass@cs.uchicago.edu
%          SSlearn : Semi Supervised Learning Toolbox
%          May 2004
%------------------------------------------------------------------------------%

C=1/(2*lambda);
parameters =  [4 1 1 0 C 40.00 0.001 0 0.5 0.1 1] ;
% map Y : 1--> 1 0-->2


[alpha, svs, b, nsv, nlab] = mexGramSVMTrain(K', Y', parameters);
alpha=alpha';

% libsvm does some weird label switching
if nlab(1)==-1
    alpha=-alpha;
end
a=zeros(length(Y),1);
a(svs+1)=alpha;
alpha=a;


