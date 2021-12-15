function [t_ns, signal] = get_measurement(file_name)
  [cnfg, scn] = my_read_cat_log('Data', file_name);
  data = import.extract_data_frames(scn);
  data = import.align_data_frames(data);
  data = import.discard_outliers(data, 0.25);
  data = import.get_average(data);
  
  t_ns   = linspace(cnfg.ScnStrt_ps,cnfg.ScnStp_ps,length(data))/1000;
  signal = data;
end