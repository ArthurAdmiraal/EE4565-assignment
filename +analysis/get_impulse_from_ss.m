function [t, amplitude] = get_impulse_from_ss(f, spectrum)
  n         = length(f);
  ts        = 1/(n*mean(diff(f)));
  amplitude = fft(spectrum);

  t         = ts * (0:n/2-1);
  amplitude = amplitude(1:n/2);
end