function [r]=on_surface(face,K)
r=isempty( intersect(face,K,'rows') );
r=~r;
end