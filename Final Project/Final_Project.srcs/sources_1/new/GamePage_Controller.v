`timescale 1ns / 1ps


module GamePage_Controller(
        input Key_C, Key_L, Key_R, Key_U, Key_D, Key_Back, Key_Random,
        input Clk,
        input Single_Left, Single_Right, Single_Roller,
        // U
        //LCR
        // D
        output reg Normal, Continue, Next, Reset, Random,
        output reg [3: 0] Display,
        output reg [3: 0] Present_State, Next_State
    );


    parameter [3: 0] KSYX_State = 3'b000;
    parameter [3: 0] PTMS_State = 3'b001;
    parameter [3: 0] LXYH_State = 3'b010;
    parameter [3: 0] Normal_State = 3'b011;
    parameter [3: 0] Continue_State = 3'b100;

    initial begin
        Present_State = KSYX_State;
        Next_State = KSYX_State;
        Display = 1;
        Normal = 0;
        Continue = 0;
        Next = 0;
        Reset = 0;
        Random = 0;
    end

    always @(posedge Clk) begin
        case (Present_State)
            KSYX_State: begin
                if(Key_C || Single_Left)
                    Next_State = PTMS_State;
                else 
                    Next_State = KSYX_State;
            end 

            PTMS_State: begin
                if(Key_L || Key_R || Single_Roller) 
                    Next_State = LXYH_State;
                else if(Key_Back || Single_Right)
                    Next_State = KSYX_State;
                else if(Key_C || Single_Left) 
                    Next_State = Normal_State;
                else
                    Next_State = PTMS_State;
            end
            
            LXYH_State: begin
                if(Key_L || Key_R || Single_Roller) 
                    Next_State = PTMS_State;
                else if(Key_Back || Single_Right)
                    Next_State = KSYX_State;
                else if(Key_C || Single_Left)
                    Next_State = Continue_State;
                else
                    Next_State = LXYH_State;
            end

            Normal_State: begin
                if(Key_Back || Single_Right)
                    Next_State = PTMS_State;
                else 
                    Next_State = Normal_State;
            end

            Continue_State: begin
                if(Key_Back || Single_Right)
                    Next_State = LXYH_State;
                else 
                    Next_State = Continue_State;
            end
        endcase
    end

    always @(Next_State) begin
        Present_State <= Next_State;
    end

    always @(posedge Clk) begin
        case (Present_State)
            KSYX_State: begin
                Display = 2;
                Reset = 1;
            end 

            PTMS_State: begin
                Display = 3;
                Reset = 1;
            end
            
            LXYH_State: begin
                Display = 4;
                Reset = 1;
            end

            Normal_State: begin
                Display = 1;
                Reset = 0;
                Normal = 1;
                Continue = 0;
                Next = Key_C;
                Random = Key_Random;
            end

            Continue_State: begin
                Display = 1;
                Reset = 0;
                Normal = 0;
                Continue = 1;
                Next = 0;
                Random = Key_Random;
            end
        endcase
    end

endmodule
