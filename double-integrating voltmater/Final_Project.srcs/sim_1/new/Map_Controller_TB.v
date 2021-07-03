`timescale 1ns / 1ps

module Map_Controller_TB(

    );
    reg Random, Reset, Update;
    wire [16 * 16 - 1: 0] Map;
    reg Clk;

    always begin
        Clk = 0;
        #0.45;
        Clk = 1;
        #0.55;
    end
    Map_Controller UTT(.Clk(Clk), .Random(Random), .Reset(Reset), .Update(Update), .Map(Map));

    initial begin
        Random = 0;
        Reset = 0;
        Update = 0;
    end


    always begin
        Random = 1;
        Reset = 0;
        Update = 0;
        # 10;

        Random = 0;
        Reset = 1;
        Update = 0;
        # 10;

        Random = 1;
        Reset = 0;
        Update = 0;
        # 10;

        Random = 0;
        Reset = 0;
        Update = 1; #1 Update = 0;
        # 10;

        Random = 0;
        Reset = 0;
        Update = 1; #1 Update = 0;
        # 10;

        Random = 0;
        Reset = 0;
        Update = 1; #1 Update = 0;
        # 10;
    end


endmodule
