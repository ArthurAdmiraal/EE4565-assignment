close all;
clear all;

%% get calibration signal
% calibration_file_name = 'mulyipath_full_011.csv';
% cal_start = -1.922;
% cal_stop  =  2.169;

calibration_file_name = 'mulyipath_nodirect_012.csv';
cal_start = -1.25;
cal_stop  =  1.25;

% acquire calibration signal with full length for correct size of spectrum
[t_ns, calibration_signal] = analysis.get_calibration_signal(calibration_file_name, [cal_start, cal_stop]);
[f, cal_spectrum]          = analysis.get_spectrum(t_ns, calibration_signal);

threshold       = 0.05;
frequency_range = (f > 0) & (abs(cal_spectrum)/max(abs(cal_spectrum)) > threshold);
f_start_index   = find(frequency_range, 1, 'first');
f_end_index     = find(frequency_range, 1, 'last');

f_start = f(f_start_index);
f_end   = f(f_end_index);

% reacquire calibration signal with mode nonzero for FIR filter
[t_ns_cal, calibration_signal] = analysis.get_calibration_signal(calibration_file_name, [cal_start, cal_stop], 'length', 'nonzero');

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

mask_ranges = {
    [-1.5, 0.5], ... % empty scenario
    [-1.0, 2.0], ... % sidewards scenario
    [-1.0, 4.5], ...% people scenario
  };

if not(isfolder(output_folder))
    mkdir(output_folder)
end

% cell arrays will store the signals for some initial processing
signals             = {};
t_nss               = {};

% align the signals in pairs
for trialnum_major = 1:(length(file_names)/2)
  % load signals in pairs
  file_name_direct   = file_names  {2*trialnum_major - 1};
  file_name_nodirect = file_names  {2*trialnum_major - 0};
  
  [~,    signal_nodirect] = import.get_measurement(file_name_nodirect);
  [t_ns, signal_direct]   = import.get_measurement(file_name_direct);

  % align signals
  signal_nodirect = analysis.align_to_signal(t_ns, signal_direct, signal_nodirect, mask_ranges{trialnum_major});
  
  % write pairs to cell arrays
  signals{2*trialnum_major - 1} = signal_direct;
  signals{2*trialnum_major - 0} = signal_nodirect;
  
  t_nss{2*trialnum_major - 1} = t_ns;
  t_nss{2*trialnum_major - 0} = t_ns;
end

for trialnum = 1:length(file_names)
    % load aligned signals from cell arrays
    t_ns        = t_nss{trialnum};
    signal      = signals{trialnum};
    description = descriptions{trialnum};

    % write raw time data
    if mod(trialnum,2)==1
      norm = max(abs(signal));
    end
    csvwrite([output_folder '/' out_names{trialnum} '-time.csv'], [t_ns;signal/norm].');

    % write spectrum of data
    [f, spectrum]  = analysis.get_spectrum(t_ns, signal);

    spectrum          = spectrum ./ cal_spectrum;
    windowed_spectrum = abs(spectrum(f_start_index:f_end_index));
    f                 = f(f_start_index:f_end_index);

    csvwrite([output_folder '/' out_names{trialnum} '-spectrum.csv'], [f;abs(windowed_spectrum)].');

    % write spectrum-estimated impulse response of data
    [t, reflections] = analysis.get_impulse_from_ss(f, windowed_spectrum);
    reflections      = reflections / reflections(1);

    csvwrite([output_folder '/' out_names{trialnum} '-impulse.csv'], [t*physconst('LightSpeed')*1e-9*100;20*log10(abs(reflections))].');
    
    % write fir deconvolution of data
    [t, reflections, t_raw, raw] = analysis.get_fir_deconvolution(t_ns, signal, calibration_signal, false);
    [t, reflections]             = analysis.get_fir_envelope_deconvolution(t_ns, signal, t_ns_cal, calibration_signal, false);
    
    % normalise with the direct signal, which comes when trialnum%2 = 1
    if mod(trialnum,2)==1
      M     = max(reflections);
      M_raw = max(abs(raw));
      x     = t     * physconst('LightSpeed')*1e-9*100;
      x_raw = t_raw * physconst('LightSpeed')*1e-9*100;
    end
    reflections = reflections / M;
    
    csvwrite([output_folder '/' out_names{trialnum} '-fir_impulse.csv'], [x;20*log10(abs(reflections))].');
    csvwrite([output_folder '/' out_names{trialnum} '-fir_impulse_raw.csv'], [x_raw;cos(2*pi*3*t_raw).*raw/M_raw].');
end