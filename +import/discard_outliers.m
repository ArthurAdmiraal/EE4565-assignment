function data_out = discard_outliers(data_in, p)
  num_frames = import.get_num_frames(data_in);

  amount_to_discard = floor(p*num_frames/2);
  
  data_out = data_in;
  for i = 1:amount_to_discard
    data_out = import.discard_worst_outlier(data_out);
  end
end