function classifier=saveclassifier(name,kerneltype,kernelparam,alpha,xtrain,b,lambda)

% SAVECLASSIFIER Generates a classifier structure containg details of a classifier
% ----------------------------------------------------------------------------------%
% Usage:
% classifier=saveclassifier(name,kerneltype,kernelparam,alpha,xtrain,bias,lambda)
%
% The classifier structure is as follows:
% 
% classifier.Name=name;  -- name of the classifier
% classifier.Kernel=kerneltype; -- name of the kernel
% classifier.KernelParam=kernelparam; -- parameters of the kernel
% classifier.alpha=alpha; -- expansion coefficients
% classifier.b=b; -- bias
% classifier.xtrain=xtrain; -- vectors correponding to the coefficients
% classifier.gammas=lambda; -- the regularization parameters 
%  Here, lambda = [gamma_A gamma_I]
%
%  Author: Vikas Sindhwani (vikass@cs.uchicago.edu)
%  June 2004
% -----------------------------------------------------------------------------------% 

classifier.Name=name;
classifier.Kernel=kerneltype;
classifier.KernelParam=kernelparam;
classifier.alpha=alpha;
classifier.b=b;
classifier.xtrain=xtrain;
classifier.gammas=lambda;