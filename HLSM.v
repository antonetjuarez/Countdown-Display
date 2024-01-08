`timescale 1ns / 1ps


module HLSM (Clk, Rst, go, sum, done, R_Data);
input go, Clk, Rst;
output reg [7:0] sum;
output reg done;
//reg [7:0] R_Data;
output [7:0] R_Data; 

reg [4:0] i;
reg [13:0] k;
reg [7:0] temp;
wire [7:0] R_Data;
reg R_en, W_en;

reg [4:0] state, nextstate;
parameter S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4, S5 = 5, S6 = 6, S7 = 7, SW = 8, SD = 9, SW2 = 10, SD2 = 11, SDD = 12; 

//behavioral
//RegFile16x8(R_Addr, W_Addr, R_en, W_en, R_Data, W_Data, Clk, Rst);

(* mark_debug = "true" *) wire [7:0] debug_Reg15, debug_Reg14, debug_Reg13, debug_Reg12, debug_Reg11, debug_Reg10, debug_Reg9;
(* mark_debug = "true" *) wire [7:0] debug_Reg8, debug_Reg7, debug_Reg6, debug_Reg5, debug_Reg4, debug_Reg3, debug_Reg2, debug_Reg1, debug_Reg0;

RegFile16x8 a(i[3:0], i[3:0], R_en, W_en, R_Data, temp - 48, Clk, Rst, 
debug_Reg15, debug_Reg14, debug_Reg13, debug_Reg12, debug_Reg11, debug_Reg10, debug_Reg9, 
debug_Reg8, debug_Reg7, debug_Reg6, debug_Reg5, debug_Reg4, debug_Reg3, debug_Reg2, debug_Reg1, debug_Reg0);

//register vals etc
always @ (posedge Clk) begin
    //i <= 0; done <= 0; 
    if (Rst == 1) begin
        state <= S0;
    end else begin
        state <= nextstate;
        
        case (state)
            S0: begin //SA
                i <= 0; 
                done <= 0; 
                sum <= 0; 
                //R_en <= 0; W_en <= 0;  //since nothing is 
            end
          
            S3: begin   //SD
                //R_en <= 1;
                temp <= R_Data;
                done <= 0; 
                //W_en <= 0;
                
            end
            S4: begin   //SE
                done <= 0; 
                //R_en <= 0; W_en <= 0;
            end
            S5: begin   //SF
                //A[i] <= temp - 48;
                done <= 0; 
                //R_en <= 0; W_en <= 1;
                sum <= sum + (temp-48);
                
            end
            S6: begin   //SG
                done <= 0; 
                //R_en <= 0; W_en <= 0;
                i <= i + 1;
            end
            
            S7: begin   //SH
                done <= 0; 
                //R_en <= 0; W_en <= 0;
                i <= 0; k <= 0;
            end
            
            SW: begin   //wait
                done <= 0;
                k <= k +1;
            end
            
            SW2: begin
                done <= 1; 
                k <= k +1;
            end
            
            SD2: begin  //display A[i]
                done <= 1; i <= i + 1; k <= 0;
            end
            
            SDD: begin      //reset?
                done <= 1; 
            end
            
            default: begin
                done <= 0; 
                //R_en <= 0; W_en <= 0;
            end
            
        endcase
    end
end


//states
always @(*) begin
    //R_en <= 0; W_en <= 0;
    case (state)
            S0: begin   //SA
                if (~go) begin
                    nextstate <= S0;
                end else begin
                    nextstate <= S1;
                    
                end
            end
            
            S1: begin   //SB
                nextstate <= S2;
            end
            
            S2: begin   //SC
                if (i < 16) begin
                    nextstate <= S3;
                end else begin
                    nextstate <= S7;
                end
            end
            
            S3: begin   //SD
                   R_en <= 1;
                nextstate <= S4;
            end
            
            S4: begin   //SE
                R_en <= 0;
                if ((temp > 47) && (temp < 58)) begin
                    nextstate <= S5;
                end else begin
                    nextstate <= S6;
                end
            end
            
            S5: begin   //SF
                W_en <= 1;
                R_en <= 0;
               nextstate <= S6;
            end
            
            S6: begin   //SG
                nextstate <= S2;
                W_en <= 0;
            end
            
            S7: begin   //SH
                nextstate <= SW;
                R_en <= 0;
                W_en <= 0;
            end
            
            SW: begin
                if (k < 10000)begin
                    nextstate <= SW;
                end else begin
                    nextstate <= SD;
                end
            end
            
            SD: begin   //display A[0]
                nextstate <= SW2;
                R_en <= 1;
            end
            
            SW2: begin
                if (k < 10000)begin
                    nextstate <= SW2;
                end else begin
                    nextstate <= SD2;
                end
                R_en <= 1;
            end
            
            SD2: begin  //display A[i]
                R_en <= 1;
                if (i < 14) begin
                    nextstate <= SW2;
                end else begin
                    nextstate <= SDD;
                end
            end
            
            SDD: begin
                R_en <= 1;
                nextstate <= SDD; // S0;
            end
    endcase 
end

assign R_Data2 = R_Data;

endmodule