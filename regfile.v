module regfile #(parameter DATAWIDTH = 32) (
    input clk,
    input resetn,
    input [3:0] readReg1,
    input [3:0] readReg2,
    input [3:0] readReg3,
    input [3:0] readReg4,
    input [3:0] writeReg1,
    input [3:0] writeReg2,
    input [DATAWIDTH-1:0] writeData1,
    input [DATAWIDTH-1:0] writeData2,
    input write,
    output reg [DATAWIDTH-1:0] readData1,
    output reg [DATAWIDTH-1:0] readData2,
    output reg [DATAWIDTH-1:0] readData3,
    output reg [DATAWIDTH-1:0] readData4
);

    reg [DATAWIDTH-1:0] registers [15:0]; // 16 registers of DATAWIDTH bits
    integer i;
    
    always @(posedge clk or negedge resetn) begin
        if(~resetn) begin // active low reset
            for(i = 0; i < 16; i = i + 1) begin
                registers[i] <= 0;
            end
        end
        else begin
            if(write) begin
                registers[writeReg1] <= writeData1; // writeData1 has priority over writeData2  
                if(writeReg1 != writeReg2) begin // if different write addresses then writeData2
                    registers[writeReg2] <= writeData2
                end
            end
        end
    end

    assign readData1 = // combinational read
        (write && (writeReg1 == readReg1)) ? writeData1 : // if write AND writeReg1 == readReg1 then write first then read writeData1
        (write && (writeReg2 == readReg1) && (writeReg1 != readReg1)) ? writeData2 : // else if write AND writeReg2 == readReg1 AND writeReg2 != writeReg1 then write first then read writeData2 
        registers[readReg1]; // else read normaly, no simultanious read and write

    // readData2
    assign readData2 =
        (write && (writeReg1 == readReg2)) ? writeData1 : // if write AND writeReg1 == readReg2 then write first then read writeData1
        (write && (writeReg2 == readReg2) && (writeReg1 != readReg2)) ? writeData2 : // else if write AND writeReg2 == readReg2 AND writeReg2 != writeReg1 then write first then read writeData2 
        registers[readReg2]; // else read normaly, no simultanious read and write

    // readData3
    assign readData3 =
        (write && (writeReg1 == readReg3)) ? writeData1 : // if write AND writeReg1 == readReg3 then write first then read writeData1
        (write && (writeReg2 == readReg3) && (writeReg1 != readReg3)) ? writeData2 : // else if write AND writeReg2 == readReg3 AND writeReg2 != writeReg1 then write first then read writeData2 
        registers[readReg3]; // else read normaly, no simultanious read and write

    // readData4
    assign readData4 =
        (write && (writeReg1 == readReg4)) ? writeData1 : // if write AND writeReg1 == readReg4 then write first then read writeData1
        (write && (writeReg2 == readReg4) && (writeReg1 != readReg4)) ? writeData2 : // else if write AND writeReg2 == readReg4 AND writeReg2 != writeReg1 then write first then read writeData2 
        registers[readReg4]; // else read normaly, no simultanious read and write
endmodule