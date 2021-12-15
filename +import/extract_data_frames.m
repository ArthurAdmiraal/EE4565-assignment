function data = extract_data_frames(scn)
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