`timescale 1ns / 1ps

module Map_Controller(
    input Clk, Random, Reset, Update, 
    input Add, 
    input [3: 0] Xcoord, Ycoord,
    output reg [16 * 16 - 1: 0] Map

    );
    integer i;
    reg [7: 0] Count;

    parameter N = 16;

    reg [16 * 16 - 1: 0] Next_Map;


    parameter [2: 0] Idle_State = 2'b00;
    parameter [2: 0] Random_State = 2'b01;
    parameter [2: 0] Update_State_0 = 2'b10;
    parameter [2: 0] Update_State_1 = 2'b11;

    initial begin
        // Present_State = Idle_State;
        Map = 0;
        Next_Map = 0;
        Count = 0;
    end

    // always @(*) begin
    //     if(Reset == 1) 
    //         Next_State = Idle_State;
    //     else if(Random == 1) 
    //         Next_State = Random_State;
    // end
    
    always @(negedge Clk) begin
        Map = Next_Map;
    end
    
    reg[30:0] seed;

    always @(posedge Clk) begin
        
        if(Reset)
            Next_Map = 0;
        else if(Random) begin

            Next_Map[21] = 1;
            Next_Map[35] = 1;
            Next_Map[37] = 1;
            Next_Map[52] = 1;
            Next_Map[53] = 1;

            // seed = 233;
            // for(i = 0; i < N * N; i = i + 1) begin
            //     seed = seed * 23333 + 114514;
            //     Next_Map[i] = seed % 2;
            //     // if(rand < 30) 
            //     //     Next_Map[i] = 1;
            //     // else 
            //     //     Next_Map[i] = 0;
            // end
        end
        else if(Update) begin
            for(i = 0; i < N * N; i = i + 1) begin
                Count = 0;
                if(i % N > 0) begin //左
                    if(i / N > 0)
                        Count = Count + Map[i - N - 1]; //左上
                    Count = Count + Map[i - 1]; //左中
                    if(i / N < N - 1)
                        Count = Count + Map[i + N - 1]; //左下
                end

                if(i / N > 0)
                    Count = Count + Map[i - N]; // 中上
                if(i / N < N - 1)
                    Count = Count + Map[i + N]; // 中下

                if(i % N < N - 1) begin //右
                    if(i / N > 0)
                        Count = Count + Map[i - N + 1]; //右上
                    Count = Count + Map[i + 1]; //右中
                    if(i / N < N - 1)
                        Count = Count + Map[i + N + 1]; //右下
                end

                case (Map[i])
                    0: begin
                        if(Count == 3) Next_Map[i] = 1;
                        else Next_Map[i] = 0;
                    end
                    1: begin
                        if(Count < 2 || Count > 3) 
                            Next_Map[i] = 0;
                        if(2 <= Count && Count <= 3)
                            Next_Map[i] = 1;
                    end
                endcase

            end
        end
        else if(Add) begin
            Next_Map = Map;
            Next_Map[Xcoord * N + Ycoord] = 1;
        end
        else
            Next_Map = Map;
    end




endmodule
