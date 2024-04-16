module pulse_generator(
    input clk,
    input rst,
    input [7:0] i_data,
    output reg [5:0] pulses_out,
	 output reg [2:0] state_out,
	 output reg [31:0] SD_data_out,
	 output reg [14:0] adr_reg_out,
	 output reg d_flipflop,
	 output reg cpy_en_out
	 
);

reg [14:0] adr_reg = 0;
reg [5:0] pulses;
reg [2:0] state;
reg SM1 = 1'b0;
reg [3:0] SM = 4'b0000;
reg [31:0] SD_data = 0;
reg save_data_pulse = 0;
reg cpy_en = 0;
reg [31:0] bank_count = 0;

always @(posedge clk ) 

begin
	
   case(SM1)
	
		1'b0: begin
					
				
					if (i_data < 8'd51) //121 for LKH | 51 for CL
						begin
							pulses = 6'b000001;
							state = 3'b001;
							d_flipflop = 1;
							
						end 
		  
					else if (i_data >= 8'd51 & i_data < 8'd102) //242 for LKH | 102 for CL
						begin
							pulses = 6'b000010;
							state = 3'b010;
							d_flipflop = 1;
						end 
		  
					else if (i_data >= 8'd102 & i_data < 8'd180) //244 for LKH | 180 for CL
						begin
							pulses = 6'b000100;
							state = 3'b011;
							d_flipflop = 1;
						end 
					  
					else if (i_data >= 8'd180 & i_data < 8'd194) //246 for LKH | 194 for CL
						begin
							pulses = 6'b001000;
							state = 3'b100;
							d_flipflop = 1;
////////////////////FOR FPGA-TO-FPGA TESTS ONLY////////////////////////////
//							pulses = 6'b000100;
//							state = 3'b011;
///////////////////////////////////////////////////////////////////////////
						end 
					  
					else if (i_data >= 8'd194 & i_data < 8'd208) //248 for LKH | 208 for CL
						begin
							pulses = 6'b010000;
							state = 3'b101;
							d_flipflop = 1;
////////////////////FOR FPGA-TO-FPGA TESTS ONLY////////////////////////////
//							pulses = 6'b000100;
//							state = 3'b011;
///////////////////////////////////////////////////////////////////////////
						end 
					  
					else if (i_data >= 8'd208 & i_data < 8'd229) //250 for LKH | 229 for CL
						begin
							pulses = 6'b100000;
							state = 3'b110;
							d_flipflop = 1;
////////////////////FOR FPGA-TO-FPGA TESTS ONLY////////////////////////////
//							pulses = 6'b000100;
//							state = 3'b011;
///////////////////////////////////////////////////////////////////////////
						end 
					  
					else if (i_data >= 8'd229 & i_data <= 8'd255) //255 for LKH | 255 for CL
						begin
							pulses = 6'b000000;
							state = 3'b111;
							d_flipflop = 1;
////////////////////FOR FPGA-TO-FPGA TESTS ONLY////////////////////////////
//							pulses = 6'b001000;
//							state = 3'b100;
///////////////////////////////////////////////////////////////////////////
						end
					
					case(SM)
		
						4'b0000: begin
										adr_reg = adr_reg + 1;
										
										SD_data[2:0] = state;
										SM <= 4'b0001;
									end
									
						4'b0001: begin
										SD_data[5:3] = state;
										SM <= 4'b0010;
									end
									
						4'b0010: begin
										SD_data[8:6] = state;
										SM <= 4'b0011;
									end
						
						4'b0011: begin
										SD_data[11:9] = state;
										SM <= 4'b0100;
									end
						
						4'b0100: begin
										SD_data[14:12] = state;
										SM <= 4'b0101;
									end
						
						4'b0101: begin
										SD_data[17:15] = state;
										SM <= 4'b0110;
									end
						
						4'b0110: begin
										SD_data[20:18] = state;
										SM <= 4'b0111;
									end
									
						4'b0111: begin
										SD_data[23:21] = state;
										SM <= 4'b1000;
									end
									
						4'b1000: begin
										SD_data[26:24] = state;
										SM <= 4'b1001;
									end		
									
						4'b1001: begin
										
										if(adr_reg == 16383 | adr_reg == 32767)
											begin
												cpy_en <= ~cpy_en;
												SD_data = bank_count;
												save_data_pulse = 1;
												bank_count <= bank_count + 1;
												SM <= 4'b0000;
											end
											
										else
											begin
												SD_data[29:27] = state;
												SM <= 4'b0000;
											end
									end	
					endcase
					
					if(adr_reg == 16383 | adr_reg == 32767)
						begin
							pulses = 6'b000000;
							state = 3'b000;
						end
						
					SM1 <= 1'b1;
				end
		
		1'b1: begin
					pulses = 6'b000000;
					state = 3'b000;
					d_flipflop = 0;
					SM1 <= 1'b0;
				end

         

   endcase 
	
   pulses_out = pulses;
	state_out = state;
	SD_data_out = SD_data;
	//save_data_pulse_out = save_data_pulse;
	adr_reg_out = adr_reg;
	cpy_en_out = cpy_en;
end

endmodule // pulse_generator