% from Hayes page 172
function [h,err] = spike(g,n0,n)
  g = g(:);
  m = length(g);
  if m+n-1<=n0, error('Delay too large'), end
  G = analysis.convm(g,n);
  d = zeros(m+n-1,1);
  d(n0+1) = 1;
  h = G\d;
  err = 1 - G(n0+1,:)*h;
end