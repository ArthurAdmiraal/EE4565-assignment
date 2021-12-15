function [f, spectrum] = get_spectrum(t_ns, signal)
  n        = length(t_ns);
  fs       = 1/mean(diff(t_ns));
  f        = (-n/2:n/2-1)*(fs/n);     % zero-centered frequency range
  spectrum = fftshift(fft(signal),1);
  %spectrum = abs(spectrum).^2/n;      % zero-centered power
end