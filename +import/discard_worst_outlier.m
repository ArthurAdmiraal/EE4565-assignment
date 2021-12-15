function data_out = discard_worst_outlier(data_in)
  num_frames = import.get_num_frames(data_in);
  
  variances = [];
  for i = 1:num_frames
    variance  = import.get_data_variance(data_in(1:num_frames ~= i, :));
    variances = [variances, variance];
  end
  
  [M, I]   = min(variances);
  data_out = data_in(1:num_frames ~= I, :);
end
