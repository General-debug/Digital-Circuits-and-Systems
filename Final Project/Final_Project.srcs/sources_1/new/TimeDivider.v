`timescale 1ns / 1ps

module TimeDivider(
    input pulse_input,
    output reg pulse_output
    );
    
    reg[28:0] cnt;
    parameter N = 10;
    initial begin
        cnt = 0;
    end

    always @(posedge pulse_input) begin 
        if(cnt < N - 1)
            cnt <= cnt + 1;
        else cnt <= 0;
    end
    
    always @(posedge pulse_input) begin//
        if(cnt == 0)
            pulse_output <= 1;
        else pulse_output <= 0;
    end
endmodule
