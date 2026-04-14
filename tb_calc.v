`timescale 1ns/1ps

module tb_calc;

    reg clk;
    reg btnc; // button central
    reg btnac; // button all clear
    reg btnl; // button left
    reg btnr; // button right
    reg btnd; // button down
    reg [15:0] sw; // switch
    reg [15:0] led; // accumulator led 

    calc DUT(
        .clk(clk),
        .btnc(btnc),
        .btnac(btnac),
        .btnl(btnl),
        .btnr(btnr),
        .btnd(btnd),
        .sw(sw),
        .led(led)
    );
    
    // 10ns clk
    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd"); 
        $dumpvars;
    end

    initial begin
        clk = 1'b0;
        @(negedge clk);
        btnac = 1'b1;
        @(negedge clk);
        btnac = 1'b0;
        // 1st check
        @(negedge clk);
        {btnl, btnr, btnd} = 3'b010;
        sw = 16'h285a;
        btnc = 1'b1;
        @(negedge clk);
        if(led != 16'h285a) begin 
            $display("ERROR @%0t, expected = 0x285a, got %0h", $time, led);
            $display("btnl=%b btnr=%b btnd=%b -> alu_op=%b", btnl, btnr, btnd, DUT.alu_op);
        end
        btnc = 1'b0;
        // 2nd check
        @(negedge clk);
        {btnl, btnr, btnd} = 3'b111;
        sw = 16'h04c8;
        btnc = 1'b1;
        @(negedge clk);
        if(led != 16'h2c92) begin
            $display("ERROR @%0t, expected = 0x2c92, got %0h", $time, led);
            $display("btnl=%b btnr=%b btnd=%b -> alu_op=%b", btnl, btnr, btnd, DUT.alu_op);
        end
        btnc = 1'b0;
        // 3rd check
        @(negedge clk);
        {btnl, btnr, btnd} = 3'b000;
        sw = 16'h0005;
        btnc = 1'b1;
        @(negedge clk);
        if(led != 16'h0164) begin
            $display("ERROR @%0t, expected = 0x0164, got %0h", $time, led);
            $display("btnl=%b btnr=%b btnd=%b -> alu_op=%b", btnl, btnr, btnd, DUT.alu_op);
        end
        btnc = 1'b0;
        // 4th check
        @(negedge clk);
        {btnl, btnr, btnd} = 3'b101;
        sw = 16'ha085;
        btnc = 1'b1;
        @(negedge clk);
        if(led != 16'h5e1a) begin
            $display("ERROR @%0t, expected = 0x5e1a, got %0h", $time, led);
            $display("btnl=%b btnr=%b btnd=%b -> alu_op=%b", btnl, btnr, btnd, DUT.alu_op);
        end
        btnc = 1'b0;
        // 5th check
        @(negedge clk);
        {btnl, btnr, btnd} = 3'b100;
        sw = 16'h07fe;
        btnc = 1'b1;
        @(negedge clk);
        if(led != 16'h13cc) begin
            $display("ERROR @%0t, expected = 0x13cc, got %0h", $time, led);
            $display("btnl=%b btnr=%b btnd=%b -> alu_op=%b", btnl, btnr, btnd, DUT.alu_op);
        end
        btnc = 1'b0;
        // 6th check
        @(negedge clk);
        {btnl, btnr, btnd} = 3'b001;
        sw = 16'h0004;
        btnc = 1'b1;
        @(negedge clk);
        if(led != 16'h3cc0) begin
            $display("ERROR @%0t, expected = 0x3cc0, got %0h", $time, led);
            $display("btnl=%b btnr=%b btnd=%b -> alu_op=%b", btnl, btnr, btnd, DUT.alu_op);
        end
        btnc = 1'b0;
        // 7th check
        @(negedge clk);
        {btnl, btnr, btnd} = 3'b110;
        sw = 16'hfa65;
        btnc = 1'b1;
        @(negedge clk);
        if(led != 16'hc7bf) begin
            $display("ERROR @%0t, expected = 0xc7bf, got %0h", $time, led);
            $display("btnl=%b btnr=%b btnd=%b -> alu_op=%b", btnl, btnr, btnd, DUT.alu_op);
        end
        btnc = 1'b0;
        // 8th check
        @(negedge clk);
        {btnl, btnr, btnd} = 3'b011;
        sw = 16'hb2e4;
        btnc = 1'b1;
        @(negedge clk);
        if(led != 16'h14db) begin
            $display("ERROR @%0t, expected = 0x14db, got %0h", $time, led);
            $display("btnl=%b btnr=%b btnd=%b -> alu_op=%b", btnl, btnr, btnd, DUT.alu_op);
        end
        btnc = 1'b0;
        $finish;
    end
endmodule