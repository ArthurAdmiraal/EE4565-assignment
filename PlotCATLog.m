[cnfg,scn] = my_read_cat_log();
data = [scn.scndata];

NSamp = scn(1,1).NumSmpls;
data = data(1:NSamp);

t_ns = linspace(cnfg.ScnStrt_ps,cnfg.ScnStp_ps,NSamp)/1000;
dt = (t_ns(end)-t_ns(1))/(NSamp-1);
fs = 1/dt;

figure;plot(t_ns,data);