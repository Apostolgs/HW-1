module calc (
    input reg clk,
    input reg btnc, // button central
    input reg btnac, // button all clear
    input reg btnl, // button left
    input reg btnr, // button right
    input reg btnd, // button down
    input reg [15:0] sw, // switch
    output [15:0] led // accumulator led 
);

    wire [31:0] op1, // operator 1 in 2's complement
    wire [31:0] op2, // operator 2 in 2's complement
    wire [3:0] alu_op, 
    wire zero, // result == 0 flag
    wire [31:0] result, 
    wire ovf // result overflows IF alu_op is add sub or mult

    reg [15:0] accumulator;

    // sign extension
    assign op1 = {{16{accumulator[15]}}, accumulator};
    assign op2 = {{16{sw[15]}}, sw};

    // alu_op control
    calc_enc enc_inst (
        .btnl(btnl),
        .btnr(btnr),
        .btnd(btnd),
        .alu_op(alu_op)
    );

    // ALU
    alu ALU(
        .op1(op1),
        .op2(op2),
        .alu_op(alu_op),
        .zero(zero),
        .result(result),
        .ovf(ovf)
        );

    // Accumulator
    always @(posedge clk) begin
        if(btnac) 
            accumulator <= 16'b0; // synchronous reset
        else if (btnc) 
            accumulator <= result[15:0]; 
    end

    //output
    assign led = accumulator;



endmodule