`include "mac_unit.v"
`include "regfile.v"

module nn(
    input [31:0] input_1,
    input [31:0] input_2,
    input clk,
    input resetn,
    input enable,
    output [31:0] final_output,
    output total_ovf,
    output total_zero,
    output [2:0] ovf_fms_stage,
    output [2:0] zero_fsm_stage
);
    // initial instantiations
    localparam [3:0] ALUOP_AR_RIGHT = 4'b0010;
    wire overflow_detected;

    reg [31:0] inter_1, inter_2;
    reg [31:0] inter_3, inter_4;
    reg [31:0] inter_5;

    reg [31:0] final_output_reg;

    reg total_ovf_reg;
    reg total_zero_reg;

    reg [2:0] ovf_stage_reg;
    reg [2:0] zero_stage_reg;


    // module instantiations
    // regfile stores biases weights and intermediate results if needed
    // Register     |   Signal          |   Description 
    // address      |   to save         |
    //----------------------------------------------------
    // 0x0          |   0               |   reserved to zero
    // 0x1          |   0               |   reserved to zero
    // 0x2          |   shift_bias_1    |   Τιμή μετατόπισης εισόδου 1
    // 0x3          |   shift_bias_2    |   Τιμή μετατόπισης εισόδου 2
    // 0x4          |   weight_1        |   Βάρος νευρώνα 1
    // 0x5          |   bias_1          |   Πόλωση νευρώνα 1
    // 0x6          |   weight_2        |   Βάρος νευρώνα 2
    // 0x7          |   bias_2          |   Πόλωση νευρώνα 2
    // 0x8          |   weight_3        |   Βάρος νευρώνα 3 - 1ης εισόδου
    // 0x9          |   weight_4        |   Βάρος νευρώνα 3 - 2ης εισόδου
    // 0x10         |   bias_3          |   Πόλωση νευρώνα 3
    // 0x11         |   shift_bias_3    |   Τιμή μετατόπισης εξόδου
    // 0x12 - 0x15  |   -               |   reserved to zero or for intermediate FSM results
    regfile #(.DATAWIDTH(32)) regfile_unit (
        .clk(clk),
        .resetn(resetn),
        .readReg1(),
        .readReg2(),
        .readReg3(),
        .readReg4(),
        .writeReg1(),
        .writeReg2(),
        .writeData1(),
        .writeData2(),
        .write(),
        .readData1(),
        .readData2(),
        .readData3(),
        .readData4()
    );



    alu alu_unit_1(
        .op1(input_1),
        .op2(), 
        .alu_op(ALUOP_AR_RIGHT), 
        .zero(), 
        .result(), 
        .ovf() 
    );

    alu alu_unit_2(
        .op1(input_2),
        .op2(), 
        .alu_op(ALUOP_AR_RIGHT), 
        .zero(), 
        .result(), 
        .ovf() 
    );

    mac_unit mac_unit_1(
        .op1(), 
        .op2(), 
        .op3(), 
        .total_result(), 
        .zero_mul(),
        .zero_add(),
        .ovf_mul(),
        .ovf_add()
    );

    mac_unit mac_unit_2(
        .op1(), 
        .op2(), 
        .op3(), 
        .total_result(), 
        .zero_mul(),
        .zero_add(),
        .ovf_mul(),
        .ovf_add()
    );
    //-------------------------------------


    // fsm states grey coded
    localparam [2:0] DEACTIVATED = 3'b000;
    localparam [2:0] LOADING = 3'b001;
    localparam [2:0] PREPROCESSING = 3'b011;
    localparam [2:0] INPUT = 3'b010;
    localparam [2:0] OUTPUT = 3'b110;
    localparam [2:0] POSTPROCESSING = 3'b100;
    localparam [2:0] IDLE = 3'b101;

    reg [2:0] current_state, next_state;

    // state transition block
    always @(posedge clk or negedge resetn) begin 
        if(~resetn) begin 
            current_state <= DEACTIVATED;
        end
        else begin
            current_state <= next_state;
        end
    end

    //next state logic
    always @* begin
        case(current_state)
            DEACTIVATED : begin
                if (enable)
                    next_state = LOADING;
                else
                    next_state = DEACTIVATED;
            end
            LOADING : begin
                next_state = IDLE;
            end
            IDLE : begin
                if(enable)
                    next_state = PREPROCESSING;
                else
                    next_state = IDLE;
            end
            PREPROCESSING : begin
                if(total_ovf_reg)
                    next_state = IDLE;
                else
                    next_state = INPUT;
            end
            INPUT : begin
                if (total_ovf_reg)
                    next_state = IDLE;
                else
                    next_state = OUTPUT;
            end
            OUTPUT : begin
                if (total_ovf_reg)
                    next_state = IDLE;
                else
                    next_state = POSTPROCESSING;
            end
            POSTPROCESSING : begin
                next_state = IDLE;
            end
        endcase
    end

    // output
    always @(posedge clk or negedge resetn) begin
        if (~resetn) begin
            inter_1 <= 0;
            inter_2 <= 0;
            inter_3 <= 0;
            inter_4 <= 0;
            inter_5 <= 0;

            final_output_reg <= 0;

            total_ovf_reg <= 0;
            total_zero_reg <= 0;

            ovf_stage_reg <= 3'b111;
            zero_stage_reg <= 3'b111;
        end
        else begin
            case(current_state)

                LOADING: begin
                    total_ovf_reg <= 0;
                    total_zero_reg <= 0;
                    ovf_stage_reg <= 3'b111;
                    zero_stage_reg <= 3'b111;
                end

                PREPROCESSING: begin
                    // placeholders for now (you will connect ALU outputs later)
                    inter_1 <= inter_1;
                    inter_2 <= inter_2;
                end

                INPUT: begin
                    inter_3 <= inter_3;
                    inter_4 <= inter_4;
                end

                OUTPUT: begin
                    inter_5 <= inter_5;
                end

                POSTPROCESSING: begin
                    final_output_reg <= inter_5;
                end

                default: begin
                    // do nothing
                end

            endcase
        end
    end

    assign final_output = total_ovf_reg ? 32'h7FFFFFFF : final_output_reg;
    assign total_ovf = total_ovf_reg;
    assign total_zero = total_zero_reg;
    assign ovf_fms_stage = ovf_stage_reg;
    assign zero_fsm_stage = zero_stage_reg;

endmodule