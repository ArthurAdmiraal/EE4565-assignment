% from hayes page 573
function X = convm(x,p)
  % this function sets up a convolution matrix
  N = length(x)+2*p-2;
  x = x(:);
  xpad = [zeros(p-1,1);x;zeros(p-1,1)];
  for i=1:p
    X(:,i)=xpad(p-i+1:N-i+1);
  end
end