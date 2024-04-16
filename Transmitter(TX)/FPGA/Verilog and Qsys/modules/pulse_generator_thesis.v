module pulse_generator(
    input clk,
    input [7:0] rng_bits,
    output reg [5:0] pulses
);

    always @(posedge clk) 
	    begin			
            if (rng_bits < 8'd51)
                begin
                    pulses = 6'b000001; // signal R
                end
            else if (rng_bits >= 8'd51 & rng_bits < 8'd102)
                begin
                    pulses = 6'b000010; // signal L
                end 
            else if (rng_bits >= 8'd102 & rng_bits < 8'd180)
                begin
                    pulses = 6'b000100; // signal H
                end 
            else if (rng_bits >= 8'd180 & rng_bits < 8'd194)
                begin
                    pulses = 6'b001000; // decoy R
                end 
            else if (rng_bits >= 8'd194 & rng_bits < 8'd208)
                begin
                    pulses = 6'b010000; // decoy L
                end 
            else if (rng_bits >= 8'd208 & rng_bits < 8'd229)
                begin
                    pulses = 6'b100000; // decoy H
                end  
            else if (rng_bits >= 8'd229 & rng_bits <= 8'd255)
                begin
                    pulses = 6'b000000; // vacuum
                end
        end
endmodule