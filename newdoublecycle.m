load NoGen_260808
PwpPt_Tq_EngGross=[PwpPt_Tq_EngGross;PwpPt_Tq_EngGross];
PwpPt_W_EngDn=[PwpPt_W_EngDn;PwpPt_W_EngDn];
Drv_V_VehTarg=[Drv_V_VehTarg;Drv_V_VehTarg];
sim_sample_time=[sim_sample_time;sim_sample_time+max(sim_sample_time)+0.1];
save NoGenDoubleNEDC sim_sample_time PwpPt_Tq_EngGross PwpPt_W_EngDn Drv_V_VehTarg lm_alternator engine drive_acc
