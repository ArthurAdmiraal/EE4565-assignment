function [t_ns, calibration_signal] = get_calibration_signal(file_name,time_range,varargin)
  % parsing of length mode
  expectedLengths = {'full','nonzero'};
  defaultLength = expectedLengths(1);
  
  p = inputParser;
  addParameter(p,'length',defaultLength,...
               @(x) any(validatestring(x,expectedLengths)));
  parse(p,varargin{:});

  % interpretation of time range
  time_range = time_range(:);
  
  cal_start = time_range(1);
  cal_stop  = time_range(2);

  % load the calibration signal
  [t_ns, calibration_signal] = import.get_measurement(file_name);

  % cut out only the calibration pulse
  [M, start_sample] = min(abs(t_ns - cal_start));
  [M, stop_sample]  = min(abs(t_ns - cal_stop));

  calibration_signal(1:start_sample-1)  = 0;
  calibration_signal(stop_sample+1:end) = 0;

  % cut out zero parts if length mode is nonzero
  if strcmp(p.Results.length, expectedLengths(2))
    calibration_signal = calibration_signal(start_sample:stop_sample);
    t_ns               = t_ns(start_sample:stop_sample);
  end
end