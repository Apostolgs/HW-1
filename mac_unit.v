`include "alu.v"

module mac_unit (
    input [31:0] op1, // input
    input [31:0] op2, // weight
    input [31:0] op3, // bias
    output [31:0] total_result, // total_result = input * weight + bias
    output zero_mul,
    output zero_add,
    output ovf_mul,
    output ovf_add
);

    wire [31:0] intermediate_result;

    localparam [3:0] ALUOP_ADD = 4'b0100;
    localparam [3:0] ALUOP_MULT = 4'b0110;

    alu ALU_MUL( // multiply op1(input) by op2(weight)
        .op1(op1),
        .op2(op2),
        .alu_op(ALUOP_MULT),
        .zero(zero_mul),
        .result(intermediate_result),
        .ovf(ovf_mul)
    );

    alu ALU_ADD( // add intermediate_result to op3(bias)
        .op1(intermediate_result),
        .op2(op3),
        .alu_op(ALUOP_ADD),
        .zero(zero_add),
        .result(total_result),
        .ovf(ovf_add)
    );



endmodule