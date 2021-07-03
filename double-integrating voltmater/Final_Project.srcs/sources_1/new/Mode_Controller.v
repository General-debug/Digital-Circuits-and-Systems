`timescale 1ns / 1ps

module Mode_Controller(
    // input Start, 
    input Reset, Normal, Continue, Clk, Next, Key_C, Key_L, Key_R, Key_U, Key_D, Key_Add,
    input [3: 0] Xgrid, Ygrid,
    input Cursor_Valid, Left, Single_Left,
    input pulse_Update,

    output reg Update, 
    output reg [2: 0] Present_State, Next_State,
    output reg Add, Twinkle, 
    output reg [3: 0] Xcoord, Ycoord
    );
    
    parameter [10: 0] Width = 16;

    parameter [2: 0] Idle_State = 3'b000;
    // parameter [2: 0] Ready_State = 3'b001;
    parameter [2: 0] Normal_State = 3'b010;
    parameter [2: 0] Continue_Update_State = 3'b011;
    parameter [2: 0] Continue_Noupdate_State = 3'b100;
    parameter [2: 0] Add_State = 3'b101;

    initial begin
        Present_State = Idle_State;
        Next_State = Idle_State;
        Update = 0;
        Twinkle = 0;
        Add = 0;
        Xcoord = 0;
        Ycoord = 0;
    end


    always @(*) begin
        if(Reset == 1)
            Next_State = Idle_State;
        else begin
            case (Present_State)
                Idle_State: begin
                    if(Continue == 1)
                        Next_State = Continue_Noupdate_State;
                    else if(Normal == 1)
                        Next_State = Normal_State;
                    else
                        Next_State = Idle_State;
                end

                Normal_State: begin
                    if(Key_Add)
                        Next_State = Add_State;
                    else if(Continue == 1)
                        Next_State = Continue_Noupdate_State;
                    else if(Normal == 1)
                        Next_State = Normal_State;
                    else
                        Next_State = Idle_State;
                end

                Continue_Noupdate_State: begin
                    if(Key_Add)
                        Next_State = Add_State;
                    else if(Continue == 1) begin
                        if(pulse_Update)
                            Next_State = Continue_Update_State;
                        else 
                            Next_State = Continue_Noupdate_State;
                    end
                    else if(Normal == 1)
                        Next_State = Normal_State;
                    else
                        Next_State = Idle_State;
                end
                
                Continue_Update_State: begin
                    if(Key_Add)
                        Next_State = Add_State;
                    else if(Continue == 1) begin
                        if(pulse_Update)
                            Next_State = Continue_Update_State;
                        else 
                            Next_State = Continue_Noupdate_State;
                    end
                    else if(Normal == 1)
                        Next_State = Normal_State; 
                    else
                        Next_State = Idle_State;
                end

                Add_State: begin
                    if(Key_Add) begin
                        if(Continue == 1)
                            Next_State = Continue_Noupdate_State;
                        else if(Normal == 1)
                            Next_State = Normal_State;
                        else
                            Next_State = Idle_State;
                    end
                    else
                        Next_State = Add_State;
                end

            endcase
        end
        
    end

    always @(posedge Clk) begin
        Present_State <= Next_State;
    end

    always @(posedge Clk) begin
        case (Present_State)

            Idle_State: begin
                Update = 0;
                Twinkle = 0;
                Add = 0;
                // Display = 1;
            end

            Normal_State: begin
                Update = Next | Single_Left;
                Twinkle = 0;
                Add = 0;
                // Display = 1;
            end

            Continue_Update_State: begin
                Update = 1;
                Twinkle = 0;
                Add = 0;
                // Display = 1;
            end

            Continue_Noupdate_State: begin
                Update = 0;
                Twinkle = 0;
                Add = 0;
                // Display = 1;
            end

            Add_State: begin
                Update = 0;
                Twinkle = 1;
                if(Key_L)
                    Ycoord = Ycoord > 0 ? Ycoord - 1 : 0;
                if(Key_R)
                    Ycoord = Ycoord < Width - 1 ? Ycoord + 1 : Width - 1;
                if(Key_U)
                    Xcoord = Xcoord > 0 ? Xcoord - 1 : 0;
                if(Key_D)
                    Xcoord = Xcoord < Width - 1 ? Xcoord + 1 : Width - 1;

                if(Cursor_Valid) begin
                    Xcoord = Xgrid;
                    Ycoord = Ygrid;
                end
                
                if(Key_C || Left) Add = 1;
                else Add = 0;
            end
        endcase
    end

endmodule
