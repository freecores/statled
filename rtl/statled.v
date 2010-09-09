`timescale 1ns / 100ps
/******************************************************************************
*  Status LED module
*
*  Use single LED ouput to displays various internal states as blink codes.
*  http://www.opencores.org/cores/statled
*
******************************************************************************/
module statled (
    input       		clk,
    input       		rst,
    input		[3:0]	status,
    output              led
);

`include "statled_par.v"

reg [32:0] 	pre;            // Prescaler
reg [7:0]	bcnt;           // Bit counter
reg [15:0] 	lsr;            // LED shift register 
reg [15:0]	cr;             // Code register
reg [3:0] 	str;            // Status register
wire 		rate;           // LED rate

//-----------------------------------------------------------------------------
// LED rate  
//
always @(posedge clk or posedge rst)
	if (rst) 
        pre <= #tDLY 0;
    else if (rate)
        pre <= #tDLY 0;
    else
        pre <= #tDLY pre + 1;

assign rate = (pre == STATLED_PULSE_CLKCNT);

//-----------------------------------------------------------------------------
// Capture status inputs
//
always @(posedge clk or posedge rst)
	if (rst) 
        str <= #tDLY 0;
    else 
        str <= #tDLY status;

//-----------------------------------------------------------------------------
// Shift register and bit counter
//
always @(posedge clk or posedge rst)
	if (rst) 
        bcnt <= #tDLY 15;
	else if (bcnt == 16)
        bcnt <= #tDLY 0;
	else if (rate)
        bcnt <= #tDLY bcnt + 1;

always @(posedge clk or posedge rst)
	if (rst) 
        lsr <= #tDLY 0;
	else if (bcnt == 16)
        lsr <= #tDLY cr;
	else if (rate)
        lsr <= #tDLY lsr << 1;

assign led = rst? 1 : lsr[15];	

//-----------------------------------------------------------------------------
// Codes 
//
always @*
    case(str) 
		0: cr = CODE_50_50;           // Default code
		1: cr = CODE_ONE;             // State 1 
		2: cr = CODE_TWO;             // State 2
		3: cr = CODE_THREE;           // ....
		4: cr = CODE_FOUR;            //
		5: cr = CODE_FIVE;            //
		6: cr = CODE_SIX;             //
		
		default: cr = 0;	         
	endcase	
				 
endmodule
