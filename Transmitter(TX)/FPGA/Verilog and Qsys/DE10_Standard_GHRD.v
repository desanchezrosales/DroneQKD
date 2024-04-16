// ============================================================================
// Copyright (c) 2016 by Terasic Technologies Inc.
// ============================================================================
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// ============================================================================
//           
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//  
//  
//                     web: http://www.terasic.com/  
//                     email: support@terasic.com
//
// ============================================================================
//Date:  Tue Sep 27 10:46:00 2016
// ============================================================================

`define ENABLE_HPS
`define ENABLE_HSMC

module DE10_Standard_GHRD(


      ///////// CLOCK /////////
      input              CLOCK2_50,
      input              CLOCK3_50,
      input              CLOCK4_50,
      input              CLOCK_50,

      ///////// KEY /////////
      input    [ 3: 0]   KEY,

      ///////// SW /////////
      input    [ 9: 0]   SW,

      ///////// LED /////////
      output   [ 9: 0]   LEDR,

      ///////// Seg7 /////////
      output   [ 6: 0]   HEX0,
      output   [ 6: 0]   HEX1,
      output   [ 6: 0]   HEX2,
      output   [ 6: 0]   HEX3,
      output   [ 6: 0]   HEX4,
      output   [ 6: 0]   HEX5,

      ///////// SDRAM /////////
      output             DRAM_CLK,
      output             DRAM_CKE,
      output   [12: 0]   DRAM_ADDR,
      output   [ 1: 0]   DRAM_BA,
      inout    [15: 0]   DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_UDQM,
      output             DRAM_CS_N,
      output             DRAM_WE_N,
      output             DRAM_CAS_N,
      output             DRAM_RAS_N,

      ///////// Video-In /////////
      input              TD_CLK27,
      input              TD_HS,
      input              TD_VS,
      input    [ 7: 0]   TD_DATA,
      output             TD_RESET_N,

      ///////// VGA /////////
      output             VGA_CLK,
      output             VGA_HS,
      output             VGA_VS,
      output   [ 7: 0]   VGA_R,
      output   [ 7: 0]   VGA_G,
      output   [ 7: 0]   VGA_B,
      output             VGA_BLANK_N,
      output             VGA_SYNC_N,

      ///////// Audio /////////
      inout              AUD_BCLK,
      output             AUD_XCK,
      inout              AUD_ADCLRCK,
      input              AUD_ADCDAT,
      inout              AUD_DACLRCK,
      output             AUD_DACDAT,

      ///////// PS2 /////////
      inout              PS2_CLK,
      inout              PS2_CLK2,
      inout              PS2_DAT,
      inout              PS2_DAT2,

      ///////// ADC /////////
      output             ADC_SCLK,
      input              ADC_DOUT,
      output             ADC_DIN,
      output             ADC_CONVST,

      ///////// I2C for Audio and Video-In /////////
      output             FPGA_I2C_SCLK,
      inout              FPGA_I2C_SDAT,

      ///////// GPIO /////////
      inout    [35: 0]   GPIO,

`ifdef ENABLE_HSMC
      ///////// HSMC /////////
      input              HSMC_CLKIN_P1,
      input              HSMC_CLKIN_N1,
      output             HSMC_CLKIN_P2,
      output             HSMC_CLKIN_N2,
      output             HSMC_CLKOUT_P1,
      output             HSMC_CLKOUT_N1,
      output             HSMC_CLKOUT_P2,
      output             HSMC_CLKOUT_N2,
      inout    [16: 0]   HSMC_TX_D_P,
      inout    [16: 0]   HSMC_TX_D_N,
      inout    [16: 0]   HSMC_RX_D_P,
      inout    [16: 0]   HSMC_RX_D_N,
      input              HSMC_CLKIN0,
      output             HSMC_CLKOUT0,
      inout    [ 3: 0]   HSMC_D,
      output             HSMC_SCL,
      inout              HSMC_SDA,
`endif /*ENABLE_HSMC*/

`ifdef ENABLE_HPS
      ///////// HPS /////////
      inout              HPS_CONV_USB_N,
      output      [14:0] HPS_DDR3_ADDR,
      output      [2:0]  HPS_DDR3_BA,
      output             HPS_DDR3_CAS_N,
      output             HPS_DDR3_CKE,
      output             HPS_DDR3_CK_N,
      output             HPS_DDR3_CK_P,
      output             HPS_DDR3_CS_N,
      output      [3:0]  HPS_DDR3_DM,
      inout       [31:0] HPS_DDR3_DQ,
      inout       [3:0]  HPS_DDR3_DQS_N,
      inout       [3:0]  HPS_DDR3_DQS_P,
      output             HPS_DDR3_ODT,
      output             HPS_DDR3_RAS_N,
      output             HPS_DDR3_RESET_N,
      input              HPS_DDR3_RZQ,
      output             HPS_DDR3_WE_N,
      output             HPS_ENET_GTX_CLK,
      inout              HPS_ENET_INT_N,
      output             HPS_ENET_MDC,
      inout              HPS_ENET_MDIO,
      input              HPS_ENET_RX_CLK,
      input       [3:0]  HPS_ENET_RX_DATA,
      input              HPS_ENET_RX_DV,
      output      [3:0]  HPS_ENET_TX_DATA,
      output             HPS_ENET_TX_EN,
      inout       [3:0]  HPS_FLASH_DATA,
      output             HPS_FLASH_DCLK,
      output             HPS_FLASH_NCSO,
      inout              HPS_GSENSOR_INT,
      inout              HPS_I2C1_SCLK,
      inout              HPS_I2C1_SDAT,
      inout              HPS_I2C2_SCLK,
      inout              HPS_I2C2_SDAT,
      inout              HPS_I2C_CONTROL,
      inout              HPS_KEY,
      inout              HPS_LCM_BK,
      inout              HPS_LCM_D_C,
      inout              HPS_LCM_RST_N,
      output             HPS_LCM_SPIM_CLK,
      output             HPS_LCM_SPIM_MOSI,
      output             HPS_LCM_SPIM_SS,
		input 				 HPS_LCM_SPIM_MISO,
      inout              HPS_LED,
      inout              HPS_LTC_GPIO,
      output             HPS_SD_CLK,
      inout              HPS_SD_CMD,
      inout       [3:0]  HPS_SD_DATA,
      output             HPS_SPIM_CLK,
      input              HPS_SPIM_MISO,
      output             HPS_SPIM_MOSI,
      inout              HPS_SPIM_SS,
      input              HPS_UART_RX,
      output             HPS_UART_TX,
      input              HPS_USB_CLKOUT,
      inout       [7:0]  HPS_USB_DATA,
      input              HPS_USB_DIR,
      input              HPS_USB_NXT,
      output             HPS_USB_STP,
`endif /*ENABLE_HPS*/
      ///////// IR /////////
      output             IRDA_TXD,
      input              IRDA_RXD
);

//=======================================================
//  Fractional PLL START
//=======================================================
	reg fPLL_clock;
	reg [63:0] reconfig_to_pll;
	reg [63:0] reconfig_from_pll;
	reg mgmt_waitrequest;
	reg mgmt_write;
	reg [5:0] mgmt_address;
	reg [31:0] mgmt_writedata;
	
	
	assign LEDR[0] = GPS_signal;
	
	assign HSMC_CLKIN_N2 = fPLL_clock;
	assign HSMC_CLKIN_P2 = GPS_signal;
	
	assign GPIO[11] = GPS_signal;
	assign GPIO[15] = fPLL_clock;
//=======================================================
//  Structural coding
//=======================================================
	
	fractional_PLL_1(
		.refclk            (CLOCK_50),            //            refclk.clk
		.rst               (rst),               //             reset.reset
		.outclk_0          (fPLL_clock),          //           outclk0.clk
		.locked            (locked),            //            locked.export
		.reconfig_to_pll   (reconfig_to_pll),   //   reconfig_to_pll.reconfig_to_pll
		.reconfig_from_pll (reconfig_from_pll)  // reconfig_from_pll.reconfig_from_pll
	);
	
	
	pll_reconfiguration_1 (
		.mgmt_clk          (CLOCK_50),          //          mgmt_clk.clk
		.mgmt_reset        (mgmt_reset),        //        mgmt_reset.reset
		.mgmt_waitrequest  (mgmt_waitrequest),  // mgmt_avalon_slave.waitrequest
		.mgmt_read         (mgmt_read),         //                  .read
		.mgmt_write        (mgmt_write),        //                  .write
		.mgmt_readdata     (mgmt_readdata),     //                  .readdata
		.mgmt_address      (mgmt_address),      //                  .address
		.mgmt_writedata    (mgmt_writedata),    //                  .writedata
		.reconfig_to_pll   (reconfig_to_pll),   //   reconfig_to_pll.reconfig_to_pll
		.reconfig_from_pll (reconfig_from_pll) // reconfig_from_pll.reconfig_from_pll
	);
	
	
	
//=======================================================
//  Structural coding
//=======================================================
	reg [31:0] fPLL_counter = 0;
	reg [31:0] c_out = 0;
	reg [31:0] K_counter = 2147483606 /* synthesis keep */;
	reg [31:0] target = 25000000;
//	wire [31:0] target;
	reg [31:0] error = 0;
	
	reg SM_trig = 0;
	
	
	reg [3:0] fPLL_SM;
	
	wire GPS_signal;
	assign GPS_signal = GPIO[0];
	
	
	always @(posedge fPLL_clock & SW[9])
	begin
		fPLL_counter =  fPLL_counter + 1;
		
		case(SM_trig)
	
			1'b0:
				begin
					if (GPS_signal == 1)
						begin
							if (fPLL_counter < target)
								begin
									c_out = fPLL_counter;
									error = target - fPLL_counter;
									
									if (error > 1000)
										K_counter = K_counter;
									else
										K_counter = K_counter + 5435*error;
										
									fPLL_counter = 0;
									SM_trig = 1'b1;
								end
								
							else if (fPLL_counter > target)
								begin
									c_out = fPLL_counter;
									error = fPLL_counter - target;
									
									if (error > 1000)
										K_counter = K_counter;
									else
										K_counter = K_counter - 5435*error;
	
									fPLL_counter = 0;
									SM_trig = 1'b1;
								end
							else
								begin
									c_out = fPLL_counter;
									error = 0;
									K_counter = K_counter;
									fPLL_counter = 0;
									SM_trig = 1'b1;
								end
						end
				end
				
			1'b1:
				begin
					if (GPS_signal == 0)
						begin
							SM_trig <= 1'b0;
						end
				end
				
		endcase
	
			
		case(fPLL_SM)
		
			4'b0000:
				begin
					if (mgmt_waitrequest == 0 & GPS_signal == 1)
						begin
							mgmt_writedata = 32'd0;
							mgmt_address = 6'b000000;
							fPLL_SM <= 4'b0001;
						end
				end
				
			4'b0001:
				begin
					mgmt_write = 1;
					fPLL_SM <= 4'b0010;
				end
			
			4'b0010:
				begin
					mgmt_write = 0;
					fPLL_SM <= 4'b0011;
				end
				
			4'b0011:
				begin
					mgmt_writedata = K_counter;
					mgmt_address = 6'b000111;
					fPLL_SM <= 4'b0100;
				end
			
			4'b0100:
				begin
					mgmt_write = 1;
					fPLL_SM <= 4'b0101;
				end
				
			4'b0101:
				begin
					mgmt_write = 0;
					fPLL_SM <= 4'b0111;
				end
			4'b0111:
				begin
					mgmt_writedata = 32'd0;
					mgmt_address = 6'b000010;
					fPLL_SM <= 4'b1000;
				end
				
			4'b1000:
				begin
					mgmt_write = 1;
					fPLL_SM <= 4'b1001;
				end
				
			4'b1001:
				begin
					mgmt_write = 0;
					fPLL_SM <= 4'b1011;
				end
				
			4'b1011:
				begin
					if (GPS_signal == 0)
						begin
							fPLL_SM <= 4'b0000;
						end
				end
			
		endcase
	end
//=======================================================
//  Fractional PLL END
//=======================================================





//=======================================================
//  REG/WIRE declarations
//=======================================================
	reg generate_bits;
	reg clock_12;
	reg clock_12_1;
	reg clock_12_2;
	reg clock_12_3;
	reg clock_12_4;
	reg clock_12_5;
	reg clock_12_6;
	reg clock_12_7;
	reg clock_100;
	
	wire c0, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12;

	wire phase_done_0, phase_done_1;
	wire lock_0, lock_1;

	wire sig_H, sig_L, sig_R, dec_H, dec_L, dec_R;
	wire sig_H_full, sig_L_full, sig_R_full, dec_H_full, dec_L_full, dec_R_full;
	
  
	my_pll (
		.refclk   (fPLL_clock),   //  refclk.clk
		.rst      (rst),      //   reset.reset
		.outclk_0 (clock_100), // outclk0.clk
		.outclk_1 (clock_12), // outclk1.clk
		.outclk_2 (clock_12_1), // outclk2.clk
		.outclk_3 (clock_12_2), // outclk3.clk
		.outclk_4 (clock_12_3), // outclk4.clk
		.outclk_5 (clock_12_4), // outclk5.clk
		.outclk_6 (clock_12_5), // outclk6.clk
		.outclk_7 (clock_12_6), // outclk7.clk
		.outclk_8 (clock_12_7), // outclk8.clk
		.locked   (locked)    //  locked.export
	);
	
	
	DPLL1(
	.refclk(clock_12),
	.locked(lock_0),
	.rst(~KEY[0]),
	.phase_done	(phase_done_0),
	.outclk_0(c0),
	.outclk_1(c1),
	.outclk_2(c2),
	.outclk_3(c3),
	.outclk_4(c4),
	.outclk_5(c5),
	.outclk_6(c6),
	.phase_en(shift_en),
	.scanclk(clock_12),
	.updn(width_control[0]),
	.cntsel(pulse_chooser)
	);

	DPLL2(
	.refclk(c6),
	.locked(lock_1),
	.rst(~KEY[1]),
	.phase_done	(phase_done_1),
	.outclk_0(c7),
	.outclk_1(c8),
	.outclk_2(c9),
	.outclk_3(c10),
	.outclk_4(c11),
	.outclk_5(c12),
	.phase_en(shift_en & width_control[1]),
	.scanclk(c6),
	.updn(width_control[0]),
	.cntsel(pulse_chooser)
	);	
	
	reg save_reg = 0;
	reg hps_start = 0;
	reg hps_addr_reset = 0;
	
	//assign HSMC_CLKIN_N2 = pulse_chooser[0] ? (pulse_chooser[1] ? (pulse_chooser[2] ? (0):(dec_R)):(pulse_chooser[2] ? (dec_H):(dec_L))):(pulse_chooser[1] ? (pulse_chooser[2] ? (0):(sig_R)): (pulse_chooser[2] ? (sig_H):(sig_L)));
	assign HSMC_CLKOUT_N2 = clock_12;
	//assign HSMC_CLKIN_P2 = pulse_chooser[0] ? (pulse_chooser[1] ? (pulse_chooser[2] ? (0):(c3 & c10)):(pulse_chooser[2] ? (c5 & c12):(c1 & c8))):(pulse_chooser[1] ? (pulse_chooser[2] ? (0):(c2 & c9)): (pulse_chooser[2] ? (c4 & c11):(c0 & c7)));
	assign HSMC_CLKOUT_P2 = pulse_chooser[0] ? (pulse_chooser[1] ? (pulse_chooser[2] ? (0):(dec_R_full)):(pulse_chooser[2] ? (dec_H_full):(dec_L_full))):(pulse_chooser[1] ? (pulse_chooser[2] ? (0):(sig_R_full)): (pulse_chooser[2] ? (sig_H_full):(sig_L_full)));

	
	assign LEDR[9] = cpy_en;
	assign LEDR[7] = save_reg;
	
	
	assign sig_L = (c0 & c7) & pulses[0] & sig_dec_control[0] & enable_signal;
	assign dec_L = (c1 & c8) & pulses[3] & sig_dec_control[1] & enable_signal;
	assign sig_R = (c2 & c9) & pulses[1] & sig_dec_control[0] & enable_signal;
	assign dec_R = (c3 & c10) & pulses[4] & sig_dec_control[1] & enable_signal;
	assign sig_H = (c4 & c11) & pulses[2] & sig_dec_control[0] & enable_signal;
	assign dec_H = (c5 & c12) & pulses[5] & sig_dec_control[1] & enable_signal;
	
	assign sig_L_full = (c0 & c7) & sig_dec_control[0] & enable_signal;
	assign dec_L_full = (c1 & c8) & sig_dec_control[1] & enable_signal;
	assign sig_R_full = (c2 & c9) & sig_dec_control[0] & enable_signal;
	assign dec_R_full = (c3 & c10) & sig_dec_control[1] & enable_signal;
	assign sig_H_full = (c4 & c11) & sig_dec_control[0] & enable_signal;
	assign dec_H_full = (c5 & c12) & sig_dec_control[1] & enable_signal;
	
//	assign GPIO[1] = pulse_chooser[0] ? (pulse_chooser[1] ? (pulse_chooser[2] ? (0):(c3)):(pulse_chooser[2] ? (c5):(c1))):(pulse_chooser[1] ? (pulse_chooser[2] ? (0):(c2)): (pulse_chooser[2] ? (c4):(c0)));
//	assign GPIO[5] = pulse_chooser[0] ? (pulse_chooser[1] ? (pulse_chooser[2] ? (0):(c10)):(pulse_chooser[2] ? (c12):(c8))):(pulse_chooser[1] ? (pulse_chooser[2] ? (0):(c9)): (pulse_chooser[2] ? (c11):(c7)));
//	assign GPIO[9] = pulse_chooser[0] ? (pulse_chooser[1] ? (pulse_chooser[2] ? (0):(pulses[4])):(pulse_chooser[2] ? (pulses[5]):(pulses[3]))):(pulse_chooser[1] ? (pulse_chooser[2] ? (0):(pulses[1])): (pulse_chooser[2] ? (pulses[2]):(pulses[0])));
	
//	assign GPIO[35] = (SW[0]) ? (signals):((pulses[3]) ? (1'bZ):(sig_L));
//	assign GPIO[33] = (SW[0]) ? (1'bZ):((pulses[0]) ? (1'bZ):(dec_L));
//	
//	assign GPIO[29] = (SW[0]) ? (signals):((pulses[4]) ? (1'bZ):(sig_R));
//	assign GPIO[27] = (SW[0]) ? (1'bZ):((pulses[1]) ? (1'bZ):(dec_R));
//	
//	assign GPIO[21] = (SW[0]) ? (signals):((pulses[5]) ? (1'bZ):(sig_H));
//	assign GPIO[19] = (SW[0]) ? (1'bZ):((pulses[2]) ? (1'bZ):(dec_H));

	assign GPIO[35] = SW[1] ? ((pulses[3]) ? (1'bZ):(sig_L)):(SW[2] ? (sig_L_full):(1'bZ));
	assign GPIO[33] = SW[1] ? ((pulses[0]) ? (1'bZ):(dec_L)):(SW[2] ? (1'bZ):(dec_L_full));

	assign GPIO[29] = SW[1] ? ((pulses[4]) ? (1'bZ):(sig_R)):(SW[2] ? (sig_R_full):(1'bZ));
	assign GPIO[27] = SW[1] ? ((pulses[1]) ? (1'bZ):(dec_R)):(SW[2] ? (1'bZ):(dec_R_full));
	
	assign GPIO[21] = SW[1] ? ((pulses[5]) ? (1'bZ):(sig_H)):(SW[2] ? (sig_H_full):(1'bZ));
	assign GPIO[19] = SW[1] ? ((pulses[2]) ? (1'bZ):(dec_H)):(SW[2] ? (1'bZ):(dec_H_full));

	
	assign LEDR[1] = sig_L;
	assign LEDR[2] = sig_R;
	assign LEDR[3] = sig_H;
	assign LEDR[4] = dec_L;
	assign LEDR[5] = dec_R;
	assign LEDR[6] = dec_H;
	
//	assign GPIO[1] = (SW[0]) ? (signals):((pulses[3]) ? (1'bZ):(sig_L));
//	assign GPIO[5] = (SW[0]) ? (signals):((pulses[5]) ? (1'bZ):(sig_H));
//	assign GPIO[9] = signals;
//	assign GPIO[13] = decoys;
//	assign GPIO[17] = (SW[0]) ? (signals):((pulses[4]) ? (1'bZ):(sig_R));


//======================================================================================
//										PLL shifts
//======================================================================================
	reg shift_en;
	reg [63:0] count;
	wire shift_reset;
	reg start;
	assign shift_reset = enable_sig;



	always @(posedge clock_12)
		if (shift_reset)
			begin
				count <= 0;	
				start <= 1;
			end
		else if (phase_done_0 == 1 & (count < n_shifts) & start)
			begin
				shift_en <= 1;
				count <= count + 1;
			end
		else if (phase_done_0 == 0)
			shift_en <= 0;
		else if (count == n_shifts)
			start <= 0;

//======================================================================================
//							 Control RAMs
//======================================================================================
	wire [7:0] n_shifts;
	wire [2:0] pulse_chooser;
	wire [1:0] width_control;
	wire [1:0] sig_dec_control;
	wire enable_sig;

	SHIFT_RAM (0, CLOCK_50, 0, 1, 0, n_shifts);
	control_RAM (0, CLOCK_50, 0, 1, 0, pulse_chooser);
	WIDTH_CONTROL_RAM (0, CLOCK_50, 0, 1, 0, width_control);
	SIG_DEC_RAM (0, CLOCK_50, 0, 1, 0, sig_dec_control);
	ENABLE_SIG_RAM (0, CLOCK_50, 0, 1, 0, enable_sig);			
			
//======================================================================================
//  Generate Random Bits
//======================================================================================

	wire bit_0, bit_1, bit_2, bit_3, bit_4, bit_5, bit_6, bit_7;
	
	RNG ibit_0(
		.clock(clock_12),
		.word_out(bit_0)
	 );
	
	RNG ibit_1(
		.clock(clock_12_1),
		.word_out(bit_1)
	);
	
	RNG ibit_2(
		.clock(clock_12_2),
		.word_out(bit_2)
	);
	
	RNG ibit_3(
		.clock(clock_12_3),
		.word_out(bit_3)
	);
	
	RNG ibit_4(
		.clock(clock_12_4),
		.word_out(bit_4)
	);
	
	RNG ibit_5(
		.clock(clock_12_5),
		.word_out(bit_5)
	);
	
	RNG ibit_6(
		.clock(clock_12_6),
		.word_out(bit_6)
	);
	
	RNG ibit_7(
		.clock(clock_12_7),
		.word_out(bit_7)
	);
	
//======================================================================================
//  Generate States
//======================================================================================


	wire [5:0] pulses;
	wire [15:0] adr_reg;
	wire [31:0] SD_data;
	wire [1:0] cpy_en;
	wire save_data_pulse;
	
	pulse_generator_2 p0(
		.clk(clock_12),
		.rst(hps_start),
		.i_data({bit_7, bit_6, bit_5, bit_4, bit_3, bit_2, bit_1, bit_0}),
		.enable_signal(enable_signal),
		.pulses(pulses),		
		.SD_data(SD_data),
		.adr_reg(adr_reg),
		.cpy_en(cpy_en),
		.save_data_pulse(save_data_pulse)
	);
//=======================================================

//=======================================================

	reg [31:0] counter_enable;
	reg enable_signal = 0;
	
	always @ (posedge clock_12)
	begin
		counter_enable = counter_enable + 1;
		
		if(counter_enable >= 83886080 && counter_enable <= 90136080)
		begin
			enable_signal = 0;
			save_reg = 1;
		end
		
		else
		begin
			enable_signal = 1;
			save_reg = 0;
		end
		
		if(counter_enable > 90136080)
			counter_enable = 0;
			
	end

//=======================================================



//=======================================================
//  HPS code

//=======================================================
//  REG/WIRE declarations
//=======================================================
  wire  hps_fpga_reset_n;
  wire [3:0] fpga_debounced_buttons;
  wire [8:0]  fpga_led_internal;
  wire [2:0]  hps_reset_req;
  wire        hps_cold_reset;
  wire        hps_warm_reset;
  wire        hps_debug_reset;
  wire [27:0] stm_hw_events;
  wire        fpga_clk_50;
// connection of internal logics
//  assign LEDR[9:1] = fpga_led_internal;
  assign stm_hw_events    = {{4{1'b0}}, SW, fpga_led_internal, fpga_debounced_buttons};
  assign fpga_clk_50=CLOCK_50;
//=======================================================
//  Structural coding
//=======================================================
soc_system u0 (      
		  .clk_clk                               (clock_100),                             //                clk.clk
		  .reset_reset_n                         (1'b1),                                 //                reset.reset_n
		  /////////////////////////////////////////////////////////////////////////////////
		  .mem_0_address                         (adr_reg),                              //                     mem_0.address
        .mem_0_chipselect                      (1'b1),                                //                          .chipselect
        .mem_0_clken                           (1'b1),                                 //                          .clken
        .mem_0_write                           (save_data_pulse & hps_start),                                //                          .write
        .mem_0_readdata                        (),                                     //                          .readdata
        .mem_0_writedata                       (SD_data),                              //                          .writedata
        .mem_0_byteenable                      (4'b1111),                                 //                          .byteenable
		  
		  
		  .adr_count_export                      (cpy_en),                               //                 adr_count.export
		  .hps_continue_export                   (save_reg),                    //              hps_continue.export
		  .hps_start_export                      (hps_start),                       //                 hps_start.export
		  .hps_addr_reset_export                 (hps_addr_reset),                  //            hps_addr_reset.export

		  /////////////////////////////////////////////////////////////////////////////////
		  
		  //HPS ddr3
		  .memory_mem_a                          ( HPS_DDR3_ADDR),                       //                memory.mem_a
        .memory_mem_ba                         ( HPS_DDR3_BA),                         //                .mem_ba
        .memory_mem_ck                         ( HPS_DDR3_CK_P),                       //                .mem_ck
        .memory_mem_ck_n                       ( HPS_DDR3_CK_N),                       //                .mem_ck_n
        .memory_mem_cke                        ( HPS_DDR3_CKE),                        //                .mem_cke
        .memory_mem_cs_n                       ( HPS_DDR3_CS_N),                       //                .mem_cs_n
        .memory_mem_ras_n                      ( HPS_DDR3_RAS_N),                      //                .mem_ras_n
        .memory_mem_cas_n                      ( HPS_DDR3_CAS_N),                      //                .mem_cas_n
        .memory_mem_we_n                       ( HPS_DDR3_WE_N),                       //                .mem_we_n
        .memory_mem_reset_n                    ( HPS_DDR3_RESET_N),                    //                .mem_reset_n
        .memory_mem_dq                         ( HPS_DDR3_DQ),                         //                .mem_dq
        .memory_mem_dqs                        ( HPS_DDR3_DQS_P),                      //                .mem_dqs
        .memory_mem_dqs_n                      ( HPS_DDR3_DQS_N),                      //                .mem_dqs_n
        .memory_mem_odt                        ( HPS_DDR3_ODT),                        //                .mem_odt
        .memory_mem_dm                         ( HPS_DDR3_DM),                         //                .mem_dm
        .memory_oct_rzqin                      ( HPS_DDR3_RZQ),                        //                .oct_rzqin
       //HPS ethernet		
	     .hps_0_hps_io_hps_io_emac1_inst_TX_CLK ( HPS_ENET_GTX_CLK),       //                             hps_0_hps_io.hps_io_emac1_inst_TX_CLK
        .hps_0_hps_io_hps_io_emac1_inst_TXD0   ( HPS_ENET_TX_DATA[0] ),   //                             .hps_io_emac1_inst_TXD0
        .hps_0_hps_io_hps_io_emac1_inst_TXD1   ( HPS_ENET_TX_DATA[1] ),   //                             .hps_io_emac1_inst_TXD1
        .hps_0_hps_io_hps_io_emac1_inst_TXD2   ( HPS_ENET_TX_DATA[2] ),   //                             .hps_io_emac1_inst_TXD2
        .hps_0_hps_io_hps_io_emac1_inst_TXD3   ( HPS_ENET_TX_DATA[3] ),   //                             .hps_io_emac1_inst_TXD3
        .hps_0_hps_io_hps_io_emac1_inst_RXD0   ( HPS_ENET_RX_DATA[0] ),   //                             .hps_io_emac1_inst_RXD0
        .hps_0_hps_io_hps_io_emac1_inst_MDIO   ( HPS_ENET_MDIO ),         //                             .hps_io_emac1_inst_MDIO
        .hps_0_hps_io_hps_io_emac1_inst_MDC    ( HPS_ENET_MDC  ),         //                             .hps_io_emac1_inst_MDC
        .hps_0_hps_io_hps_io_emac1_inst_RX_CTL ( HPS_ENET_RX_DV),         //                             .hps_io_emac1_inst_RX_CTL
        .hps_0_hps_io_hps_io_emac1_inst_TX_CTL ( HPS_ENET_TX_EN),         //                             .hps_io_emac1_inst_TX_CTL
        .hps_0_hps_io_hps_io_emac1_inst_RX_CLK ( HPS_ENET_RX_CLK),        //                             .hps_io_emac1_inst_RX_CLK
        .hps_0_hps_io_hps_io_emac1_inst_RXD1   ( HPS_ENET_RX_DATA[1] ),   //                             .hps_io_emac1_inst_RXD1
        .hps_0_hps_io_hps_io_emac1_inst_RXD2   ( HPS_ENET_RX_DATA[2] ),   //                             .hps_io_emac1_inst_RXD2
        .hps_0_hps_io_hps_io_emac1_inst_RXD3   ( HPS_ENET_RX_DATA[3] ),   //                             .hps_io_emac1_inst_RXD3
       //HPS QSPI  
		  .hps_0_hps_io_hps_io_qspi_inst_IO0     ( HPS_FLASH_DATA[0]    ),     //                               .hps_io_qspi_inst_IO0
        .hps_0_hps_io_hps_io_qspi_inst_IO1     ( HPS_FLASH_DATA[1]    ),     //                               .hps_io_qspi_inst_IO1
        .hps_0_hps_io_hps_io_qspi_inst_IO2     ( HPS_FLASH_DATA[2]    ),     //                               .hps_io_qspi_inst_IO2
        .hps_0_hps_io_hps_io_qspi_inst_IO3     ( HPS_FLASH_DATA[3]    ),     //                               .hps_io_qspi_inst_IO3
        .hps_0_hps_io_hps_io_qspi_inst_SS0     ( HPS_FLASH_NCSO    ),        //                               .hps_io_qspi_inst_SS0
        .hps_0_hps_io_hps_io_qspi_inst_CLK     ( HPS_FLASH_DCLK    ),        //                               .hps_io_qspi_inst_CLK
       //HPS SD card 
		  .hps_0_hps_io_hps_io_sdio_inst_CMD     ( HPS_SD_CMD    ),           //                               .hps_io_sdio_inst_CMD
        .hps_0_hps_io_hps_io_sdio_inst_D0      ( HPS_SD_DATA[0]     ),      //                               .hps_io_sdio_inst_D0
        .hps_0_hps_io_hps_io_sdio_inst_D1      ( HPS_SD_DATA[1]     ),      //                               .hps_io_sdio_inst_D1
        .hps_0_hps_io_hps_io_sdio_inst_CLK     ( HPS_SD_CLK   ),            //                               .hps_io_sdio_inst_CLK
        .hps_0_hps_io_hps_io_sdio_inst_D2      ( HPS_SD_DATA[2]     ),      //                               .hps_io_sdio_inst_D2
        .hps_0_hps_io_hps_io_sdio_inst_D3      ( HPS_SD_DATA[3]     ),      //                               .hps_io_sdio_inst_D3
       //HPS USB 		  
		  .hps_0_hps_io_hps_io_usb1_inst_D0      ( HPS_USB_DATA[0]    ),      //                               .hps_io_usb1_inst_D0
        .hps_0_hps_io_hps_io_usb1_inst_D1      ( HPS_USB_DATA[1]    ),      //                               .hps_io_usb1_inst_D1
        .hps_0_hps_io_hps_io_usb1_inst_D2      ( HPS_USB_DATA[2]    ),      //                               .hps_io_usb1_inst_D2
        .hps_0_hps_io_hps_io_usb1_inst_D3      ( HPS_USB_DATA[3]    ),      //                               .hps_io_usb1_inst_D3
        .hps_0_hps_io_hps_io_usb1_inst_D4      ( HPS_USB_DATA[4]    ),      //                               .hps_io_usb1_inst_D4
        .hps_0_hps_io_hps_io_usb1_inst_D5      ( HPS_USB_DATA[5]    ),      //                               .hps_io_usb1_inst_D5
        .hps_0_hps_io_hps_io_usb1_inst_D6      ( HPS_USB_DATA[6]    ),      //                               .hps_io_usb1_inst_D6
        .hps_0_hps_io_hps_io_usb1_inst_D7      ( HPS_USB_DATA[7]    ),      //                               .hps_io_usb1_inst_D7
        .hps_0_hps_io_hps_io_usb1_inst_CLK     ( HPS_USB_CLKOUT    ),       //                               .hps_io_usb1_inst_CLK
        .hps_0_hps_io_hps_io_usb1_inst_STP     ( HPS_USB_STP    ),          //                               .hps_io_usb1_inst_STP
        .hps_0_hps_io_hps_io_usb1_inst_DIR     ( HPS_USB_DIR    ),          //                               .hps_io_usb1_inst_DIR
        .hps_0_hps_io_hps_io_usb1_inst_NXT     ( HPS_USB_NXT    ),          //                               .hps_io_usb1_inst_NXT
		  
		  //HPS SPI0->LCDM 	
        .hps_0_hps_io_hps_io_spim0_inst_CLK    ( HPS_LCM_SPIM_CLK),    //                               .hps_io_spim0_inst_CLK
        .hps_0_hps_io_hps_io_spim0_inst_MOSI   ( HPS_LCM_SPIM_MOSI),   //                               .hps_io_spim0_inst_MOSI
        .hps_0_hps_io_hps_io_spim0_inst_MISO   ( HPS_LCM_SPIM_MISO),   //                               .hps_io_spim0_inst_MISO
        .hps_0_hps_io_hps_io_spim0_inst_SS0    ( HPS_LCM_SPIM_SS),    //                               .hps_io_spim0_inst_SS0
       //HPS SPI1 		  
		  .hps_0_hps_io_hps_io_spim1_inst_CLK    ( HPS_SPIM_CLK  ),           //                               .hps_io_spim1_inst_CLK
        .hps_0_hps_io_hps_io_spim1_inst_MOSI   ( HPS_SPIM_MOSI ),           //                               .hps_io_spim1_inst_MOSI
        .hps_0_hps_io_hps_io_spim1_inst_MISO   ( HPS_SPIM_MISO ),           //                               .hps_io_spim1_inst_MISO
        .hps_0_hps_io_hps_io_spim1_inst_SS0    ( HPS_SPIM_SS ),             //                               .hps_io_spim1_inst_SS0
      //HPS UART		
		  .hps_0_hps_io_hps_io_uart0_inst_RX     ( HPS_UART_RX    ),          //                               .hps_io_uart0_inst_RX
        .hps_0_hps_io_hps_io_uart0_inst_TX     ( HPS_UART_TX    ),          //                               .hps_io_uart0_inst_TX
		//HPS I2C1
		  .hps_0_hps_io_hps_io_i2c0_inst_SDA     ( HPS_I2C1_SDAT    ),        //                               .hps_io_i2c0_inst_SDA
        .hps_0_hps_io_hps_io_i2c0_inst_SCL     ( HPS_I2C1_SCLK    ),        //                               .hps_io_i2c0_inst_SCL
		//HPS I2C2
		  .hps_0_hps_io_hps_io_i2c1_inst_SDA     ( HPS_I2C2_SDAT    ),        //                               .hps_io_i2c1_inst_SDA
        .hps_0_hps_io_hps_io_i2c1_inst_SCL     ( HPS_I2C2_SCLK    ),        //                               .hps_io_i2c1_inst_SCL
      //HPS GPIO  
		  .hps_0_hps_io_hps_io_gpio_inst_GPIO09  ( HPS_CONV_USB_N),           //                               .hps_io_gpio_inst_GPIO09
        .hps_0_hps_io_hps_io_gpio_inst_GPIO35  ( HPS_ENET_INT_N),           //                               .hps_io_gpio_inst_GPIO35
        .hps_0_hps_io_hps_io_gpio_inst_GPIO37  ( HPS_LCM_BK ),  //                               .hps_io_gpio_inst_GPIO37
		  .hps_0_hps_io_hps_io_gpio_inst_GPIO40  ( HPS_LTC_GPIO ),              //                               .hps_io_gpio_inst_GPIO40
        .hps_0_hps_io_hps_io_gpio_inst_GPIO41  ( HPS_LCM_D_C ),              //                               .hps_io_gpio_inst_GPIO41
        .hps_0_hps_io_hps_io_gpio_inst_GPIO44  ( HPS_LCM_RST_N  ),  //                               .hps_io_gpio_inst_GPIO44
		  .hps_0_hps_io_hps_io_gpio_inst_GPIO48  ( HPS_I2C_CONTROL),          //                               .hps_io_gpio_inst_GPIO48
        .hps_0_hps_io_hps_io_gpio_inst_GPIO53  ( HPS_LED),                  //                               .hps_io_gpio_inst_GPIO53
        .hps_0_hps_io_hps_io_gpio_inst_GPIO54  ( HPS_KEY),                  //                               .hps_io_gpio_inst_GPIO54
    	  .hps_0_hps_io_hps_io_gpio_inst_GPIO61  ( HPS_GSENSOR_INT),  //                               .hps_io_gpio_inst_GPIO61

			
		  .hps_0_h2f_reset_reset_n               ( hps_fpga_reset_n ),                //                hps_0_h2f_reset.reset_n
		  .hps_0_f2h_cold_reset_req_reset_n      (~hps_cold_reset ),      //       hps_0_f2h_cold_reset_req.reset_n
		  .hps_0_f2h_debug_reset_req_reset_n     (~hps_debug_reset ),     //      hps_0_f2h_debug_reset_req.reset_n
		  .hps_0_f2h_stm_hw_events_stm_hwevents  (stm_hw_events ),  //        hps_0_f2h_stm_hw_events.stm_hwevents
		  .hps_0_f2h_warm_reset_req_reset_n      (~hps_warm_reset ),      //       hps_0_f2h_warm_reset_req.reset_n
  
    );

	 
	 // Debounce logic to clean out glitches within 1ms
debounce debounce_inst (
  .clk                                  (fpga_clk_50),
  .reset_n                              (hps_fpga_reset_n),  
  .data_in                              (KEY),
  .data_out                             (fpga_debounced_buttons)
);
  defparam debounce_inst.WIDTH = 4;
  defparam debounce_inst.POLARITY = "LOW";
  defparam debounce_inst.TIMEOUT = 50000;               // at 50Mhz this is a debounce time of 1ms
  defparam debounce_inst.TIMEOUT_WIDTH = 16;            // ceil(log2(TIMEOUT))
  
// Source/Probe megawizard instance
hps_reset hps_reset_inst (
  .source_clk (fpga_clk_50),
  .source     (hps_reset_req)
);

altera_edge_detector pulse_cold_reset (
  .clk       (fpga_clk_50),
  .rst_n     (hps_fpga_reset_n),
  .signal_in (hps_reset_req[0]),
  .pulse_out (hps_cold_reset)
);
  defparam pulse_cold_reset.PULSE_EXT = 6;
  defparam pulse_cold_reset.EDGE_TYPE = 1;
  defparam pulse_cold_reset.IGNORE_RST_WHILE_BUSY = 1;

altera_edge_detector pulse_warm_reset (
  .clk       (fpga_clk_50),
  .rst_n     (hps_fpga_reset_n),
  .signal_in (hps_reset_req[1]),
  .pulse_out (hps_warm_reset)
);
  defparam pulse_warm_reset.PULSE_EXT = 2;
  defparam pulse_warm_reset.EDGE_TYPE = 1;
  defparam pulse_warm_reset.IGNORE_RST_WHILE_BUSY = 1;
  
altera_edge_detector pulse_debug_reset (
  .clk       (fpga_clk_50),
  .rst_n     (hps_fpga_reset_n),
  .signal_in (hps_reset_req[2]),
  .pulse_out (hps_debug_reset)
);
  defparam pulse_debug_reset.PULSE_EXT = 32;
  defparam pulse_debug_reset.EDGE_TYPE = 1;
  defparam pulse_debug_reset.IGNORE_RST_WHILE_BUSY = 1;
  
reg [25:0] counter; 
reg  led_level;
always @(posedge fpga_clk_50 or negedge hps_fpga_reset_n)
begin
if(~hps_fpga_reset_n)
begin
                counter<=0;
                led_level<=0;
end

else if(counter==24999999)
        begin
                counter<=0;
                led_level<=~led_level;
        end
else
                counter<=counter+1'b1;
end

//assign LEDR[0]=led_level;
endmodule

  