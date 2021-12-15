function [t, amplitude] = get_impulse(f, spectrum)
  n         = length(f);
  ts        = 1/(n*mean(diff(f)));
  amplitude = ifft(ifftshift(spectrum));
  t         = ts * (0:n-1);
end