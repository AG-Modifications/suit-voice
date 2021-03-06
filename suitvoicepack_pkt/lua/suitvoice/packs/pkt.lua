--[[ Hazardous EnVironment Suit Voice Pack ]]

RegisterSuitVoicePack( "Prospekt", "pkt", "////////////////////////////////////////////////////////////////\n// H.E.V. Suit Voice Pack - Prospekt\n////////////////////////////////////////////////////////////////\n\n// Initialization\nHEV_PKT_AAx player/pcv_vest\nHEV_PKT_A0 player/pcv_vest\n\n// Automatic Medical Systems\nHEV_PKT_MED1 hl1/fvox/(p140) boop, boop, boop, (p100) automedic_onpkt {Len 4.92 closecaption HEV.automedic_on}\n\nHEV_PKT_HEAL5 hl1/fvox/(p140) boop, boop, boop, (p100) hiss, antidote_shotpkt {Len 4.17 closecaption HEV.antidote_shot}\nHEV_PKT_HEAL7 hl1/fvox/(p140) boop, boop, boop, (p100) hiss, morphine_shotpkt {Len 4.16 closecaption HEV.morphine_shot}\n\n// Vital Sign Monitoring\nHEV_PKT_DMG0 hl1/fvox/(p160) boop, boop, boop, (p100) minor_lacerationspkt {Len 4.09 closecaption HEV.minor_lacerations}\nHEV_PKT_DMG1 hl1/fvox/(p160) boop, boop, boop, (p100) major_lacerationspkt {Len 4.19 closecaption HEV.major_lacerations}\nHEV_PKT_DMG2 hl1/fvox/(p160) boop, boop, boop, (p100) internal_bleedingpkt {Len 3.64 closecaption HEV.internal_bleeding}\nHEV_PKT_DMG3 hl1/fvox/(p160) boop, boop, boop, (p100) blood_toxinspkt {Len 5.04 closecaption HEV.blood_toxins}\nHEV_PKT_DMG4 hl1/fvox/(p160) boop, boop, boop, (p100) minor_fracturepkt {Len 3.67 closecaption HEV.minor_fracture}\nHEV_PKT_DMG5 hl1/fvox/(p160) boop, boop, boop, (p100) major_fracturepkt {Len 3.67 closecaption HEV.major_fracture}\nHEV_PKT_DMG6 hl1/fvox/(p160) boop, boop, boop, (p100) blood_losspkt {Len 3.39 closecaption HEV.blood_loss}\nHEV_PKT_DMG7 hl1/fvox/(p140) boop, boop, boop, (p100) seek_medicpkt {Len 3.92 closecaption HEV.seek_medic}\n\nHEV_PKT_SHOCK hl1/fvox/(p120) beep, beep, (p100) warningpkt, shock_damagepkt {Len 4.05 closecaption HEV.shock_damage}\nHEV_PKT_FIRE hl1/fvox/(p120) beep, beep, (p100) warningpkt, heat_damagepkt {Len 4.77 closecaption HEV.heat_damage}\n\nHEV_PKT_HLTH1 hl1/fvox/(p120) beep, beep, (p100) health_dropping2pkt {Len 3.68 closecaption HEV.health_dropping2}\nHEV_PKT_HLTH2 hl1/fvox/(p120) beep, beep, beep, (p100) health_criticalpkt {Len 4.32 closecaption HEV.health_critical}\nHEV_PKT_HLTH3 hl1/fvox/(p120) beep, beep, beep, (p100) near_deathpkt {Len 4.77 closecaption HEV.near_death}\n\n// High Impact Reactive Armor\nHEV_PKT_0P hl1/fvox/fuzz fuzz, power_belowpkt fivepkt percentpkt {Len 6.35}\nHEV_PKT_1P hl1/fvox/fuzz fuzz, power_restoredpkt(e40), tenpkt percentpkt {Len 2.75}\nHEV_PKT_2P hl1/fvox/fuzz fuzz, power_restoredpkt(e40), fifteenpkt percentpkt {Len 3.15}\nHEV_PKT_3P hl1/fvox/fuzz fuzz, power_restoredpkt(e40), twentypkt percentpkt {Len 2.99}\nHEV_PKT_4P hl1/fvox/fuzz fuzz, power_restoredpkt(e40), twentypkt fivepkt percentpkt {Len 3.87}\nHEV_PKT_5P hl1/fvox/fuzz fuzz, power_restoredpkt(e40), thirtypkt percentpkt {Len 3.04}\nHEV_PKT_6P hl1/fvox/fuzz fuzz, power_restoredpkt(e40), thirtypkt fivepkt percentpkt {Len 3.91}\nHEV_PKT_7P hl1/fvox/fuzz fuzz, power_restoredpkt(e40), fourtypkt percentpkt {Len 3.07}\nHEV_PKT_8P hl1/fvox/fuzz fuzz, power_restoredpkt(e40), fourtypkt fivepkt percentpkt {Len 3.95}\nHEV_PKT_9P hl1/fvox/fuzz fuzz, power_restoredpkt(e40), fiftypkt percentpkt {Len 3.17}\nHEV_PKT_10P hl1/fvox/fuzz fuzz, power_restoredpkt(e40), fiftypkt fivepkt percentpkt {Len 4.05}\nHEV_PKT_11P hl1/fvox/fuzz fuzz, power_restoredpkt(e40), sixtypkt percentpkt {Len 3.16}\nHEV_PKT_12P hl1/fvox/fuzz fuzz, power_restoredpkt(e40), sixtypkt fivepkt percentpkt {Len 4.04}\nHEV_PKT_13P hl1/fvox/fuzz fuzz, power_restoredpkt(e40), seventypkt percentpkt {Len 3.12}\nHEV_PKT_14P hl1/fvox/fuzz fuzz, power_restoredpkt(e40), seventypkt fivepkt percentpkt {Len 4.00}\nHEV_PKT_15P hl1/fvox/fuzz fuzz, power_restoredpkt(e40), eightypkt percentpkt {Len 2.88}\nHEV_PKT_16P hl1/fvox/fuzz fuzz, power_restoredpkt(e40), eightypkt fivepkt percentpkt {Len 3.76}\nHEV_PKT_17P hl1/fvox/fuzz fuzz, power_restoredpkt(e40), ninetypkt percentpkt {Len 3.12}\nHEV_PKT_18P hl1/fvox/fuzz fuzz, power_restoredpkt(e40), ninetypkt fivepkt percentpkt {Len 4.00}\nHEV_PKT_19P hl1/fvox/fuzz fuzz, power_level_ispkt onehundredpkt percentpkt {Len 4.62}\n\n// Munition Level Monitoring\nHEV_PKT_AMO0 hl1/fvox/blip ammo_depletedpkt {Len 2.16 closecaption HEV.ammo_depleted}\n\n// Atmospheric Contaminant Sensors\nHEV_PKT_DET0 hl1/fvox/blip blip blip, biohazard_detectedpkt {Len 3.67 closecaption HEV.biohazard_detected}\nHEV_PKT_DET1 hl1/fvox/blip blip blip, chemical_detectedpkt {Len 4.33 closecaption HEV.chemical_detected}\nHEV_PKT_DET2 hl1/fvox/blip blip blip, radiation_detectedpkt {Len 5.08 closecaption HEV.radiation_detected}\n" );