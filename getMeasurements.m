close all;
clear all;

%% get calibration signal
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
plot(t_ns, signal, t_ns, calibration_signal);

[f, cal_spectrum] = getSpectrum(t_ns, calibration_signal);

figure;
plot(f, 20*log(abs(cal_spectrum)));


threshold = 0.01;
frequency_range = f > 0 & abs(cal_spectrum)/max(abs(cal_spectrum)) > threshold;
f_start_index   = find(frequency_range, 1, 'first');
f_end_index     = find(frequency_range, 1, 'last');

f_start = f(f_start_index);
f_end   = f(f_end_index);

%% data analysis
% descriptions = {'Empty',                           ... % experiment 2) 3 metre without people
%                 'Empty (no direct)',               ... % experiment 5) only reflector blocking path
%                 'Sidewards reflector',             ... % mulyipath_full_011
%                 'Sidewards reflector (no direct)', ... % mulyipath_nodirect_012
%                 'People',                          ... % experiment 3) 3 metre with people
%                 'People (no direct)'                   % experiment 4) people with reflector
%   };
% 
% file_names = {'experiment2_006.csv',        ... % experiment 2) 3 metre without people
%               'experiment5_009.csv',        ... % experiment 5) only reflector blocking path
%               'mulyipath_full_011.csv',     ... % mulyipath_full_011
%               'mulyipath_nodirect_012.csv', ... % mulyipath_nodirect_012
%               'experiment3_007.csv',        ... % experiment 3) 3 metre with people
%               'experiment4_008.csv'             % experiment 4) people with reflector
%   };
% 
% for trialnum = 1:length(file_names) 
%     file_name   = file_names{trialnum};
%     description = descriptions{trialnum};
%     
%     [t_ns, signal] = getMeasurement(file_name);
%     [f, spectrum]  = getSpectrum(t_ns, signal);
% 
%     f        = f(f_start_index:f_end_index);
%     spectrum = spectrum(f_start_index:f_end_index) ./ cal_spectrum(f_start_index:f_end_index);
% 
%     figure;
%     plot(f, abs(spectrum));
%     title(file_name, 'Interpreter', 'none');
% 
%     [t_ns, reflections] = getSpectrum(f, abs(spectrum));
% end 


file_name = 'mulyipath_full_011.csv'

[t_ns, signal] = getMeasurement(file_name);
[f, spectrum]  = getSpectrum(t_ns, signal);

figure;
hold on;
plot(f, 20*log(abs(spectrum)));

spectrum = spectrum ./ cal_spectrum;

figure;
windowed_spectrum = spectrum;
windowed_spectrum(abs(cal_spectrum)/max(abs(cal_spectrum)) < threshold) = 0;
plot(f, abs(windowed_spectrum));
title(['Calibrated spectrum',' ',file_name], 'Interpreter', 'none');

% indices = abs(cal_spectrum)/max(abs(cal_spectrum)) > threshold;
% windowed_spectrum = abs(windowed_spectrum(indices));
% f                 = f(indices);

windowed_spectrum = abs(windowed_spectrum(f_start_index:f_end_index));
f                 = f(f_start_index:f_end_index);
figure;
plot(f, windowed_spectrum);
[t, reflections] = getImpulseFromSS(f, windowed_spectrum);
reflections = reflections / reflections(1);

figure;
plot(t, 20*log(abs(reflections)));
title(['Calibrated impulse response',' ',file_name], 'Interpreter', 'none');

%% data analysis
% data_files = {'experiment1_005.csv', 'experiment2_006.csv', 'experiment3_007.csv', 'experiment4_008.csv', 'experiment5_009.csv', 'experiment6_010.csv'} 
% for trialnum = 1:length(data_files) 
%     file_name = data_files{trialnum};
%     
%     [t_ns, signal] = getMeasurement(file_name);
%     [f, spectrum]  = getSpectrum(t_ns, signal);
% 
%     f        = f(f_start_index:f_end_index);
%     spectrum = spectrum(f_start_index:f_end_index) ./ cal_spectrum(f_start_index:f_end_index);
% 
%     figure;
%     plot(f, abs(spectrum));
%     title(file_name, 'Interpreter', 'none');
% 
%     [t_ns, reflections] = getSpectrum(f, abs(spectrum));
% end 

% figure;
% plot(t_ns, abs(reflections));

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
  
  [M, I] = max(variances);
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

% data_len = size(data);
%   data_len = data_len(1);
% 
%   full_data = data(1,:);
%   max_shift = 0;
%   
%   for i = 2:data_len
%     [r, lags] = xcorr(data(1,:), data(i,:));
%     [M,I]     = max(r);
%     to_shift  = lags(I);
%     max_shift = max(abs(to_shift), max_shift);
%     to_add    = circshift(data(i,:), to_shift);
% 
%     full_data = full_data + to_add;
%   end
%   
%   full_data(1:max_shift)       = 0;
%   full_data(end-max_shift:end) = 0;

% data_files = {'Standing','Walking'} 
% for trialnum = 1:length(trials) 
%     trial = trials{trialnum} 
%     eval(['acc_' trial '= data.sub.(trial).acceleration']) 
% end 

% figure;
%plot(full_data)
% for i = 1:data_len
%   plot(data(i,:));
%   pause(0.2);
% end

% plot(full_data)

% [r, lags] = xcorr(data(1,:), data(2,:));
% plot(lags, r);

% NSamp = scn(1,1).NumSmpls;
% data = data(1:NSamp);
% 
% t_ns = linspace(cnfg.ScnStrt_ps,cnfg.ScnStp_ps,NSamp)/1000;
% dt = (t_ns(end)-t_ns(1))/(NSamp-1);
% fs = 1/dt;
% 
% figure;
% plot(t_ns,data);
% 
% pulse_range = [-1.678, 2.169];
% 
% [M,start_sample] = min(abs(t_ns - pulse_range(1)));
% [M,stop_sample]  = min(abs(t_ns - pulse_range(2)));
% 
% data(1:start_sample-1)  = 0;
% data(stop_sample+1:end) = 0;
% 
% pulse_shape = fft(data);

% figure;
% plot(abs(fft(data)));
% 
% figure;
% plot(t_ns,data);
