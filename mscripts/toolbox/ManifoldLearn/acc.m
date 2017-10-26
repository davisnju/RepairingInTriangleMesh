% Returns accuracy.  Intended to be used with breakeven.m
%
% Written by Jason Rennie <jrennie@csail.mit.edu>
% Last modified: Thu Feb 19 13:18:03 2004

function [obj] = accuracy(np,nn,fp,fn)
  obj = (np+nn-fp-fn)./(np+nn);
