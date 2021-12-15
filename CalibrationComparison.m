close all;
clear all;

%% get calibration signal, direct path
calibration_file_name = 'mulyipath_full_011.csv';
cal_start = -1.922;
cal_stop  =  2.169;

[t_ns, signal] = getMeasurement(calibration_file_name);

calibration_signal = signal;

[M, start_sample] = min(abs(t_ns - cal_start));
[M, stop_sample]  = min(abs(t_ns - cal_stop));

calibration_signal(1:start_sample)  = 0;
calibration_signal(stop_sample:end) = 0;

figure;
hold on;
plot(t_ns, signal);
plot(t_ns, calibration_signal);
legend('Raw', 'Calibration pulse')

xlabel('t (ns)');
ylabel('y');
title('Calibration signal (direct path)');

[f, cal_spectrum] = getSpectrum(t_ns, calibration_signal);

figure;
plot(f, 20*log(abs(cal_spectrum)), 'Color', [0.8500 0.3250 0.0980]);
xlabel('f (GHz)');
ylabel('Y (dB)');
title('Calibration signal spectrum (direct path)');

%% get calibration signal, only reflected pulse
calibration_file_name = 'mulyipath_nodirect_012.csv';
cal_start = -1.25;
cal_stop  =  1.25;

[t_ns, signal] = getMeasurement(calibration_file_name);

calibration_signal = signal;

[M, start_sample] = min(abs(t_ns - cal_start));
[M, stop_sample]  = min(abs(t_ns - cal_stop));

calibration_signal(1:start_sample)  = 0;
calibration_signal(stop_sample:end) = 0;

figure;
hold on;
plot(t_ns, signal);
plot(t_ns, calibration_signal);
legend('Raw', 'Calibration pulse')

xlabel('t (ns)');
ylabel('y');
title('Calibration signal (reflection)');

[f, cal_spectrum] = getSpectrum(t_ns, calibration_signal);

figure;
plot(f, 20*log(abs(cal_spectrum)), 'Color', [0.8500 0.3250 0.0980]);
xlabel('f (GHz)');
ylabel('Y (dB)');
title('Calibration signal spectrum (reflection)');

%% functions
function [f, spectrum] = getSpectrum(t_ns, signal)
  n        = length(t_ns);
  fs       = 1/mean(diff(t_ns));
  f        = (-n/2:n/2-1)*(fs/n);     % zero-centered frequency range
  spectrum = fftshift(fft(signal),1);
  %spectrum = abs(spectrum).^2/n;      % zero-centered power
end

function [t, amplitude] = getImpulse(f, spectrum)
  n         = length(f);
  ts        = 1/(n*mean(diff(f)));
  amplitude = ifft(ifftshift(spectrum));
  t         = ts * (0:n-1);
end

function [t, amplitude] = getImpulseFromSS(f, spectrum)
  n         = length(f);
  ts        = 1/(n*mean(diff(f)));
  amplitude = fft(spectrum);

  t         = ts * (0:n/2-1);
  amplitude = amplitude(1:n/2);
end

function [t_ns, signal] = getMeasurement(file_name)
  [cnfg, scn] = my_read_cat_log('Data', file_name);
  data = extractDataFrames(scn);
  data = alignDataFrames(data);
  data = discardOutliers(data, 0.25);
  data = getAverage(data);
  
  t_ns   = linspace(cnfg.ScnStrt_ps,cnfg.ScnStp_ps,length(data))/1000;
  signal = data;
end

function data = extractDataFrames(scn)
  data = [scn.scndata];
  
  scn_size = size(scn);
  scn_len  = scn_size(end);

  data = [];

  idx = 1;
  for i = 1:scn_len
    if scn(1,i).ChRise
      data(idx,:) = scn(1,i).scndata;
      idx = idx + 1;
    end
  end
end

function data_out = alignDataFrames(data_in)
  data_len = size(data_in);
  data_len = data_len(1);

  max_shift = 0;
  
  data_out(1,:) = data_in(1,:);
  for i = 2:data_len
    [r, lags]  = xcorr(data_in(1,:), data_in(i,:));
    [M,I]      = max(r);
    to_shift   = lags(I);
    max_shift  = max(abs(to_shift), max_shift);
    
    data_out(i, :) = circshift(data_in(i,:), to_shift);
    
    data_out(i, 1:max_shift)       = 0;
    data_out(i, end-max_shift:end) = 0;
  end
end

function variance = getDataVariance(data)
  variance = sum(var(data));
end

function num_frames = getNumFrames(data_in)
  num_frames = size(data_in);
  num_frames = num_frames(1);
end

function data_out = discardMostOutlier(data_in)
  num_frames = getNumFrames(data_in);
  
  variances = [];
  for i = 1:num_frames
    variance = getDataVariance(data_in(1:num_frames ~= i, :));
    variances = [variances, variance];
  end
  
  [M, I] = min(variances);
  data_out = data_in(1:num_frames ~= I, :);
end

function data_out = discardOutliers(data_in, p)
  num_frames = getNumFrames(data_in);

  amount_to_discard = floor(p*num_frames/2);
  
  data_out = data_in;
  for i = 1:amount_to_discard
    data_out = discardMostOutlier(data_out);
  end
end

function data_out = getAverage(data_in)
  data_out = mean(data_in, 1);
end