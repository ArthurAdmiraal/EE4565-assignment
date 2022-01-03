% get_fir_deconvolution(t_ns, signal, calibration_signal, normalise=true)
function [t, reflections] = get_fir_deconvolution(t_ns, signal, calibration_signal, varargin)
  n1 = length(calibration_signal);
  d1 = floor((n1-1)/2);
  [h,err] = analysis.spike(calibration_signal,d1,n1);
  
  y = filter(h,1,signal);

  n2 = 81;
  d2 = (n2-1)/2;
  Wn = 0.2;
  b  = fir1(n2,Wn);
  
  reflections = filter(b, 1, abs(y));
  
  if (nargin>0 && varargin{1}) || (nargin==0)
    reflections = reflections / max(reflections);
  end

  ts = mean(diff(t_ns));
  t  = t_ns - ts*(d2+d1);
end