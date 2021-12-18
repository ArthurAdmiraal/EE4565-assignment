output_folder = 'PreOutput';
file_name     = 'experiment3_007.csv'; % people (with direct)

[cnfg, scn] = my_read_cat_log('Data', file_name);
data = import.extract_data_frames(scn);
data = import.align_data_frames(data);

single_data = import.discard_outliers(data, 0.25);
single_data = import.get_average(single_data);

t_ns    = linspace(cnfg.ScnStrt_ps,cnfg.ScnStp_ps,length(data))/1000;

data    = data/max(abs(single_data));

indices = t_ns>-2.3 & t_ns<6.3;
data    = data(:, indices);
t_ns    = t_ns(indices);

if not(isfolder(output_folder))
    mkdir(output_folder)
end

csvwrite([output_folder '/People_raw-time.csv'], [t_ns;data].');