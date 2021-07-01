`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/21 23:21:09
// Design Name: 
// Module Name: entime_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module entime_tb(
    );
    reg clk;
    wire pulse_output;
    
    entime#(.N(10)) UUT(.clk(clk),.pulse_output(pulse_output));
    
    always begin
        #4.5; clk = 0;
        #5; clk = 1;#0.5;
    end
    
    always @(posedge clk) begin
        #1000;
    end
endmodule
