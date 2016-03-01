battery.init_temp = 25;
battery.init_SOC = 75;
SOC_beg=battery.init_SOC;
battery.HSOC_gas_current = 0.0;                                     %% gassing current of a battery at 100% SOC [A]
battery.eta_coulomb = 100;                                         %% coulombic efficiency at PSOC [%], not activated in model
battery.I_max_regen = 115; %!%!%! note the CA: with 115 A max CA and full decel performance (i.e. stronger decel than cycle prescribes, FC is lowest); regen only
%battery.I_max_regen = 95; %!%!%! note the CA: with 95 A max CA and full decel performance (i.e. stronger decel than cycle prescribes, FC is lowest); regen + stop/start
%
Hop_12V_80Ah
AGM_ini_file