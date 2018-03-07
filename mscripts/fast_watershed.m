function [L] = fast_watershed(n,H,A)
% fast_watershed - fast watershed
%   [L] = fast_watershed(n,H,A)
%   n is num of vertexes
%   H is an curvature array of vertexex,
%     one may use Gauss,total,C_rms,C_abs,Cmin,Cmax
%   A is adjacent list of each vertex, cell(n,1)->array(num_of_nb)
%
%   L is label for each vertex
%
%   The algorithm is detailed in
%       L Vincent and Soille P.
%       watersheds in digital spaces
%       - an efficient algorithm based on immersion simulations.
%       IEEE Transactions on Pattern Analysis & Machine Intelligence, 1991,
%       13(6): 583-598.
%
%   Copyright (c) 2018 Wei Dai

import java.util.*;
MASK = int32(-2);   % inital value of a threshhold level
WASHED = int32(0);  % value of the pixels belonging to the watershed
INIT = int32(-1);   % initial value of label_out

lab = zeros(n,1, 'int32');
dist = zeros(n,1, 'int32');

lab(1:n)=INIT;

fictitious = int32(-3);
curlab = int32(0);

Hn = uniquetol(H);  % uses a default tolerance of 1e-6 for single-precision inputs and 1e-12 for double-precision inputs
Hn = sort(Hn);
Hn_len = length(Hn);

fifo = LinkedList();

for hi=1:Hn_len
    h=Hn(hi);
    for i=1:n
        if float_eq(H(i), h, 1e-12)
            lab(i)=MASK;
            
            % Traversing all the neighbors of vi
            nni=length(A{i});
            for j=1:nni
                lij=lab(A{i}(j));
                if lij > 0 || lij == WASHED
                    dist(i)=int32(1);
                    fifo.add(i);
                    break;
                end
            end
        end
    end    
    
    curdist=int32(1);
    fifo.add(fictitious);    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% while 1 %%%%%%%%%%%%%%%%%%%%%%
    k=0;
    while 1
        k = k + 1;
        p=fifo.remove();
        
        if p==fictitious
            if fifo.size == 0
                break
            else
                fifo.add(fictitious);
                curdist = curdist + 1;
                p=fifo.remove();
            end
        end
        
        % Traversing all the neighbors (pj) of p
        nnp=length(A{p});
        lp=lab(p);
        for j=1:nnp
            pj=A{p}(j);
            lpj=lab(pj);
            dpj=dist(pj);
            if dpj < curdist && (lpj > 0 || lpj == WASHED)
                if lpj > 0 
                    if lp == MASK || lp == WASHED
                        lab(p) = lpj;
                    elseif lp ~= lpj
                        lab(p) = WASHED;
                    else
                    end
                elseif lp == MASK
                    lab(p) = WASHED;
                else
                end
            elseif lpj == MASK && dpj == 0
                dist(pj)=curdist + 1;
                fifo.add(pj);
            else
            end
        end            
    end
    
    %%%%%%%%%%%%%%%%%% checks if new minima have been discovered %%%%%%
    for p=1:n
        if float_eq(H(p), h, 1e-12)
            dist(p)=0;
            if lab(p) == MASK
                curlab = curlab + 1;
                fifo.add(p);
                lab(p)=curlab;
                while fifo.size ~= 0
                    q=fifo.remove();                    
                    % Traversing all the neighbors (qj) of q
                    nnq=length(A{q});
                    for j=1:nnq
                        qj=A{q}(j);
                        if lab(qj)==MASK
                            fifo.add(qj);
                            lab(qj)=curlab;
                        end
                    end
                end
            end
        end
    end
end

L=lab;
end