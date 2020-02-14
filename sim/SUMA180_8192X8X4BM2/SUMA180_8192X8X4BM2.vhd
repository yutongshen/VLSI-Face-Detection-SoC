-- |-----------------------------------------------------------------------|
-- 
--              Synchronous High Speed Single Port SRAM Compiler 
-- 
--                    UMC 0.18um GenericII Logic Process
--    __________________________________________________________________________
-- 
-- 
--        (C) Copyright 2002-2009 Faraday Technology Corp. All Rights Reserved.
-- 
--      This source code is an unpublished work belongs to Faraday Technology
--      Corp.  It is considered a trade secret and is not to be divulged or
--      used by parties who have not received written authorization from
--      Faraday Technology Corp.
-- 
--      Faraday's home page can be found at:
--      http://www.faraday-tech.com/
--     
-- ________________________________________________________________________________
-- 
--       Module Name       :  SUMA180_8192X8X4BM2  
--       Word              :  8192                 
--       Bit               :  8                    
--       Byte              :  4                    
--       Mux               :  2                    
--       Power Ring Type   :  port                 
--       Power Ring Width  :  2 (um)               
--       Output Loading    :  0.01 (pf)            
--       Input Data Slew   :  0.02 (ns)            
--       Input Clock Slew  :  0.02 (ns)            
-- 
-- ________________________________________________________________________________
-- 
--       Library          : FSA0M_A
--       Memaker          : 200901.2.1
--       Date             : 2019/01/15 02:45:30
-- 
-- ________________________________________________________________________________
-- 
--
-- Notice on usage: Fixed delay or timing data are given in this model.
--                  It supports SDF back-annotation, please generate SDF file
--                  by EDA tools to get the accurate timing.
--
-- |-----------------------------------------------------------------------|
--
-- Warning : 
--   If customer's design viloate the set-up time or hold time criteria of 
--   synchronous SRAM, it's possible to hit the meta-stable point of 
--   latch circuit in the decoder and cause the data loss in the memory 
--   bitcell. So please follow the memory IP's spec to design your 
--   product.
--
-- |-----------------------------------------------------------------------|
--
--       Library          : FSA0M_A
--       Memaker          : 200901.2.1
--       Date             : Tue Jan 15 02:45:30 CST 2019
--
-- |-----------------------------------------------------------------------|

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.VITAL_Primitives.all;
use IEEE.VITAL_Timing.all;
use std.textio.all;
use IEEE.std_logic_textio.all;

-- entity declaration --
entity SUMA180_8192X8X4BM2 is
   generic(
      SYN_CS:          integer  := 1;
      NO_SER_TOH:      integer  := 1;
      AddressSize:     integer  := 13;
      Bits:            integer  := 8;
      Words:           integer  := 8192;
      Bytes:           integer  := 4;
      AspectRatio:     integer  := 2;
      TOH:             time     := 1.212 ns;

      TimingChecksOn: Boolean := True;
      InstancePath: STRING := "*";
      Xon: Boolean := True;
      MsgOn: Boolean := True;

      tpd_CK_DO0_posedge : VitalDelayType01 :=  (3.295 ns, 3.295 ns);
      tpd_CK_DO1_posedge : VitalDelayType01 :=  (3.295 ns, 3.295 ns);
      tpd_CK_DO2_posedge : VitalDelayType01 :=  (3.295 ns, 3.295 ns);
      tpd_CK_DO3_posedge : VitalDelayType01 :=  (3.295 ns, 3.295 ns);
      tpd_CK_DO4_posedge : VitalDelayType01 :=  (3.295 ns, 3.295 ns);
      tpd_CK_DO5_posedge : VitalDelayType01 :=  (3.295 ns, 3.295 ns);
      tpd_CK_DO6_posedge : VitalDelayType01 :=  (3.295 ns, 3.295 ns);
      tpd_CK_DO7_posedge : VitalDelayType01 :=  (3.295 ns, 3.295 ns);
      tpd_CK_DO8_posedge : VitalDelayType01 :=  (3.295 ns, 3.295 ns);
      tpd_CK_DO9_posedge : VitalDelayType01 :=  (3.295 ns, 3.295 ns);
      tpd_CK_DO10_posedge : VitalDelayType01 :=  (3.295 ns, 3.295 ns);
      tpd_CK_DO11_posedge : VitalDelayType01 :=  (3.295 ns, 3.295 ns);
      tpd_CK_DO12_posedge : VitalDelayType01 :=  (3.295 ns, 3.295 ns);
      tpd_CK_DO13_posedge : VitalDelayType01 :=  (3.295 ns, 3.295 ns);
      tpd_CK_DO14_posedge : VitalDelayType01 :=  (3.295 ns, 3.295 ns);
      tpd_CK_DO15_posedge : VitalDelayType01 :=  (3.295 ns, 3.295 ns);
      tpd_CK_DO16_posedge : VitalDelayType01 :=  (3.295 ns, 3.295 ns);
      tpd_CK_DO17_posedge : VitalDelayType01 :=  (3.295 ns, 3.295 ns);
      tpd_CK_DO18_posedge : VitalDelayType01 :=  (3.295 ns, 3.295 ns);
      tpd_CK_DO19_posedge : VitalDelayType01 :=  (3.295 ns, 3.295 ns);
      tpd_CK_DO20_posedge : VitalDelayType01 :=  (3.295 ns, 3.295 ns);
      tpd_CK_DO21_posedge : VitalDelayType01 :=  (3.295 ns, 3.295 ns);
      tpd_CK_DO22_posedge : VitalDelayType01 :=  (3.295 ns, 3.295 ns);
      tpd_CK_DO23_posedge : VitalDelayType01 :=  (3.295 ns, 3.295 ns);
      tpd_CK_DO24_posedge : VitalDelayType01 :=  (3.295 ns, 3.295 ns);
      tpd_CK_DO25_posedge : VitalDelayType01 :=  (3.295 ns, 3.295 ns);
      tpd_CK_DO26_posedge : VitalDelayType01 :=  (3.295 ns, 3.295 ns);
      tpd_CK_DO27_posedge : VitalDelayType01 :=  (3.295 ns, 3.295 ns);
      tpd_CK_DO28_posedge : VitalDelayType01 :=  (3.295 ns, 3.295 ns);
      tpd_CK_DO29_posedge : VitalDelayType01 :=  (3.295 ns, 3.295 ns);
      tpd_CK_DO30_posedge : VitalDelayType01 :=  (3.295 ns, 3.295 ns);
      tpd_CK_DO31_posedge : VitalDelayType01 :=  (3.295 ns, 3.295 ns);

      tpd_OE_DO0    : VitalDelayType01Z := (0.418 ns, 0.418 ns, 0.559 ns, 0.418 ns, 0.559 ns, 0.418 ns);
      tpd_OE_DO1    : VitalDelayType01Z := (0.418 ns, 0.418 ns, 0.559 ns, 0.418 ns, 0.559 ns, 0.418 ns);
      tpd_OE_DO2    : VitalDelayType01Z := (0.418 ns, 0.418 ns, 0.559 ns, 0.418 ns, 0.559 ns, 0.418 ns);
      tpd_OE_DO3    : VitalDelayType01Z := (0.418 ns, 0.418 ns, 0.559 ns, 0.418 ns, 0.559 ns, 0.418 ns);
      tpd_OE_DO4    : VitalDelayType01Z := (0.418 ns, 0.418 ns, 0.559 ns, 0.418 ns, 0.559 ns, 0.418 ns);
      tpd_OE_DO5    : VitalDelayType01Z := (0.418 ns, 0.418 ns, 0.559 ns, 0.418 ns, 0.559 ns, 0.418 ns);
      tpd_OE_DO6    : VitalDelayType01Z := (0.418 ns, 0.418 ns, 0.559 ns, 0.418 ns, 0.559 ns, 0.418 ns);
      tpd_OE_DO7    : VitalDelayType01Z := (0.418 ns, 0.418 ns, 0.559 ns, 0.418 ns, 0.559 ns, 0.418 ns);
      tpd_OE_DO8    : VitalDelayType01Z := (0.418 ns, 0.418 ns, 0.559 ns, 0.418 ns, 0.559 ns, 0.418 ns);
      tpd_OE_DO9    : VitalDelayType01Z := (0.418 ns, 0.418 ns, 0.559 ns, 0.418 ns, 0.559 ns, 0.418 ns);
      tpd_OE_DO10    : VitalDelayType01Z := (0.418 ns, 0.418 ns, 0.559 ns, 0.418 ns, 0.559 ns, 0.418 ns);
      tpd_OE_DO11    : VitalDelayType01Z := (0.418 ns, 0.418 ns, 0.559 ns, 0.418 ns, 0.559 ns, 0.418 ns);
      tpd_OE_DO12    : VitalDelayType01Z := (0.418 ns, 0.418 ns, 0.559 ns, 0.418 ns, 0.559 ns, 0.418 ns);
      tpd_OE_DO13    : VitalDelayType01Z := (0.418 ns, 0.418 ns, 0.559 ns, 0.418 ns, 0.559 ns, 0.418 ns);
      tpd_OE_DO14    : VitalDelayType01Z := (0.418 ns, 0.418 ns, 0.559 ns, 0.418 ns, 0.559 ns, 0.418 ns);
      tpd_OE_DO15    : VitalDelayType01Z := (0.418 ns, 0.418 ns, 0.559 ns, 0.418 ns, 0.559 ns, 0.418 ns);
      tpd_OE_DO16    : VitalDelayType01Z := (0.418 ns, 0.418 ns, 0.559 ns, 0.418 ns, 0.559 ns, 0.418 ns);
      tpd_OE_DO17    : VitalDelayType01Z := (0.418 ns, 0.418 ns, 0.559 ns, 0.418 ns, 0.559 ns, 0.418 ns);
      tpd_OE_DO18    : VitalDelayType01Z := (0.418 ns, 0.418 ns, 0.559 ns, 0.418 ns, 0.559 ns, 0.418 ns);
      tpd_OE_DO19    : VitalDelayType01Z := (0.418 ns, 0.418 ns, 0.559 ns, 0.418 ns, 0.559 ns, 0.418 ns);
      tpd_OE_DO20    : VitalDelayType01Z := (0.418 ns, 0.418 ns, 0.559 ns, 0.418 ns, 0.559 ns, 0.418 ns);
      tpd_OE_DO21    : VitalDelayType01Z := (0.418 ns, 0.418 ns, 0.559 ns, 0.418 ns, 0.559 ns, 0.418 ns);
      tpd_OE_DO22    : VitalDelayType01Z := (0.418 ns, 0.418 ns, 0.559 ns, 0.418 ns, 0.559 ns, 0.418 ns);
      tpd_OE_DO23    : VitalDelayType01Z := (0.418 ns, 0.418 ns, 0.559 ns, 0.418 ns, 0.559 ns, 0.418 ns);
      tpd_OE_DO24    : VitalDelayType01Z := (0.418 ns, 0.418 ns, 0.559 ns, 0.418 ns, 0.559 ns, 0.418 ns);
      tpd_OE_DO25    : VitalDelayType01Z := (0.418 ns, 0.418 ns, 0.559 ns, 0.418 ns, 0.559 ns, 0.418 ns);
      tpd_OE_DO26    : VitalDelayType01Z := (0.418 ns, 0.418 ns, 0.559 ns, 0.418 ns, 0.559 ns, 0.418 ns);
      tpd_OE_DO27    : VitalDelayType01Z := (0.418 ns, 0.418 ns, 0.559 ns, 0.418 ns, 0.559 ns, 0.418 ns);
      tpd_OE_DO28    : VitalDelayType01Z := (0.418 ns, 0.418 ns, 0.559 ns, 0.418 ns, 0.559 ns, 0.418 ns);
      tpd_OE_DO29    : VitalDelayType01Z := (0.418 ns, 0.418 ns, 0.559 ns, 0.418 ns, 0.559 ns, 0.418 ns);
      tpd_OE_DO30    : VitalDelayType01Z := (0.418 ns, 0.418 ns, 0.559 ns, 0.418 ns, 0.559 ns, 0.418 ns);
      tpd_OE_DO31    : VitalDelayType01Z := (0.418 ns, 0.418 ns, 0.559 ns, 0.418 ns, 0.559 ns, 0.418 ns);
      tsetup_A0_CK_posedge_posedge    :  VitalDelayType := 0.615 ns;
      tsetup_A0_CK_negedge_posedge    :  VitalDelayType := 0.615 ns;
      tsetup_A1_CK_posedge_posedge    :  VitalDelayType := 0.615 ns;
      tsetup_A1_CK_negedge_posedge    :  VitalDelayType := 0.615 ns;
      tsetup_A2_CK_posedge_posedge    :  VitalDelayType := 0.615 ns;
      tsetup_A2_CK_negedge_posedge    :  VitalDelayType := 0.615 ns;
      tsetup_A3_CK_posedge_posedge    :  VitalDelayType := 0.615 ns;
      tsetup_A3_CK_negedge_posedge    :  VitalDelayType := 0.615 ns;
      tsetup_A4_CK_posedge_posedge    :  VitalDelayType := 0.615 ns;
      tsetup_A4_CK_negedge_posedge    :  VitalDelayType := 0.615 ns;
      tsetup_A5_CK_posedge_posedge    :  VitalDelayType := 0.615 ns;
      tsetup_A5_CK_negedge_posedge    :  VitalDelayType := 0.615 ns;
      tsetup_A6_CK_posedge_posedge    :  VitalDelayType := 0.615 ns;
      tsetup_A6_CK_negedge_posedge    :  VitalDelayType := 0.615 ns;
      tsetup_A7_CK_posedge_posedge    :  VitalDelayType := 0.615 ns;
      tsetup_A7_CK_negedge_posedge    :  VitalDelayType := 0.615 ns;
      tsetup_A8_CK_posedge_posedge    :  VitalDelayType := 0.615 ns;
      tsetup_A8_CK_negedge_posedge    :  VitalDelayType := 0.615 ns;
      tsetup_A9_CK_posedge_posedge    :  VitalDelayType := 0.615 ns;
      tsetup_A9_CK_negedge_posedge    :  VitalDelayType := 0.615 ns;
      tsetup_A10_CK_posedge_posedge    :  VitalDelayType := 0.615 ns;
      tsetup_A10_CK_negedge_posedge    :  VitalDelayType := 0.615 ns;
      tsetup_A11_CK_posedge_posedge    :  VitalDelayType := 0.615 ns;
      tsetup_A11_CK_negedge_posedge    :  VitalDelayType := 0.615 ns;
      tsetup_A12_CK_posedge_posedge    :  VitalDelayType := 0.615 ns;
      tsetup_A12_CK_negedge_posedge    :  VitalDelayType := 0.615 ns;
      thold_A0_CK_posedge_posedge     :  VitalDelayType := 0.110 ns;
      thold_A0_CK_negedge_posedge     :  VitalDelayType := 0.110 ns;
      thold_A1_CK_posedge_posedge     :  VitalDelayType := 0.110 ns;
      thold_A1_CK_negedge_posedge     :  VitalDelayType := 0.110 ns;
      thold_A2_CK_posedge_posedge     :  VitalDelayType := 0.110 ns;
      thold_A2_CK_negedge_posedge     :  VitalDelayType := 0.110 ns;
      thold_A3_CK_posedge_posedge     :  VitalDelayType := 0.110 ns;
      thold_A3_CK_negedge_posedge     :  VitalDelayType := 0.110 ns;
      thold_A4_CK_posedge_posedge     :  VitalDelayType := 0.110 ns;
      thold_A4_CK_negedge_posedge     :  VitalDelayType := 0.110 ns;
      thold_A5_CK_posedge_posedge     :  VitalDelayType := 0.110 ns;
      thold_A5_CK_negedge_posedge     :  VitalDelayType := 0.110 ns;
      thold_A6_CK_posedge_posedge     :  VitalDelayType := 0.110 ns;
      thold_A6_CK_negedge_posedge     :  VitalDelayType := 0.110 ns;
      thold_A7_CK_posedge_posedge     :  VitalDelayType := 0.110 ns;
      thold_A7_CK_negedge_posedge     :  VitalDelayType := 0.110 ns;
      thold_A8_CK_posedge_posedge     :  VitalDelayType := 0.110 ns;
      thold_A8_CK_negedge_posedge     :  VitalDelayType := 0.110 ns;
      thold_A9_CK_posedge_posedge     :  VitalDelayType := 0.110 ns;
      thold_A9_CK_negedge_posedge     :  VitalDelayType := 0.110 ns;
      thold_A10_CK_posedge_posedge     :  VitalDelayType := 0.110 ns;
      thold_A10_CK_negedge_posedge     :  VitalDelayType := 0.110 ns;
      thold_A11_CK_posedge_posedge     :  VitalDelayType := 0.110 ns;
      thold_A11_CK_negedge_posedge     :  VitalDelayType := 0.110 ns;
      thold_A12_CK_posedge_posedge     :  VitalDelayType := 0.110 ns;
      thold_A12_CK_negedge_posedge     :  VitalDelayType := 0.110 ns;
      tsetup_DI0_CK_posedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI0_CK_negedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI1_CK_posedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI1_CK_negedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI2_CK_posedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI2_CK_negedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI3_CK_posedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI3_CK_negedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI4_CK_posedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI4_CK_negedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI5_CK_posedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI5_CK_negedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI6_CK_posedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI6_CK_negedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI7_CK_posedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI7_CK_negedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI8_CK_posedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI8_CK_negedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI9_CK_posedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI9_CK_negedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI10_CK_posedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI10_CK_negedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI11_CK_posedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI11_CK_negedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI12_CK_posedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI12_CK_negedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI13_CK_posedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI13_CK_negedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI14_CK_posedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI14_CK_negedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI15_CK_posedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI15_CK_negedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI16_CK_posedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI16_CK_negedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI17_CK_posedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI17_CK_negedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI18_CK_posedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI18_CK_negedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI19_CK_posedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI19_CK_negedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI20_CK_posedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI20_CK_negedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI21_CK_posedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI21_CK_negedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI22_CK_posedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI22_CK_negedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI23_CK_posedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI23_CK_negedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI24_CK_posedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI24_CK_negedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI25_CK_posedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI25_CK_negedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI26_CK_posedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI26_CK_negedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI27_CK_posedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI27_CK_negedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI28_CK_posedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI28_CK_negedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI29_CK_posedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI29_CK_negedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI30_CK_posedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI30_CK_negedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI31_CK_posedge_posedge    :  VitalDelayType := 0.528 ns;
      tsetup_DI31_CK_negedge_posedge    :  VitalDelayType := 0.528 ns;
      thold_DI0_CK_posedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI0_CK_negedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI1_CK_posedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI1_CK_negedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI2_CK_posedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI2_CK_negedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI3_CK_posedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI3_CK_negedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI4_CK_posedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI4_CK_negedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI5_CK_posedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI5_CK_negedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI6_CK_posedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI6_CK_negedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI7_CK_posedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI7_CK_negedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI8_CK_posedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI8_CK_negedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI9_CK_posedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI9_CK_negedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI10_CK_posedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI10_CK_negedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI11_CK_posedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI11_CK_negedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI12_CK_posedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI12_CK_negedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI13_CK_posedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI13_CK_negedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI14_CK_posedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI14_CK_negedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI15_CK_posedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI15_CK_negedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI16_CK_posedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI16_CK_negedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI17_CK_posedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI17_CK_negedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI18_CK_posedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI18_CK_negedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI19_CK_posedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI19_CK_negedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI20_CK_posedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI20_CK_negedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI21_CK_posedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI21_CK_negedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI22_CK_posedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI22_CK_negedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI23_CK_posedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI23_CK_negedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI24_CK_posedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI24_CK_negedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI25_CK_posedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI25_CK_negedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI26_CK_posedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI26_CK_negedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI27_CK_posedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI27_CK_negedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI28_CK_posedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI28_CK_negedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI29_CK_posedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI29_CK_negedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI30_CK_posedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI30_CK_negedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI31_CK_posedge_posedge     :  VitalDelayType := 0.100 ns;
      thold_DI31_CK_negedge_posedge     :  VitalDelayType := 0.100 ns;
      tsetup_WEB0_CK_posedge_posedge  :  VitalDelayType := 0.353 ns;
      tsetup_WEB0_CK_negedge_posedge  :  VitalDelayType := 0.353 ns;
      thold_WEB0_CK_posedge_posedge   :  VitalDelayType := 0.100 ns;
      thold_WEB0_CK_negedge_posedge   :  VitalDelayType := 0.100 ns;
      tsetup_WEB1_CK_posedge_posedge  :  VitalDelayType := 0.353 ns;
      tsetup_WEB1_CK_negedge_posedge  :  VitalDelayType := 0.353 ns;
      thold_WEB1_CK_posedge_posedge   :  VitalDelayType := 0.100 ns;
      thold_WEB1_CK_negedge_posedge   :  VitalDelayType := 0.100 ns;
      tsetup_WEB2_CK_posedge_posedge  :  VitalDelayType := 0.353 ns;
      tsetup_WEB2_CK_negedge_posedge  :  VitalDelayType := 0.353 ns;
      thold_WEB2_CK_posedge_posedge   :  VitalDelayType := 0.100 ns;
      thold_WEB2_CK_negedge_posedge   :  VitalDelayType := 0.100 ns;
      tsetup_WEB3_CK_posedge_posedge  :  VitalDelayType := 0.353 ns;
      tsetup_WEB3_CK_negedge_posedge  :  VitalDelayType := 0.353 ns;
      thold_WEB3_CK_posedge_posedge   :  VitalDelayType := 0.100 ns;
      thold_WEB3_CK_negedge_posedge   :  VitalDelayType := 0.100 ns;
      tsetup_CS_CK_posedge_posedge    :  VitalDelayType := 0.769 ns;
      tsetup_CS_CK_negedge_posedge    :  VitalDelayType := 0.769 ns;
      thold_CS_CK_posedge_posedge     :  VitalDelayType := 0.137 ns;
      thold_CS_CK_negedge_posedge     :  VitalDelayType := 0.137 ns;
      tperiod_CK                      :  VitalDelayType := 3.988 ns;
      tpw_CK_posedge                 :  VitalDelayType := 0.363 ns;
      tpw_CK_negedge                 :  VitalDelayType := 0.363 ns;
      tipd_A0                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A1                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A2                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A3                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A4                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A5                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A6                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A7                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A8                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A9                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A10                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A11                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A12                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DI0                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DI1                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DI2                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DI3                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DI4                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DI5                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DI6                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DI7                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DI8                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DI9                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DI10                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DI11                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DI12                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DI13                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DI14                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DI15                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DI16                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DI17                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DI18                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DI19                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DI20                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DI21                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DI22                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DI23                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DI24                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DI25                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DI26                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DI27                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DI28                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DI29                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DI30                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DI31                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_WEB0                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_WEB1                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_WEB2                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_WEB3                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_CS                        :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_CK                        :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_OE                        :  VitalDelayType01 := (0.000 ns, 0.000 ns)      
      );

   port(
      A0                         :   IN   std_logic;
      A1                         :   IN   std_logic;
      A2                         :   IN   std_logic;
      A3                         :   IN   std_logic;
      A4                         :   IN   std_logic;
      A5                         :   IN   std_logic;
      A6                         :   IN   std_logic;
      A7                         :   IN   std_logic;
      A8                         :   IN   std_logic;
      A9                         :   IN   std_logic;
      A10                         :   IN   std_logic;
      A11                         :   IN   std_logic;
      A12                         :   IN   std_logic;
      DO0                        :   OUT   std_logic;
      DO1                        :   OUT   std_logic;
      DO2                        :   OUT   std_logic;
      DO3                        :   OUT   std_logic;
      DO4                        :   OUT   std_logic;
      DO5                        :   OUT   std_logic;
      DO6                        :   OUT   std_logic;
      DO7                        :   OUT   std_logic;
      DO8                        :   OUT   std_logic;
      DO9                        :   OUT   std_logic;
      DO10                        :   OUT   std_logic;
      DO11                        :   OUT   std_logic;
      DO12                        :   OUT   std_logic;
      DO13                        :   OUT   std_logic;
      DO14                        :   OUT   std_logic;
      DO15                        :   OUT   std_logic;
      DO16                        :   OUT   std_logic;
      DO17                        :   OUT   std_logic;
      DO18                        :   OUT   std_logic;
      DO19                        :   OUT   std_logic;
      DO20                        :   OUT   std_logic;
      DO21                        :   OUT   std_logic;
      DO22                        :   OUT   std_logic;
      DO23                        :   OUT   std_logic;
      DO24                        :   OUT   std_logic;
      DO25                        :   OUT   std_logic;
      DO26                        :   OUT   std_logic;
      DO27                        :   OUT   std_logic;
      DO28                        :   OUT   std_logic;
      DO29                        :   OUT   std_logic;
      DO30                        :   OUT   std_logic;
      DO31                        :   OUT   std_logic;
      DI0                        :   IN   std_logic;
      DI1                        :   IN   std_logic;
      DI2                        :   IN   std_logic;
      DI3                        :   IN   std_logic;
      DI4                        :   IN   std_logic;
      DI5                        :   IN   std_logic;
      DI6                        :   IN   std_logic;
      DI7                        :   IN   std_logic;
      DI8                        :   IN   std_logic;
      DI9                        :   IN   std_logic;
      DI10                        :   IN   std_logic;
      DI11                        :   IN   std_logic;
      DI12                        :   IN   std_logic;
      DI13                        :   IN   std_logic;
      DI14                        :   IN   std_logic;
      DI15                        :   IN   std_logic;
      DI16                        :   IN   std_logic;
      DI17                        :   IN   std_logic;
      DI18                        :   IN   std_logic;
      DI19                        :   IN   std_logic;
      DI20                        :   IN   std_logic;
      DI21                        :   IN   std_logic;
      DI22                        :   IN   std_logic;
      DI23                        :   IN   std_logic;
      DI24                        :   IN   std_logic;
      DI25                        :   IN   std_logic;
      DI26                        :   IN   std_logic;
      DI27                        :   IN   std_logic;
      DI28                        :   IN   std_logic;
      DI29                        :   IN   std_logic;
      DI30                        :   IN   std_logic;
      DI31                        :   IN   std_logic;
      WEB0                       :   IN   std_logic;
      WEB1                       :   IN   std_logic;
      WEB2                       :   IN   std_logic;
      WEB3                       :   IN   std_logic;
      CK                            :   IN   std_logic;
      CS                           :   IN   std_logic;
      OE                            :   IN   std_logic
      );

attribute VITAL_LEVEL0 of SUMA180_8192X8X4BM2 : entity is TRUE;

end SUMA180_8192X8X4BM2;

-- architecture body --
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.VITAL_Primitives.all;
use IEEE.VITAL_Timing.all;

architecture behavior of SUMA180_8192X8X4BM2 is
   -- attribute VITALMEMORY_LEVEL1 of behavior : architecture is TRUE;

   CONSTANT True_flg:       integer := 0;
   CONSTANT False_flg:      integer := 1;
   CONSTANT Range_flg:      integer := 2;

   FUNCTION Minimum ( CONSTANT t1, t2 : IN TIME ) RETURN TIME IS
   BEGIN
      IF (t1 < t2) THEN RETURN (t1); ELSE RETURN (t2); END IF;
   END Minimum;

   FUNCTION Maximum ( CONSTANT t1, t2 : IN TIME ) RETURN TIME IS
   BEGIN
      IF (t1 < t2) THEN RETURN (t2); ELSE RETURN (t1); END IF;
   END Maximum;

   FUNCTION BVtoI(bin: std_logic_vector) RETURN integer IS
      variable result: integer;
   BEGIN
      result := 0;
      for i in bin'range loop
         if bin(i) = '1' then
            result := result + 2**i;
         end if;
      end loop;
      return result;
   END; -- BVtoI

   PROCEDURE ScheduleOutputDelay (
       SIGNAL   OutSignal        : OUT std_logic;
       VARIABLE Data             : IN  std_logic;
       CONSTANT Delay            : IN  VitalDelayType01 := VitalDefDelay01;
       VARIABLE Previous_A       : IN  std_logic_vector(AddressSize-1 downto 0);
       VARIABLE Current_A        : IN  std_logic_vector(AddressSize-1 downto 0);
       CONSTANT NO_SER_TOH       : IN  integer
   ) IS
   BEGIN

      if (NO_SER_TOH /= 1) then
         OutSignal <= TRANSPORT 'X' AFTER TOH;
         OutSignal <= TRANSPORT Data AFTER Maximum(Delay(tr10), Delay(tr01));
      else
         if (Current_A /= Previous_A) then
            OutSignal <= TRANSPORT 'X' AFTER TOH;
            OutSignal <= TRANSPORT Data AFTER Maximum(Delay(tr10), Delay(tr01));
         else
            OutSignal <= TRANSPORT Data AFTER Maximum(Delay(tr10), Delay(tr01));
         end if;
      end if;
   END ScheduleOutputDelay;

   FUNCTION TO_INTEGER (
     a: std_logic_vector
   ) RETURN INTEGER IS
     VARIABLE y: INTEGER := 0;
   BEGIN
        y := 0;
        FOR i IN a'RANGE LOOP
            y := y * 2;
            IF a(i) /= '1' AND a(i) /= '0' THEN
                y := 0;
                EXIT;
            ELSIF a(i) = '1' THEN
                y := y + 1;
            END IF;
        END LOOP;
        RETURN y;
   END TO_INTEGER;

   function AddressRangeCheck(AddressItem: std_logic_vector; flag_Address: integer) return integer is
     variable Uresult : std_logic;
     variable status  : integer := 0;

   begin
      if (Bits /= 1) then
         Uresult := AddressItem(0) xor AddressItem(1);
         for i in 2 to AddressItem'length-1 loop
            Uresult := Uresult xor AddressItem(i);
         end loop;
      else
         Uresult := AddressItem(0);
      end if;

      if (Uresult = 'U') then
         status := False_flg;
      elsif (Uresult = 'X') then
         status := False_flg;
      elsif (Uresult = 'Z') then
         status := False_flg;
      else
         status := True_flg;
      end if;

      if (status=False_flg) then
        if (flag_Address = True_flg) then
           -- Generate Error Messae --
           assert FALSE report "** MEM_Error: Unknown value occurred in Address." severity WARNING;
        end if;
      end if;

      if (status=True_flg) then
         if ((BVtoI(AddressItem)) >= Words) then
             assert FALSE report "** MEM_Error: Out of range occurred in Address." severity WARNING; 
             status := Range_flg;
         else
             status := True_flg;
         end if;
      end if;

      return status;
   end AddressRangeCheck;

   function CS_monitor(CSItem: std_logic; flag_CS: integer) return integer is
     variable status  : integer := 0;

   begin
      if (CSItem = 'U') then
         status := False_flg;
      elsif (CSItem = 'X') then
         status := False_flg;
      elsif (CSItem = 'Z') then
         status := False_flg;
      else
         status := True_flg;
      end if;

      if (status=False_flg) then
        if (flag_CS = True_flg) then
           -- Generate Error Messae --
           assert FALSE report "** MEM_Error: Unknown value occurred in ChipSelect." severity WARNING;
        end if;
      end if;

      return status;
   end CS_monitor;

   Type memoryArray Is array (Words-1 downto 0) Of std_logic_vector (Bits-1 downto 0);

   SIGNAL CS_ipd         : std_logic := 'X';
   SIGNAL OE_ipd         : std_logic := 'X';
   SIGNAL CK_ipd         : std_logic := 'X';
   SIGNAL A_ipd          : std_logic_vector(AddressSize-1 downto 0) := (others => 'X');
   SIGNAL WEB0_ipd       : std_logic := 'X';
   SIGNAL DI0_ipd        : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   SIGNAL DO0_int        : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   SIGNAL WEB1_ipd       : std_logic := 'X';
   SIGNAL DI1_ipd        : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   SIGNAL DO1_int        : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   SIGNAL WEB2_ipd       : std_logic := 'X';
   SIGNAL DI2_ipd        : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   SIGNAL DO2_int        : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   SIGNAL WEB3_ipd       : std_logic := 'X';
   SIGNAL DI3_ipd        : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   SIGNAL DO3_int        : std_logic_vector(Bits-1 downto 0) := (others => 'X');

begin

   ---------------------
   --  INPUT PATH DELAYs
   ---------------------
   WireDelay : block
   begin
   VitalWireDelay (OE_ipd, OE, tipd_OE);
   VitalWireDelay (CK_ipd, CK, tipd_CK);
   VitalWireDelay (CS_ipd, CS, tipd_CS);
   VitalWireDelay (WEB0_ipd, WEB0, tipd_WEB0);
   VitalWireDelay (WEB1_ipd, WEB1, tipd_WEB1);
   VitalWireDelay (WEB2_ipd, WEB2, tipd_WEB2);
   VitalWireDelay (WEB3_ipd, WEB3, tipd_WEB3);
   VitalWireDelay (A_ipd(0), A0, tipd_A0);
   VitalWireDelay (A_ipd(1), A1, tipd_A1);
   VitalWireDelay (A_ipd(2), A2, tipd_A2);
   VitalWireDelay (A_ipd(3), A3, tipd_A3);
   VitalWireDelay (A_ipd(4), A4, tipd_A4);
   VitalWireDelay (A_ipd(5), A5, tipd_A5);
   VitalWireDelay (A_ipd(6), A6, tipd_A6);
   VitalWireDelay (A_ipd(7), A7, tipd_A7);
   VitalWireDelay (A_ipd(8), A8, tipd_A8);
   VitalWireDelay (A_ipd(9), A9, tipd_A9);
   VitalWireDelay (A_ipd(10), A10, tipd_A10);
   VitalWireDelay (A_ipd(11), A11, tipd_A11);
   VitalWireDelay (A_ipd(12), A12, tipd_A12);
   VitalWireDelay (DI0_ipd(0), DI0, tipd_DI0);
   VitalWireDelay (DI0_ipd(1), DI1, tipd_DI1);
   VitalWireDelay (DI0_ipd(2), DI2, tipd_DI2);
   VitalWireDelay (DI0_ipd(3), DI3, tipd_DI3);
   VitalWireDelay (DI0_ipd(4), DI4, tipd_DI4);
   VitalWireDelay (DI0_ipd(5), DI5, tipd_DI5);
   VitalWireDelay (DI0_ipd(6), DI6, tipd_DI6);
   VitalWireDelay (DI0_ipd(7), DI7, tipd_DI7);
   VitalWireDelay (DI1_ipd(0), DI8, tipd_DI8);
   VitalWireDelay (DI1_ipd(1), DI9, tipd_DI9);
   VitalWireDelay (DI1_ipd(2), DI10, tipd_DI10);
   VitalWireDelay (DI1_ipd(3), DI11, tipd_DI11);
   VitalWireDelay (DI1_ipd(4), DI12, tipd_DI12);
   VitalWireDelay (DI1_ipd(5), DI13, tipd_DI13);
   VitalWireDelay (DI1_ipd(6), DI14, tipd_DI14);
   VitalWireDelay (DI1_ipd(7), DI15, tipd_DI15);
   VitalWireDelay (DI2_ipd(0), DI16, tipd_DI16);
   VitalWireDelay (DI2_ipd(1), DI17, tipd_DI17);
   VitalWireDelay (DI2_ipd(2), DI18, tipd_DI18);
   VitalWireDelay (DI2_ipd(3), DI19, tipd_DI19);
   VitalWireDelay (DI2_ipd(4), DI20, tipd_DI20);
   VitalWireDelay (DI2_ipd(5), DI21, tipd_DI21);
   VitalWireDelay (DI2_ipd(6), DI22, tipd_DI22);
   VitalWireDelay (DI2_ipd(7), DI23, tipd_DI23);
   VitalWireDelay (DI3_ipd(0), DI24, tipd_DI24);
   VitalWireDelay (DI3_ipd(1), DI25, tipd_DI25);
   VitalWireDelay (DI3_ipd(2), DI26, tipd_DI26);
   VitalWireDelay (DI3_ipd(3), DI27, tipd_DI27);
   VitalWireDelay (DI3_ipd(4), DI28, tipd_DI28);
   VitalWireDelay (DI3_ipd(5), DI29, tipd_DI29);
   VitalWireDelay (DI3_ipd(6), DI30, tipd_DI30);
   VitalWireDelay (DI3_ipd(7), DI31, tipd_DI31);

   end block;

   VitalBUFIF1 (q      => DO0,
                data   => DO0_int(0),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO0);
   VitalBUFIF1 (q      => DO1,
                data   => DO0_int(1),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO1);
   VitalBUFIF1 (q      => DO2,
                data   => DO0_int(2),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO2);
   VitalBUFIF1 (q      => DO3,
                data   => DO0_int(3),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO3);
   VitalBUFIF1 (q      => DO4,
                data   => DO0_int(4),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO4);
   VitalBUFIF1 (q      => DO5,
                data   => DO0_int(5),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO5);
   VitalBUFIF1 (q      => DO6,
                data   => DO0_int(6),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO6);
   VitalBUFIF1 (q      => DO7,
                data   => DO0_int(7),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO7);
   VitalBUFIF1 (q      => DO8,
                data   => DO1_int(0),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO8);
   VitalBUFIF1 (q      => DO9,
                data   => DO1_int(1),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO9);
   VitalBUFIF1 (q      => DO10,
                data   => DO1_int(2),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO10);
   VitalBUFIF1 (q      => DO11,
                data   => DO1_int(3),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO11);
   VitalBUFIF1 (q      => DO12,
                data   => DO1_int(4),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO12);
   VitalBUFIF1 (q      => DO13,
                data   => DO1_int(5),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO13);
   VitalBUFIF1 (q      => DO14,
                data   => DO1_int(6),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO14);
   VitalBUFIF1 (q      => DO15,
                data   => DO1_int(7),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO15);
   VitalBUFIF1 (q      => DO16,
                data   => DO2_int(0),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO16);
   VitalBUFIF1 (q      => DO17,
                data   => DO2_int(1),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO17);
   VitalBUFIF1 (q      => DO18,
                data   => DO2_int(2),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO18);
   VitalBUFIF1 (q      => DO19,
                data   => DO2_int(3),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO19);
   VitalBUFIF1 (q      => DO20,
                data   => DO2_int(4),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO20);
   VitalBUFIF1 (q      => DO21,
                data   => DO2_int(5),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO21);
   VitalBUFIF1 (q      => DO22,
                data   => DO2_int(6),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO22);
   VitalBUFIF1 (q      => DO23,
                data   => DO2_int(7),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO23);
   VitalBUFIF1 (q      => DO24,
                data   => DO3_int(0),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO24);
   VitalBUFIF1 (q      => DO25,
                data   => DO3_int(1),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO25);
   VitalBUFIF1 (q      => DO26,
                data   => DO3_int(2),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO26);
   VitalBUFIF1 (q      => DO27,
                data   => DO3_int(3),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO27);
   VitalBUFIF1 (q      => DO28,
                data   => DO3_int(4),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO28);
   VitalBUFIF1 (q      => DO29,
                data   => DO3_int(5),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO29);
   VitalBUFIF1 (q      => DO30,
                data   => DO3_int(6),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO30);
   VitalBUFIF1 (q      => DO31,
                data   => DO3_int(7),
                enable => OE_ipd,
                tpd_enable_q => tpd_OE_DO31);

   --------------------
   --  BEHAVIOR SECTION
   --------------------
   VITALBehavior : PROCESS (CS_ipd, 
                            OE_ipd,
                            A_ipd,
                            WEB0_ipd,
                            DI0_ipd,
                            WEB1_ipd,
                            DI1_ipd,
                            WEB2_ipd,
                            DI2_ipd,
                            WEB3_ipd,
                            DI3_ipd,
                            CK_ipd)

   -- timing check results
   VARIABLE Tviol_A_CK_posedge  : STD_ULOGIC := '0';
   VARIABLE Tviol_WEB0_CK_posedge  : STD_ULOGIC := '0';
   VARIABLE Tviol_DI0_CK_posedge  : STD_ULOGIC := '0';
   VARIABLE Tviol_WEB1_CK_posedge  : STD_ULOGIC := '0';
   VARIABLE Tviol_DI1_CK_posedge  : STD_ULOGIC := '0';
   VARIABLE Tviol_WEB2_CK_posedge  : STD_ULOGIC := '0';
   VARIABLE Tviol_DI2_CK_posedge  : STD_ULOGIC := '0';
   VARIABLE Tviol_WEB3_CK_posedge  : STD_ULOGIC := '0';
   VARIABLE Tviol_DI3_CK_posedge  : STD_ULOGIC := '0';
   VARIABLE Tviol_CS_CK_posedge  : STD_ULOGIC := '0';

   VARIABLE Pviol_CK    : STD_ULOGIC := '0';
   VARIABLE Pdata_CK    : VitalPeriodDataType := VitalPeriodDataInit;

   VARIABLE Tmkr_A_CK_posedge   : VitalTimingDataType := VitalTimingDataInit;
   VARIABLE Tmkr_WEB0_CK_posedge   : VitalTimingDataType := VitalTimingDataInit;
   VARIABLE Tmkr_DI0_CK_posedge   : VitalTimingDataType := VitalTimingDataInit;
   VARIABLE Tmkr_WEB1_CK_posedge   : VitalTimingDataType := VitalTimingDataInit;
   VARIABLE Tmkr_DI1_CK_posedge   : VitalTimingDataType := VitalTimingDataInit;
   VARIABLE Tmkr_WEB2_CK_posedge   : VitalTimingDataType := VitalTimingDataInit;
   VARIABLE Tmkr_DI2_CK_posedge   : VitalTimingDataType := VitalTimingDataInit;
   VARIABLE Tmkr_WEB3_CK_posedge   : VitalTimingDataType := VitalTimingDataInit;
   VARIABLE Tmkr_DI3_CK_posedge   : VitalTimingDataType := VitalTimingDataInit;
   VARIABLE Tmkr_CS_CK_posedge   : VitalTimingDataType := VitalTimingDataInit;

   VARIABLE DO0_zd : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   VARIABLE memoryCore0  : memoryArray;
   VARIABLE DO1_zd : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   VARIABLE memoryCore1  : memoryArray;
   VARIABLE DO2_zd : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   VARIABLE memoryCore2  : memoryArray;
   VARIABLE DO3_zd : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   VARIABLE memoryCore3  : memoryArray;

   VARIABLE ck_change   : std_logic_vector(1 downto 0);
   VARIABLE web0_cs      : std_logic_vector(1 downto 0);
   VARIABLE web1_cs      : std_logic_vector(1 downto 0);
   VARIABLE web2_cs      : std_logic_vector(1 downto 0);
   VARIABLE web3_cs      : std_logic_vector(1 downto 0);

   -- previous latch data
   VARIABLE Latch_A        : std_logic_vector(AddressSize-1 downto 0) := (others => 'X');
   VARIABLE Latch_DI0       : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   VARIABLE Latch_WEB0      : std_logic := 'X';
   VARIABLE Latch_DI1       : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   VARIABLE Latch_WEB1      : std_logic := 'X';
   VARIABLE Latch_DI2       : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   VARIABLE Latch_WEB2      : std_logic := 'X';
   VARIABLE Latch_DI3       : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   VARIABLE Latch_WEB3      : std_logic := 'X';
   VARIABLE Latch_CS       : std_logic := 'X';

   -- internal latch data
   VARIABLE A_i            : std_logic_vector(AddressSize-1 downto 0) := (others => 'X');
   VARIABLE DI0_i           : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   VARIABLE WEB0_i          : std_logic := 'X';
   VARIABLE DI1_i           : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   VARIABLE WEB1_i          : std_logic := 'X';
   VARIABLE DI2_i           : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   VARIABLE WEB2_i          : std_logic := 'X';
   VARIABLE DI3_i           : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   VARIABLE WEB3_i          : std_logic := 'X';
   VARIABLE CS_i           : std_logic := 'X';

   VARIABLE last_A         : std_logic_vector(AddressSize-1 downto 0) := (others => 'X');

   VARIABLE LastClkEdge    : std_logic := 'X';

   VARIABLE flag_A: integer   := True_flg;
   VARIABLE flag_CS: integer   := True_flg;

   begin

   ------------------------
   --  Timing Check Section
   ------------------------
   if (TimingChecksOn) then
         VitalSetupHoldCheck (
          Violation               => Tviol_A_CK_posedge,
          TimingData              => Tmkr_A_CK_posedge,
          TestSignal              => A_ipd,
          TestSignalName          => "A",
          TestDelay               => 0 ns,
          RefSignal               => CK_ipd,
          RefSignalName           => "CK",
          RefDelay                => 0 ns,
          SetupHigh               => tsetup_A0_CK_posedge_posedge,
          SetupLow                => tsetup_A0_CK_negedge_posedge,
          HoldHigh                => thold_A0_CK_negedge_posedge,
          HoldLow                 => thold_A0_CK_posedge_posedge,
          CheckEnabled            =>
                           NOW /= 0 ns AND CS_ipd = '1',
          RefTransition           => 'R',
          HeaderMsg               => InstancePath & "/SUMA180_8192X8X4BM2",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);

         VitalSetupHoldCheck (
          Violation               => Tviol_WEB0_CK_posedge,
          TimingData              => Tmkr_WEB0_CK_posedge,
          TestSignal              => WEB0_ipd,
          TestSignalName          => "WEB0",
          TestDelay               => 0 ns,
          RefSignal               => CK_ipd,
          RefSignalName           => "CK",
          RefDelay                => 0 ns,
          SetupHigh               => tsetup_WEB0_CK_posedge_posedge,
          SetupLow                => tsetup_WEB0_CK_negedge_posedge,
          HoldHigh                => thold_WEB0_CK_negedge_posedge,
          HoldLow                 => thold_WEB0_CK_posedge_posedge,
          CheckEnabled            =>
                           NOW /= 0 ns AND CS_ipd = '1',
          RefTransition           => 'R',
          HeaderMsg               => InstancePath & "/SUMA180_8192X8X4BM2",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);
         VitalSetupHoldCheck (
          Violation               => Tviol_WEB1_CK_posedge,
          TimingData              => Tmkr_WEB1_CK_posedge,
          TestSignal              => WEB1_ipd,
          TestSignalName          => "WEB1",
          TestDelay               => 0 ns,
          RefSignal               => CK_ipd,
          RefSignalName           => "CK",
          RefDelay                => 0 ns,
          SetupHigh               => tsetup_WEB1_CK_posedge_posedge,
          SetupLow                => tsetup_WEB1_CK_negedge_posedge,
          HoldHigh                => thold_WEB1_CK_negedge_posedge,
          HoldLow                 => thold_WEB1_CK_posedge_posedge,
          CheckEnabled            =>
                           NOW /= 0 ns AND CS_ipd = '1',
          RefTransition           => 'R',
          HeaderMsg               => InstancePath & "/SUMA180_8192X8X4BM2",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);
         VitalSetupHoldCheck (
          Violation               => Tviol_WEB2_CK_posedge,
          TimingData              => Tmkr_WEB2_CK_posedge,
          TestSignal              => WEB2_ipd,
          TestSignalName          => "WEB2",
          TestDelay               => 0 ns,
          RefSignal               => CK_ipd,
          RefSignalName           => "CK",
          RefDelay                => 0 ns,
          SetupHigh               => tsetup_WEB2_CK_posedge_posedge,
          SetupLow                => tsetup_WEB2_CK_negedge_posedge,
          HoldHigh                => thold_WEB2_CK_negedge_posedge,
          HoldLow                 => thold_WEB2_CK_posedge_posedge,
          CheckEnabled            =>
                           NOW /= 0 ns AND CS_ipd = '1',
          RefTransition           => 'R',
          HeaderMsg               => InstancePath & "/SUMA180_8192X8X4BM2",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);
         VitalSetupHoldCheck (
          Violation               => Tviol_WEB3_CK_posedge,
          TimingData              => Tmkr_WEB3_CK_posedge,
          TestSignal              => WEB3_ipd,
          TestSignalName          => "WEB3",
          TestDelay               => 0 ns,
          RefSignal               => CK_ipd,
          RefSignalName           => "CK",
          RefDelay                => 0 ns,
          SetupHigh               => tsetup_WEB3_CK_posedge_posedge,
          SetupLow                => tsetup_WEB3_CK_negedge_posedge,
          HoldHigh                => thold_WEB3_CK_negedge_posedge,
          HoldLow                 => thold_WEB3_CK_posedge_posedge,
          CheckEnabled            =>
                           NOW /= 0 ns AND CS_ipd = '1',
          RefTransition           => 'R',
          HeaderMsg               => InstancePath & "/SUMA180_8192X8X4BM2",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);

         VitalSetupHoldCheck (
          Violation               => Tviol_DI0_CK_posedge,
          TimingData              => Tmkr_DI0_CK_posedge,
          TestSignal              => DI0_ipd,
          TestSignalName          => "DI",
          TestDelay               => 0 ns,
          RefSignal               => CK_ipd,
          RefSignalName           => "CK",
          RefDelay                => 0 ns,
          SetupHigh               => tsetup_DI0_CK_posedge_posedge,
          SetupLow                => tsetup_DI0_CK_negedge_posedge,
          HoldHigh                => thold_DI0_CK_negedge_posedge,
          HoldLow                 => thold_DI0_CK_posedge_posedge,
          CheckEnabled            =>
                           NOW /= 0 ns AND CS_ipd = '1' AND WEB0_ipd /= '1',
          RefTransition           => 'R',
          HeaderMsg               => InstancePath & "/SUMA180_8192X8X4BM2",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);
         VitalSetupHoldCheck (
          Violation               => Tviol_DI1_CK_posedge,
          TimingData              => Tmkr_DI1_CK_posedge,
          TestSignal              => DI1_ipd,
          TestSignalName          => "DI",
          TestDelay               => 0 ns,
          RefSignal               => CK_ipd,
          RefSignalName           => "CK",
          RefDelay                => 0 ns,
          SetupHigh               => tsetup_DI0_CK_posedge_posedge,
          SetupLow                => tsetup_DI0_CK_negedge_posedge,
          HoldHigh                => thold_DI0_CK_negedge_posedge,
          HoldLow                 => thold_DI0_CK_posedge_posedge,
          CheckEnabled            =>
                           NOW /= 0 ns AND CS_ipd = '1' AND WEB1_ipd /= '1',
          RefTransition           => 'R',
          HeaderMsg               => InstancePath & "/SUMA180_8192X8X4BM2",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);
         VitalSetupHoldCheck (
          Violation               => Tviol_DI2_CK_posedge,
          TimingData              => Tmkr_DI2_CK_posedge,
          TestSignal              => DI2_ipd,
          TestSignalName          => "DI",
          TestDelay               => 0 ns,
          RefSignal               => CK_ipd,
          RefSignalName           => "CK",
          RefDelay                => 0 ns,
          SetupHigh               => tsetup_DI0_CK_posedge_posedge,
          SetupLow                => tsetup_DI0_CK_negedge_posedge,
          HoldHigh                => thold_DI0_CK_negedge_posedge,
          HoldLow                 => thold_DI0_CK_posedge_posedge,
          CheckEnabled            =>
                           NOW /= 0 ns AND CS_ipd = '1' AND WEB2_ipd /= '1',
          RefTransition           => 'R',
          HeaderMsg               => InstancePath & "/SUMA180_8192X8X4BM2",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);
         VitalSetupHoldCheck (
          Violation               => Tviol_DI3_CK_posedge,
          TimingData              => Tmkr_DI3_CK_posedge,
          TestSignal              => DI3_ipd,
          TestSignalName          => "DI",
          TestDelay               => 0 ns,
          RefSignal               => CK_ipd,
          RefSignalName           => "CK",
          RefDelay                => 0 ns,
          SetupHigh               => tsetup_DI0_CK_posedge_posedge,
          SetupLow                => tsetup_DI0_CK_negedge_posedge,
          HoldHigh                => thold_DI0_CK_negedge_posedge,
          HoldLow                 => thold_DI0_CK_posedge_posedge,
          CheckEnabled            =>
                           NOW /= 0 ns AND CS_ipd = '1' AND WEB3_ipd /= '1',
          RefTransition           => 'R',
          HeaderMsg               => InstancePath & "/SUMA180_8192X8X4BM2",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);

         VitalSetupHoldCheck (
          Violation               => Tviol_CS_CK_posedge,
          TimingData              => Tmkr_CS_CK_posedge,
          TestSignal              => CS_ipd,
          TestSignalName          => "CS",
          TestDelay               => 0 ns,
          RefSignal               => CK_ipd,
          RefSignalName           => "CK",
          RefDelay                => 0 ns,
          SetupHigh               => tsetup_CS_CK_posedge_posedge,
          SetupLow                => tsetup_CS_CK_negedge_posedge,
          HoldHigh                => thold_CS_CK_negedge_posedge,
          HoldLow                 => thold_CS_CK_posedge_posedge,
          CheckEnabled            => NOW /= 0 ns,
          RefTransition           => 'R',
          HeaderMsg               => InstancePath & "/SUMA180_8192X8X4BM2",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);

         VitalPeriodPulseCheck (
          Violation               => Pviol_CK,
          PeriodData              => Pdata_CK,
          TestSignal              => CK_ipd,
          TestSignalName          => "CK",
          TestDelay               => 0 ns,
          Period                  => tperiod_CK,
          PulseWidthHigh          => tpw_CK_posedge,
          PulseWidthLow           => tpw_CK_negedge,
          CheckEnabled            => NOW /= 0 ns AND CS_ipd = '1',
          HeaderMsg               => InstancePath & "/SUMA180_8192X8X4BM2",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);
   end if;

   -------------------------
   --  Functionality Section
   -------------------------

       if (CS_ipd = '1' and CS_ipd'event) then
          if (SYN_CS = 0) then
             DO0_zd := (OTHERS => 'X');
             DO0_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
             DO1_zd := (OTHERS => 'X');
             DO1_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
             DO2_zd := (OTHERS => 'X');
             DO2_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
             DO3_zd := (OTHERS => 'X');
             DO3_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
          end if;
       end if;

       if (CK_ipd'event) then
         ck_change := LastClkEdge&CK_ipd;
         case ck_change is
            when "01"   =>
                if (CS_monitor(CS_ipd,flag_CS) = True_flg) then
                   -- Reduce error message --
                   flag_CS := True_flg;
                else
                   flag_CS := False_flg;
                end if;

                Latch_A    := A_ipd;
                Latch_CS   := CS_ipd;
                Latch_DI0  := DI0_ipd;
                Latch_WEB0 := WEB0_ipd;
                Latch_DI1  := DI1_ipd;
                Latch_WEB1 := WEB1_ipd;
                Latch_DI2  := DI2_ipd;
                Latch_WEB2 := WEB2_ipd;
                Latch_DI3  := DI3_ipd;
                Latch_WEB3 := WEB3_ipd;

                -- memory_function
                A_i    := Latch_A;
                CS_i   := Latch_CS;
                DI0_i  := Latch_DI0;
                WEB0_i := Latch_WEB0;
                DI1_i  := Latch_DI1;
                WEB1_i := Latch_WEB1;
                DI2_i  := Latch_DI2;
                WEB2_i := Latch_WEB2;
                DI3_i  := Latch_DI3;
                WEB3_i := Latch_WEB3;


                web0_cs    := WEB0_i&CS_i;
                case web0_cs is
                   when "11" => 
                       -------- Reduce error message --------------------------
                       if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                           -- Reduce error message --
                           flag_A := True_flg;
                           --------------------------
                           DO0_zd := memoryCore0(to_integer(A_i));
                           ScheduleOutputDelay(DO0_int(0), DO0_zd(0),
                              tpd_CK_DO0_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO0_int(1), DO0_zd(1),
                              tpd_CK_DO1_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO0_int(2), DO0_zd(2),
                              tpd_CK_DO2_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO0_int(3), DO0_zd(3),
                              tpd_CK_DO3_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO0_int(4), DO0_zd(4),
                              tpd_CK_DO4_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO0_int(5), DO0_zd(5),
                              tpd_CK_DO5_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO0_int(6), DO0_zd(6),
                              tpd_CK_DO6_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO0_int(7), DO0_zd(7),
                              tpd_CK_DO7_posedge,last_A,A_i,NO_SER_TOH);
                       else
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           DO0_zd := (OTHERS => 'X');
                           DO0_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                       end if;

                   when "01" => 
                       if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                           -- Reduce error message --
                           flag_A := True_flg;
                           --------------------------
                           memoryCore0(to_integer(A_i)) := DI0_i;
                           DO0_zd := memoryCore0(to_integer(A_i));
                           ScheduleOutputDelay(DO0_int(0), DO0_zd(0),
                              tpd_CK_DO0_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO0_int(1), DO0_zd(1),
                              tpd_CK_DO1_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO0_int(2), DO0_zd(2),
                              tpd_CK_DO2_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO0_int(3), DO0_zd(3),
                              tpd_CK_DO3_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO0_int(4), DO0_zd(4),
                              tpd_CK_DO4_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO0_int(5), DO0_zd(5),
                              tpd_CK_DO5_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO0_int(6), DO0_zd(6),
                              tpd_CK_DO6_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO0_int(7), DO0_zd(7),
                              tpd_CK_DO7_posedge,last_A,A_i,NO_SER_TOH);
                       elsif (AddressRangeCheck(A_i,flag_A) = Range_flg) then
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           DO0_zd := (OTHERS => 'X');
                           DO0_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                       else
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           DO0_zd := (OTHERS => 'X');
                           DO0_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                           FOR i IN Words-1 downto 0 LOOP
                              memoryCore0(i) := (OTHERS => 'X');
                           END LOOP;
                       end if;

                   when "1X" |
                        "1U" |
                        "1Z" => DO0_zd := (OTHERS => 'X');
                                DO0_int <= TRANSPORT (OTHERS => 'X') AFTER TOH; 
                   when "10" |
                        "00" |
                        "X0" |
                        "U0" |
                        "Z0"   => -- do nothing
                   when others =>
                                if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                                   -- Reduce error message --
                                   flag_A := True_flg;
                                   --------------------------
                                   memoryCore0(to_integer(A_i)) := (OTHERS => 'X');
                                   DO0_zd := (OTHERS => 'X');
                                   DO0_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                                elsif (AddressRangeCheck(A_i,flag_A) = Range_flg) then
                                    -- Reduce error message --
                                    flag_A := False_flg;
                                    --------------------------
                                    DO0_zd := (OTHERS => 'X');
                                    DO0_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                                else
                                   -- Reduce error message --
                                   flag_A := False_flg;
                                   --------------------------
                                   DO0_zd := (OTHERS => 'X');
                                   DO0_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                                   FOR i IN Words-1 downto 0 LOOP
                                      memoryCore0(i) := (OTHERS => 'X');
                                   END LOOP;
                                end if;
                end case;


                web1_cs    := WEB1_i&CS_i;
                case web1_cs is
                   when "11" => 
                       -------- Reduce error message --------------------------
                       if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                           -- Reduce error message --
                           flag_A := True_flg;
                           --------------------------
                           DO1_zd := memoryCore1(to_integer(A_i));
                           ScheduleOutputDelay(DO1_int(0), DO1_zd(0),
                              tpd_CK_DO8_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO1_int(1), DO1_zd(1),
                              tpd_CK_DO9_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO1_int(2), DO1_zd(2),
                              tpd_CK_DO10_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO1_int(3), DO1_zd(3),
                              tpd_CK_DO11_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO1_int(4), DO1_zd(4),
                              tpd_CK_DO12_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO1_int(5), DO1_zd(5),
                              tpd_CK_DO13_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO1_int(6), DO1_zd(6),
                              tpd_CK_DO14_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO1_int(7), DO1_zd(7),
                              tpd_CK_DO15_posedge,last_A,A_i,NO_SER_TOH);
                       else
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           DO1_zd := (OTHERS => 'X');
                           DO1_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                       end if;

                   when "01" => 
                       if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                           -- Reduce error message --
                           flag_A := True_flg;
                           --------------------------
                           memoryCore1(to_integer(A_i)) := DI1_i;
                           DO1_zd := memoryCore1(to_integer(A_i));
                           ScheduleOutputDelay(DO1_int(0), DO1_zd(0),
                              tpd_CK_DO8_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO1_int(1), DO1_zd(1),
                              tpd_CK_DO9_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO1_int(2), DO1_zd(2),
                              tpd_CK_DO10_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO1_int(3), DO1_zd(3),
                              tpd_CK_DO11_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO1_int(4), DO1_zd(4),
                              tpd_CK_DO12_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO1_int(5), DO1_zd(5),
                              tpd_CK_DO13_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO1_int(6), DO1_zd(6),
                              tpd_CK_DO14_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO1_int(7), DO1_zd(7),
                              tpd_CK_DO15_posedge,last_A,A_i,NO_SER_TOH);
                       elsif (AddressRangeCheck(A_i,flag_A) = Range_flg) then
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           DO1_zd := (OTHERS => 'X');
                           DO1_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                       else
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           DO1_zd := (OTHERS => 'X');
                           DO1_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                           FOR i IN Words-1 downto 0 LOOP
                              memoryCore1(i) := (OTHERS => 'X');
                           END LOOP;
                       end if;

                   when "1X" |
                        "1U" |
                        "1Z" => DO1_zd := (OTHERS => 'X');
                                DO1_int <= TRANSPORT (OTHERS => 'X') AFTER TOH; 
                   when "10" |
                        "00" |
                        "X0" |
                        "U0" |
                        "Z0"   => -- do nothing
                   when others =>
                                if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                                   -- Reduce error message --
                                   flag_A := True_flg;
                                   --------------------------
                                   memoryCore1(to_integer(A_i)) := (OTHERS => 'X');
                                   DO1_zd := (OTHERS => 'X');
                                   DO1_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                                elsif (AddressRangeCheck(A_i,flag_A) = Range_flg) then
                                    -- Reduce error message --
                                    flag_A := False_flg;
                                    --------------------------
                                    DO1_zd := (OTHERS => 'X');
                                    DO1_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                                else
                                   -- Reduce error message --
                                   flag_A := False_flg;
                                   --------------------------
                                   DO1_zd := (OTHERS => 'X');
                                   DO1_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                                   FOR i IN Words-1 downto 0 LOOP
                                      memoryCore1(i) := (OTHERS => 'X');
                                   END LOOP;
                                end if;
                end case;


                web2_cs    := WEB2_i&CS_i;
                case web2_cs is
                   when "11" => 
                       -------- Reduce error message --------------------------
                       if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                           -- Reduce error message --
                           flag_A := True_flg;
                           --------------------------
                           DO2_zd := memoryCore2(to_integer(A_i));
                           ScheduleOutputDelay(DO2_int(0), DO2_zd(0),
                              tpd_CK_DO16_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO2_int(1), DO2_zd(1),
                              tpd_CK_DO17_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO2_int(2), DO2_zd(2),
                              tpd_CK_DO18_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO2_int(3), DO2_zd(3),
                              tpd_CK_DO19_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO2_int(4), DO2_zd(4),
                              tpd_CK_DO20_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO2_int(5), DO2_zd(5),
                              tpd_CK_DO21_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO2_int(6), DO2_zd(6),
                              tpd_CK_DO22_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO2_int(7), DO2_zd(7),
                              tpd_CK_DO23_posedge,last_A,A_i,NO_SER_TOH);
                       else
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           DO2_zd := (OTHERS => 'X');
                           DO2_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                       end if;

                   when "01" => 
                       if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                           -- Reduce error message --
                           flag_A := True_flg;
                           --------------------------
                           memoryCore2(to_integer(A_i)) := DI2_i;
                           DO2_zd := memoryCore2(to_integer(A_i));
                           ScheduleOutputDelay(DO2_int(0), DO2_zd(0),
                              tpd_CK_DO16_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO2_int(1), DO2_zd(1),
                              tpd_CK_DO17_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO2_int(2), DO2_zd(2),
                              tpd_CK_DO18_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO2_int(3), DO2_zd(3),
                              tpd_CK_DO19_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO2_int(4), DO2_zd(4),
                              tpd_CK_DO20_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO2_int(5), DO2_zd(5),
                              tpd_CK_DO21_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO2_int(6), DO2_zd(6),
                              tpd_CK_DO22_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO2_int(7), DO2_zd(7),
                              tpd_CK_DO23_posedge,last_A,A_i,NO_SER_TOH);
                       elsif (AddressRangeCheck(A_i,flag_A) = Range_flg) then
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           DO2_zd := (OTHERS => 'X');
                           DO2_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                       else
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           DO2_zd := (OTHERS => 'X');
                           DO2_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                           FOR i IN Words-1 downto 0 LOOP
                              memoryCore2(i) := (OTHERS => 'X');
                           END LOOP;
                       end if;

                   when "1X" |
                        "1U" |
                        "1Z" => DO2_zd := (OTHERS => 'X');
                                DO2_int <= TRANSPORT (OTHERS => 'X') AFTER TOH; 
                   when "10" |
                        "00" |
                        "X0" |
                        "U0" |
                        "Z0"   => -- do nothing
                   when others =>
                                if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                                   -- Reduce error message --
                                   flag_A := True_flg;
                                   --------------------------
                                   memoryCore2(to_integer(A_i)) := (OTHERS => 'X');
                                   DO2_zd := (OTHERS => 'X');
                                   DO2_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                                elsif (AddressRangeCheck(A_i,flag_A) = Range_flg) then
                                    -- Reduce error message --
                                    flag_A := False_flg;
                                    --------------------------
                                    DO2_zd := (OTHERS => 'X');
                                    DO2_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                                else
                                   -- Reduce error message --
                                   flag_A := False_flg;
                                   --------------------------
                                   DO2_zd := (OTHERS => 'X');
                                   DO2_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                                   FOR i IN Words-1 downto 0 LOOP
                                      memoryCore2(i) := (OTHERS => 'X');
                                   END LOOP;
                                end if;
                end case;


                web3_cs    := WEB3_i&CS_i;
                case web3_cs is
                   when "11" => 
                       -------- Reduce error message --------------------------
                       if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                           -- Reduce error message --
                           flag_A := True_flg;
                           --------------------------
                           DO3_zd := memoryCore3(to_integer(A_i));
                           ScheduleOutputDelay(DO3_int(0), DO3_zd(0),
                              tpd_CK_DO24_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO3_int(1), DO3_zd(1),
                              tpd_CK_DO25_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO3_int(2), DO3_zd(2),
                              tpd_CK_DO26_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO3_int(3), DO3_zd(3),
                              tpd_CK_DO27_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO3_int(4), DO3_zd(4),
                              tpd_CK_DO28_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO3_int(5), DO3_zd(5),
                              tpd_CK_DO29_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO3_int(6), DO3_zd(6),
                              tpd_CK_DO30_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO3_int(7), DO3_zd(7),
                              tpd_CK_DO31_posedge,last_A,A_i,NO_SER_TOH);
                       else
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           DO3_zd := (OTHERS => 'X');
                           DO3_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                       end if;

                   when "01" => 
                       if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                           -- Reduce error message --
                           flag_A := True_flg;
                           --------------------------
                           memoryCore3(to_integer(A_i)) := DI3_i;
                           DO3_zd := memoryCore3(to_integer(A_i));
                           ScheduleOutputDelay(DO3_int(0), DO3_zd(0),
                              tpd_CK_DO24_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO3_int(1), DO3_zd(1),
                              tpd_CK_DO25_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO3_int(2), DO3_zd(2),
                              tpd_CK_DO26_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO3_int(3), DO3_zd(3),
                              tpd_CK_DO27_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO3_int(4), DO3_zd(4),
                              tpd_CK_DO28_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO3_int(5), DO3_zd(5),
                              tpd_CK_DO29_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO3_int(6), DO3_zd(6),
                              tpd_CK_DO30_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO3_int(7), DO3_zd(7),
                              tpd_CK_DO31_posedge,last_A,A_i,NO_SER_TOH);
                       elsif (AddressRangeCheck(A_i,flag_A) = Range_flg) then
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           DO3_zd := (OTHERS => 'X');
                           DO3_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                       else
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           DO3_zd := (OTHERS => 'X');
                           DO3_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                           FOR i IN Words-1 downto 0 LOOP
                              memoryCore3(i) := (OTHERS => 'X');
                           END LOOP;
                       end if;

                   when "1X" |
                        "1U" |
                        "1Z" => DO3_zd := (OTHERS => 'X');
                                DO3_int <= TRANSPORT (OTHERS => 'X') AFTER TOH; 
                   when "10" |
                        "00" |
                        "X0" |
                        "U0" |
                        "Z0"   => -- do nothing
                   when others =>
                                if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                                   -- Reduce error message --
                                   flag_A := True_flg;
                                   --------------------------
                                   memoryCore3(to_integer(A_i)) := (OTHERS => 'X');
                                   DO3_zd := (OTHERS => 'X');
                                   DO3_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                                elsif (AddressRangeCheck(A_i,flag_A) = Range_flg) then
                                    -- Reduce error message --
                                    flag_A := False_flg;
                                    --------------------------
                                    DO3_zd := (OTHERS => 'X');
                                    DO3_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                                else
                                   -- Reduce error message --
                                   flag_A := False_flg;
                                   --------------------------
                                   DO3_zd := (OTHERS => 'X');
                                   DO3_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                                   FOR i IN Words-1 downto 0 LOOP
                                      memoryCore3(i) := (OTHERS => 'X');
                                   END LOOP;
                                end if;
                end case;

                -- end memory_function
                last_A := A_ipd;

            when "10"   => -- do nothing
            when others => if (NOW /= 0 ns) then
                              assert FALSE report "** MEM_Error: Abnormal transition occurred." severity WARNING;
                           end if;
                           if (CS_ipd /= '1') then
                              DO0_zd := (OTHERS => 'X');
                              DO0_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                              if (WEB0_ipd /= '1') then
                                 FOR i IN Words-1 downto 0 LOOP
                                    memoryCore0(i) := (OTHERS => 'X');
                                 END LOOP;
                              end if;
                              DO1_zd := (OTHERS => 'X');
                              DO1_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                              if (WEB1_ipd /= '1') then
                                 FOR i IN Words-1 downto 0 LOOP
                                    memoryCore1(i) := (OTHERS => 'X');
                                 END LOOP;
                              end if;
                              DO2_zd := (OTHERS => 'X');
                              DO2_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                              if (WEB2_ipd /= '1') then
                                 FOR i IN Words-1 downto 0 LOOP
                                    memoryCore2(i) := (OTHERS => 'X');
                                 END LOOP;
                              end if;
                              DO3_zd := (OTHERS => 'X');
                              DO3_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                              if (WEB3_ipd /= '1') then
                                 FOR i IN Words-1 downto 0 LOOP
                                    memoryCore3(i) := (OTHERS => 'X');
                                 END LOOP;
                              end if;
                           end if;
         end case;

         LastClkEdge := CK_ipd;
       end if;

       if (Tviol_A_CK_posedge     = 'X' or
           Tviol_WEB0_CK_posedge  = 'X' or
           Tviol_DI0_CK_posedge   = 'X' or
           Tviol_WEB1_CK_posedge  = 'X' or
           Tviol_DI1_CK_posedge   = 'X' or
           Tviol_WEB2_CK_posedge  = 'X' or
           Tviol_DI2_CK_posedge   = 'X' or
           Tviol_WEB3_CK_posedge  = 'X' or
           Tviol_DI3_CK_posedge   = 'X' or
           Tviol_CS_CK_posedge    = 'X' or
           Pviol_CK               = 'X'
          ) then

         if (Pviol_CK = 'X') then
            if (CS_ipd /= '0') then
               DO0_zd := (OTHERS => 'X');
               DO0_int <= TRANSPORT (OTHERS => 'X');
               if (WEB0_ipd /= '1') then
                  FOR i IN Words-1 downto 0 LOOP
                     memoryCore0(i) := (OTHERS => 'X');
                  END LOOP;
               end if;
               DO1_zd := (OTHERS => 'X');
               DO1_int <= TRANSPORT (OTHERS => 'X');
               if (WEB1_ipd /= '1') then
                  FOR i IN Words-1 downto 0 LOOP
                     memoryCore1(i) := (OTHERS => 'X');
                  END LOOP;
               end if;
               DO2_zd := (OTHERS => 'X');
               DO2_int <= TRANSPORT (OTHERS => 'X');
               if (WEB2_ipd /= '1') then
                  FOR i IN Words-1 downto 0 LOOP
                     memoryCore2(i) := (OTHERS => 'X');
                  END LOOP;
               end if;
               DO3_zd := (OTHERS => 'X');
               DO3_int <= TRANSPORT (OTHERS => 'X');
               if (WEB3_ipd /= '1') then
                  FOR i IN Words-1 downto 0 LOOP
                     memoryCore3(i) := (OTHERS => 'X');
                  END LOOP;
               end if;
            end if;
         else
            FOR i IN AddressSize-1 downto 0 LOOP
              if (Tviol_A_CK_posedge = 'X') then
                 Latch_A(i) := 'X';
              else
                 Latch_A(i) := Latch_A(i);
              end if;
            END LOOP;
            FOR i IN Bits-1 downto 0 LOOP
              if (Tviol_DI0_CK_posedge = 'X') then
                 Latch_DI0(i) := 'X';
              else
                 Latch_DI0(i) := Latch_DI0(i);
              end if;
              if (Tviol_DI1_CK_posedge = 'X') then
                 Latch_DI1(i) := 'X';
              else
                 Latch_DI1(i) := Latch_DI1(i);
              end if;
              if (Tviol_DI2_CK_posedge = 'X') then
                 Latch_DI2(i) := 'X';
              else
                 Latch_DI2(i) := Latch_DI2(i);
              end if;
              if (Tviol_DI3_CK_posedge = 'X') then
                 Latch_DI3(i) := 'X';
              else
                 Latch_DI3(i) := Latch_DI3(i);
              end if;
            END LOOP;
            if (Tviol_WEB0_CK_posedge = 'X') then
               Latch_WEB0 := 'X';
            else
               Latch_WEB0 := Latch_WEB0;
            end if;
            if (Tviol_WEB0_CK_posedge = 'X') then
               Latch_WEB1 := 'X';
            else
               Latch_WEB1 := Latch_WEB1;
            end if;
            if (Tviol_WEB0_CK_posedge = 'X') then
               Latch_WEB2 := 'X';
            else
               Latch_WEB2 := Latch_WEB2;
            end if;
            if (Tviol_WEB0_CK_posedge = 'X') then
               Latch_WEB3 := 'X';
            else
               Latch_WEB3 := Latch_WEB3;
            end if;
            if (Tviol_CS_CK_posedge = 'X') then
               Latch_CS := 'X';
            else
               Latch_CS := Latch_CS;
            end if;

                -- memory_function
                A_i    := Latch_A;
                CS_i   := Latch_CS;
                DI0_i  := Latch_DI0;
                WEB0_i := Latch_WEB0;
                DI1_i  := Latch_DI1;
                WEB1_i := Latch_WEB1;
                DI2_i  := Latch_DI2;
                WEB2_i := Latch_WEB2;
                DI3_i  := Latch_DI3;
                WEB3_i := Latch_WEB3;


                web0_cs    := WEB0_i&CS_i;
                case web0_cs is
                   when "11" => 
                       -------- Reduce error message --------------------------
                       if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                           -- Reduce error message --
                           flag_A := True_flg;
                           --------------------------
                           DO0_zd := memoryCore0(to_integer(A_i));
                           ScheduleOutputDelay(DO0_int(0), DO0_zd(0),
                              tpd_CK_DO0_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO0_int(1), DO0_zd(1),
                              tpd_CK_DO1_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO0_int(2), DO0_zd(2),
                              tpd_CK_DO2_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO0_int(3), DO0_zd(3),
                              tpd_CK_DO3_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO0_int(4), DO0_zd(4),
                              tpd_CK_DO4_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO0_int(5), DO0_zd(5),
                              tpd_CK_DO5_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO0_int(6), DO0_zd(6),
                              tpd_CK_DO6_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO0_int(7), DO0_zd(7),
                              tpd_CK_DO7_posedge,last_A,A_i,NO_SER_TOH);
                       else
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           DO0_zd := (OTHERS => 'X');
                           DO0_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                       end if;

                   when "01" => 
                       if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                           -- Reduce error message --
                           flag_A := True_flg;
                           --------------------------
                           memoryCore0(to_integer(A_i)) := DI0_i;
                           DO0_zd := memoryCore0(to_integer(A_i));
                           ScheduleOutputDelay(DO0_int(0), DO0_zd(0),
                              tpd_CK_DO0_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO0_int(1), DO0_zd(1),
                              tpd_CK_DO1_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO0_int(2), DO0_zd(2),
                              tpd_CK_DO2_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO0_int(3), DO0_zd(3),
                              tpd_CK_DO3_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO0_int(4), DO0_zd(4),
                              tpd_CK_DO4_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO0_int(5), DO0_zd(5),
                              tpd_CK_DO5_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO0_int(6), DO0_zd(6),
                              tpd_CK_DO6_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO0_int(7), DO0_zd(7),
                              tpd_CK_DO7_posedge,last_A,A_i,NO_SER_TOH);
                       elsif (AddressRangeCheck(A_i,flag_A) = Range_flg) then
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           DO0_zd := (OTHERS => 'X');
                           DO0_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                       else
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           DO0_zd := (OTHERS => 'X');
                           DO0_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                           FOR i IN Words-1 downto 0 LOOP
                              memoryCore0(i) := (OTHERS => 'X');
                           END LOOP;
                       end if;

                   when "1X" |
                        "1U" |
                        "1Z" => DO0_zd := (OTHERS => 'X');
                                DO0_int <= TRANSPORT (OTHERS => 'X') AFTER TOH; 
                   when "10" |
                        "00" |
                        "X0" |
                        "U0" |
                        "Z0"   => -- do nothing
                   when others =>
                                if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                                   -- Reduce error message --
                                   flag_A := True_flg;
                                   --------------------------
                                   memoryCore0(to_integer(A_i)) := (OTHERS => 'X');
                                   DO0_zd := (OTHERS => 'X');
                                   DO0_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                                elsif (AddressRangeCheck(A_i,flag_A) = Range_flg) then
                                    -- Reduce error message --
                                    flag_A := False_flg;
                                    --------------------------
                                    DO0_zd := (OTHERS => 'X');
                                    DO0_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                                else
                                   -- Reduce error message --
                                   flag_A := False_flg;
                                   --------------------------
                                   DO0_zd := (OTHERS => 'X');
                                   DO0_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                                   FOR i IN Words-1 downto 0 LOOP
                                      memoryCore0(i) := (OTHERS => 'X');
                                   END LOOP;
                                end if;
                end case;


                web1_cs    := WEB1_i&CS_i;
                case web1_cs is
                   when "11" => 
                       -------- Reduce error message --------------------------
                       if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                           -- Reduce error message --
                           flag_A := True_flg;
                           --------------------------
                           DO1_zd := memoryCore1(to_integer(A_i));
                           ScheduleOutputDelay(DO1_int(0), DO1_zd(0),
                              tpd_CK_DO8_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO1_int(1), DO1_zd(1),
                              tpd_CK_DO9_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO1_int(2), DO1_zd(2),
                              tpd_CK_DO10_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO1_int(3), DO1_zd(3),
                              tpd_CK_DO11_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO1_int(4), DO1_zd(4),
                              tpd_CK_DO12_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO1_int(5), DO1_zd(5),
                              tpd_CK_DO13_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO1_int(6), DO1_zd(6),
                              tpd_CK_DO14_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO1_int(7), DO1_zd(7),
                              tpd_CK_DO15_posedge,last_A,A_i,NO_SER_TOH);
                       else
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           DO1_zd := (OTHERS => 'X');
                           DO1_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                       end if;

                   when "01" => 
                       if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                           -- Reduce error message --
                           flag_A := True_flg;
                           --------------------------
                           memoryCore1(to_integer(A_i)) := DI1_i;
                           DO1_zd := memoryCore1(to_integer(A_i));
                           ScheduleOutputDelay(DO1_int(0), DO1_zd(0),
                              tpd_CK_DO8_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO1_int(1), DO1_zd(1),
                              tpd_CK_DO9_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO1_int(2), DO1_zd(2),
                              tpd_CK_DO10_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO1_int(3), DO1_zd(3),
                              tpd_CK_DO11_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO1_int(4), DO1_zd(4),
                              tpd_CK_DO12_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO1_int(5), DO1_zd(5),
                              tpd_CK_DO13_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO1_int(6), DO1_zd(6),
                              tpd_CK_DO14_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO1_int(7), DO1_zd(7),
                              tpd_CK_DO15_posedge,last_A,A_i,NO_SER_TOH);
                       elsif (AddressRangeCheck(A_i,flag_A) = Range_flg) then
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           DO1_zd := (OTHERS => 'X');
                           DO1_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                       else
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           DO1_zd := (OTHERS => 'X');
                           DO1_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                           FOR i IN Words-1 downto 0 LOOP
                              memoryCore1(i) := (OTHERS => 'X');
                           END LOOP;
                       end if;

                   when "1X" |
                        "1U" |
                        "1Z" => DO1_zd := (OTHERS => 'X');
                                DO1_int <= TRANSPORT (OTHERS => 'X') AFTER TOH; 
                   when "10" |
                        "00" |
                        "X0" |
                        "U0" |
                        "Z0"   => -- do nothing
                   when others =>
                                if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                                   -- Reduce error message --
                                   flag_A := True_flg;
                                   --------------------------
                                   memoryCore1(to_integer(A_i)) := (OTHERS => 'X');
                                   DO1_zd := (OTHERS => 'X');
                                   DO1_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                                elsif (AddressRangeCheck(A_i,flag_A) = Range_flg) then
                                    -- Reduce error message --
                                    flag_A := False_flg;
                                    --------------------------
                                    DO1_zd := (OTHERS => 'X');
                                    DO1_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                                else
                                   -- Reduce error message --
                                   flag_A := False_flg;
                                   --------------------------
                                   DO1_zd := (OTHERS => 'X');
                                   DO1_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                                   FOR i IN Words-1 downto 0 LOOP
                                      memoryCore1(i) := (OTHERS => 'X');
                                   END LOOP;
                                end if;
                end case;


                web2_cs    := WEB2_i&CS_i;
                case web2_cs is
                   when "11" => 
                       -------- Reduce error message --------------------------
                       if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                           -- Reduce error message --
                           flag_A := True_flg;
                           --------------------------
                           DO2_zd := memoryCore2(to_integer(A_i));
                           ScheduleOutputDelay(DO2_int(0), DO2_zd(0),
                              tpd_CK_DO16_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO2_int(1), DO2_zd(1),
                              tpd_CK_DO17_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO2_int(2), DO2_zd(2),
                              tpd_CK_DO18_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO2_int(3), DO2_zd(3),
                              tpd_CK_DO19_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO2_int(4), DO2_zd(4),
                              tpd_CK_DO20_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO2_int(5), DO2_zd(5),
                              tpd_CK_DO21_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO2_int(6), DO2_zd(6),
                              tpd_CK_DO22_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO2_int(7), DO2_zd(7),
                              tpd_CK_DO23_posedge,last_A,A_i,NO_SER_TOH);
                       else
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           DO2_zd := (OTHERS => 'X');
                           DO2_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                       end if;

                   when "01" => 
                       if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                           -- Reduce error message --
                           flag_A := True_flg;
                           --------------------------
                           memoryCore2(to_integer(A_i)) := DI2_i;
                           DO2_zd := memoryCore2(to_integer(A_i));
                           ScheduleOutputDelay(DO2_int(0), DO2_zd(0),
                              tpd_CK_DO16_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO2_int(1), DO2_zd(1),
                              tpd_CK_DO17_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO2_int(2), DO2_zd(2),
                              tpd_CK_DO18_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO2_int(3), DO2_zd(3),
                              tpd_CK_DO19_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO2_int(4), DO2_zd(4),
                              tpd_CK_DO20_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO2_int(5), DO2_zd(5),
                              tpd_CK_DO21_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO2_int(6), DO2_zd(6),
                              tpd_CK_DO22_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO2_int(7), DO2_zd(7),
                              tpd_CK_DO23_posedge,last_A,A_i,NO_SER_TOH);
                       elsif (AddressRangeCheck(A_i,flag_A) = Range_flg) then
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           DO2_zd := (OTHERS => 'X');
                           DO2_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                       else
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           DO2_zd := (OTHERS => 'X');
                           DO2_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                           FOR i IN Words-1 downto 0 LOOP
                              memoryCore2(i) := (OTHERS => 'X');
                           END LOOP;
                       end if;

                   when "1X" |
                        "1U" |
                        "1Z" => DO2_zd := (OTHERS => 'X');
                                DO2_int <= TRANSPORT (OTHERS => 'X') AFTER TOH; 
                   when "10" |
                        "00" |
                        "X0" |
                        "U0" |
                        "Z0"   => -- do nothing
                   when others =>
                                if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                                   -- Reduce error message --
                                   flag_A := True_flg;
                                   --------------------------
                                   memoryCore2(to_integer(A_i)) := (OTHERS => 'X');
                                   DO2_zd := (OTHERS => 'X');
                                   DO2_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                                elsif (AddressRangeCheck(A_i,flag_A) = Range_flg) then
                                    -- Reduce error message --
                                    flag_A := False_flg;
                                    --------------------------
                                    DO2_zd := (OTHERS => 'X');
                                    DO2_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                                else
                                   -- Reduce error message --
                                   flag_A := False_flg;
                                   --------------------------
                                   DO2_zd := (OTHERS => 'X');
                                   DO2_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                                   FOR i IN Words-1 downto 0 LOOP
                                      memoryCore2(i) := (OTHERS => 'X');
                                   END LOOP;
                                end if;
                end case;


                web3_cs    := WEB3_i&CS_i;
                case web3_cs is
                   when "11" => 
                       -------- Reduce error message --------------------------
                       if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                           -- Reduce error message --
                           flag_A := True_flg;
                           --------------------------
                           DO3_zd := memoryCore3(to_integer(A_i));
                           ScheduleOutputDelay(DO3_int(0), DO3_zd(0),
                              tpd_CK_DO24_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO3_int(1), DO3_zd(1),
                              tpd_CK_DO25_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO3_int(2), DO3_zd(2),
                              tpd_CK_DO26_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO3_int(3), DO3_zd(3),
                              tpd_CK_DO27_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO3_int(4), DO3_zd(4),
                              tpd_CK_DO28_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO3_int(5), DO3_zd(5),
                              tpd_CK_DO29_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO3_int(6), DO3_zd(6),
                              tpd_CK_DO30_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO3_int(7), DO3_zd(7),
                              tpd_CK_DO31_posedge,last_A,A_i,NO_SER_TOH);
                       else
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           DO3_zd := (OTHERS => 'X');
                           DO3_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                       end if;

                   when "01" => 
                       if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                           -- Reduce error message --
                           flag_A := True_flg;
                           --------------------------
                           memoryCore3(to_integer(A_i)) := DI3_i;
                           DO3_zd := memoryCore3(to_integer(A_i));
                           ScheduleOutputDelay(DO3_int(0), DO3_zd(0),
                              tpd_CK_DO24_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO3_int(1), DO3_zd(1),
                              tpd_CK_DO25_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO3_int(2), DO3_zd(2),
                              tpd_CK_DO26_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO3_int(3), DO3_zd(3),
                              tpd_CK_DO27_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO3_int(4), DO3_zd(4),
                              tpd_CK_DO28_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO3_int(5), DO3_zd(5),
                              tpd_CK_DO29_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO3_int(6), DO3_zd(6),
                              tpd_CK_DO30_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DO3_int(7), DO3_zd(7),
                              tpd_CK_DO31_posedge,last_A,A_i,NO_SER_TOH);
                       elsif (AddressRangeCheck(A_i,flag_A) = Range_flg) then
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           DO3_zd := (OTHERS => 'X');
                           DO3_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                       else
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           DO3_zd := (OTHERS => 'X');
                           DO3_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                           FOR i IN Words-1 downto 0 LOOP
                              memoryCore3(i) := (OTHERS => 'X');
                           END LOOP;
                       end if;

                   when "1X" |
                        "1U" |
                        "1Z" => DO3_zd := (OTHERS => 'X');
                                DO3_int <= TRANSPORT (OTHERS => 'X') AFTER TOH; 
                   when "10" |
                        "00" |
                        "X0" |
                        "U0" |
                        "Z0"   => -- do nothing
                   when others =>
                                if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                                   -- Reduce error message --
                                   flag_A := True_flg;
                                   --------------------------
                                   memoryCore3(to_integer(A_i)) := (OTHERS => 'X');
                                   DO3_zd := (OTHERS => 'X');
                                   DO3_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                                elsif (AddressRangeCheck(A_i,flag_A) = Range_flg) then
                                    -- Reduce error message --
                                    flag_A := False_flg;
                                    --------------------------
                                    DO3_zd := (OTHERS => 'X');
                                    DO3_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                                else
                                   -- Reduce error message --
                                   flag_A := False_flg;
                                   --------------------------
                                   DO3_zd := (OTHERS => 'X');
                                   DO3_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                                   FOR i IN Words-1 downto 0 LOOP
                                      memoryCore3(i) := (OTHERS => 'X');
                                   END LOOP;
                                end if;
                end case;

                -- end memory_function

         end if;
       end if;

   end PROCESS;

end behavior;

