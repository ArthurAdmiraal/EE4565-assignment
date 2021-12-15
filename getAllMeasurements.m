close all;
clear all;

%% get calibration signal
% calibration_file_name = 'mulyipath_full_011.csv';
% cal_start = -1.922;
% cal_stop  =  2.169;

calibration_file_name = 'mulyipath_nodirect_012.csv';
cal_start = -1.25;
cal_stop  =  1.25;

[t_ns, signal] = import.get_measurement(calibration_file_name);

calibration_signal = signal;

[M, start_sample] = min(abs(t_ns - cal_start));
[M, stop_sample]  = min(abs(t_ns - cal_stop));

calibration_signal(1:start_sample)  = 0;
calibration_signal(stop_sample:end) = 0;

figure;
plot(t_ns, signal, t_ns, calibration_signal);

[f, cal_spectrum] = analysis.get_spectrum(t_ns, calibration_signal);

figure;
plot(f, 20*log(abs(cal_spectrum)));


threshold = 0.05;
frequency_range = f > 0 & abs(cal_spectrum)/max(abs(cal_spectrum)) > threshold;
f_start_index   = find(frequency_range, 1, 'first');
f_end_index     = find(frequency_range, 1, 'last');

f_start = f(f_start_index);
f_end   = f(f_end_index);

%% data analysis
output_folder = 'Output';

descriptions = {'Empty',                           ... % experiment 2) 3 metre without people
                'Empty (no direct)',               ... % experiment 5) only reflector blocking path
                'Sidewards reflector',             ... % mulyipath_full_011
                'Sidewards reflector (no direct)', ... % mulyipath_nodirect_012
                'People',                          ... % experiment 3) 3 metre with people
                'People (no direct)'                   % experiment 4) people with reflector
  };

file_names = {'experiment2_006.csv',        ... % experiment 2) 3 metre without people
              'experiment5_009.csv',        ... % experiment 5) only reflector blocking path
              'mulyipath_full_011.csv',     ... % mulyipath_full_011
              'mulyipath_nodirect_012.csv', ... % mulyipath_nodirect_012
              'experiment3_007.csv',        ... % experiment 3) 3 metre with people
              'experiment4_008.csv'             % experiment 4) people with reflector
  };

out_names = {'Empty',              ... % experiment 2) 3 metre without people
             'Empty_nodirect',     ... % experiment 5) only reflector blocking path
             'Sidewards',          ... % mulyipath_full_011
             'Sidewards_nodirect', ... % mulyipath_nodirect_012
             'People',             ... % experiment 3) 3 metre with people
             'People_nodirect'         % experiment 4) people with reflector
  };

if not(isfolder(output_folder))
    mkdir(output_folder)
end

[t_ns, calibration_signal] = analysis.get_calibration_signal(calibration_file_name, [-1.25, 1.25], 'length', 'nonzero');

for trialnum = 1:length(file_names) 
  file_name   = file_names{trialnum};
  description = descriptions{trialnum};

  [t_ns, signal] = import.get_measurement(file_name);
  
  csvwrite([output_folder '/' out_names{trialnum} '-time.csv'], [t_ns;signal/max(abs(signal))].');
  
  [f, spectrum]  = analysis.get_spectrum(t_ns, signal);

  spectrum          = spectrum ./ cal_spectrum;
  windowed_spectrum = abs(spectrum(f_start_index:f_end_index));
  f                 = f(f_start_index:f_end_index);
  
  csvwrite([output_folder '/' out_names{trialnum} '-spectrum.csv'], [f;windowed_spectrum].');
  
%   figure;
%   plot(f, windowed_spectrum);
%   title(['Calibrated spectrum',' ',description], 'Interpreter', 'none');
  
  [t, reflections] = analysis.get_impulse_from_ss(f, windowed_spectrum);
  reflections      = reflections / reflections(1);
  
  csvwrite([output_folder '/' out_names{trialnum} '-impulse.csv'], [t*physconst('LightSpeed')*1e-9*100;20*log(abs(reflections))].');

  [t, reflections] = analysis.get_fir_deconvolution(t_ns, signal, calibration_signal);
  csvwrite([output_folder '/' out_names{trialnum} '-fir_impulse.csv'], [t*physconst('LightSpeed')*1e-9*100;20*log(abs(reflections))].');
  
%   figure;
%   plot(t*physconst('LightSpeed')*1e-9*100, 20*log(abs(reflections)));
  
%   figure;
%   plot(t, 20*log(abs(reflections)));
%   title(['Calibrated impulse response',' ',description], 'Interpreter', 'none');
end

%% old stuff
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
