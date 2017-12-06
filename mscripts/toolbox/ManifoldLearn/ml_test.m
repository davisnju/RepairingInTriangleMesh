function [f,labels,error]=ml_test(classifier,X,Y)

% ML_TEST Uses a classifier to classify data in X
% ----------------------------------------------------------------------------%
%
% Usage: 
% [f,labels,error]=ml_test(classifier,X,Y)
%
% Inputs:
% classifier: A classifier structure returned by ml_train or saveclassifier
% X : n x d matrix (n examples in d dimensions)
% Y : optional column vector of labels. Values in -1,0,+1 
%     If Y is provided, computes error rates 
%     Note:  Y is allowd to be in [-1,0,+1]
%            The error computation is done over labeled points [-1,+1]
% 
% Outputs: 
% f : real valued classifier output
% labels: f thresholded at b 
% error: error rate over labeled part of Y
% 
% Author:  Vikas Sindhwani vikass@cs.uchicago.edu
%          June 2004
%------------------------------------------------------------------------------%


% read classifier
Kernel=classifier.Kernel;
KernelParam=classifier.KernelParam;
alpha=classifier.alpha;
b=classifier.b;
xtrain=classifier.xtrain;

% compute test kernel
K=calckernel(Kernel,KernelParam,xtrain,X);
f=K*alpha - b;
labels=sign(f);

% compute error rate over labeled part of test set
if exist('Y','var')==1
    test=find(Y);
    error=sum(labels(test)~=Y(test))/length(test)*100;
end

