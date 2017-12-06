% Returns harmonic mean of accuracy rate on positive examples (recall)
% and accuracy rate on negative examples.  Intended to be used with
% breakeven.m
%
% Written by Jason Rennie <jrennie@csail.mit.edu>
% Last modified: Thu Feb 19 13:18:34 2004

function [obj] = r1(np,nn,fp,fn)
  nrate = (nn-fp)/nn;
  prate = (np-fn)/np;
  obj = 2*nrate*prate/(nrate+prate);
