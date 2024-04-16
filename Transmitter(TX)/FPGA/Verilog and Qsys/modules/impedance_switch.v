DPLL1(
	.refclk(CLOCK_50),
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
	.phase_en(shift_en_0),
	.scanclk(CLOCK_50),
	.updn(updn_0),
	.cntsel(cntsel_0)
	);

DPLL2(
	.refclk(CLOCK_50),
	.locked(lock_1),
	.rst(~KEY[1]),
	.phase_done	(phase_done_1),
	.outclk_0(c7),
	.outclk_1(c8),
	.outclk_2(c9),
	.outclk_3(c10),
	.outclk_4(c11),
	.outclk_5(c12),
	.phase_en(shift_en_1),
	.scanclk(CLOCK_50),
	.updn(updn_1),
	.cntsel(cntsel_1)
	);

assign sig_R = (c0 & c1) &  pulses[0];
assign dec_R = (c2 & c3) &  pulses[3];

assign sig_L = (c4 & c5) &  pulses[1];
assign dec_L = (c6 & c7) & pulses[4];

assign sig_H = (c8 & c9) & pulses[2];
assign dec_H = (c10 & c11) & pulses[5];




assign GPIO[1] = pulses[3] ? (1'bZ):(sig_R);
assign GPIO[3] = pulses[0] ? (1'bZ):(dec_R);

assign GPIO[7] = pulses[4] ? (1'bZ):(sig_L);
assign GPIO[9] = pulses[1] ? (1'bZ):(dec_L);

assign GPIO[15] = pulses[5] ? (1'bZ):(sig_H);
assign GPIO[17] = pulses[2] ? (1'bZ):(dec_H);