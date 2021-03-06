close all;
clear all;

%% get calibration signal
% calibration_file_name = 'mulyipath_full_011.csv';
% cal_start = -1.922;
% cal_stop  =  2.169;

calibration_file_name = 'mulyipath_nodirect_012.csv';
cal_start = -1.25;
cal_stop  =  1.25;

[t_ns, calibration_signal] = analysis.get_calibration_signal(calibration_file_name, [-1.25, 1.25], 'length', 'nonzero');

%% data analysis
% load signals in pairs
% file_name_direct   = file_names  {2*trialnum_major - 1};
% file_name_nodirect = file_names  {2*trialnum_major - 0};
% 
% signal_aligned = analysis.align_to_signal(signal_full, signal_blocked);
% t_ns           = t_ns_full;

[t_ns, signal_direct]   = get_signal(5);
[~,    signal_nodirect] = get_signal(6);

signal_nodirect = analysis.align_to_signal(t_ns, signal_direct, signal_nodirect, [-1,4.5]);

[t,  reflections_full]   = analysis.get_fir_deconvolution(t_ns, signal_direct,   calibration_signal, false);
[~, reflections_blocked] = analysis.get_fir_deconvolution(t_ns, signal_nodirect, calibration_signal, false);

reflections_blocked = reflections_blocked / max(reflections_full);
reflections_full    = reflections_full    / max(reflections_full);

figure;
hold on;
plot(t_ns, signal_direct);
plot(t_ns, signal_nodirect);
legend('Direct','Blocked');
title('Aligned time data');

figure;
hold on;
x = t*physconst('LightSpeed')*1e-9*100;
plot(x, 20*log10(abs(reflections_full)));
plot(x, 20*log10(abs(reflections_blocked)));
legend('Direct','Blocked');
title('Side-by-side impulse responses');
  
function [t_ns, signal, description] = get_signal(trialnum)
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

  file_name   = file_names{trialnum};
  
  [t_ns, signal] = import.get_measurement(file_name);
  description    = descriptions{trialnum};
end