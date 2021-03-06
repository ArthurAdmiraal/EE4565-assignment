% get_fir_envelope_deconvolution(t_ns, signal, t_ns_cal, calibration_signal, normalise=true)
function [t, reflections] = get_fir_envelope_deconvolution(t_ns, signal, t_ns_cal, calibration_signal, varargin)
  f_mod = 3.014;
  
  ts = mean(diff(t_ns));
  
  n2 = 81;
  d2 = (n2-1)/2;
  Wn = f_mod * ts;
  b  = fir1(n2,Wn);
  
  % get complex envelopes - quadrature mix and filter
  signal_envelope      = signal            .*cos(2*pi*f_mod*t_ns)     + 1j*signal            .*sin(2*pi*f_mod*t_ns);
  calibration_envelope = calibration_signal.*cos(2*pi*f_mod*t_ns_cal) + 1j*calibration_signal.*sin(2*pi*f_mod*t_ns_cal);

  signal_envelope      = filter(b, 1, signal_envelope);
  calibration_envelope = filter(b, 1, calibration_envelope);
  
  % deconvolve based on complex envelopes
  n1 = length(calibration_envelope);
  d1 = floor((n1-1)/2);
  [h,err] = analysis.spike(calibration_envelope,d1,n1);
  
  reflections = abs(filter(h,1,signal_envelope));
  
  % normalise if desired
  if (nargin>0 && varargin{1}) || (nargin==0)
    reflections = reflections / max(reflections);
  end

  ts    = mean(diff(t_ns));
  t     = t_ns - ts*(d2+d1);
  
  % correct for mistaken pulse start
  [M,I] = max(reflections);
  t     = t     - t(I);
end