module calc_env (
    input btnl,
    input btnr,
    input btnd,
    output [3:0] alu_op
);
    //------------alu_op[0]-------------//
    wire not_btnl;
    wire not_btnd;
    wire l_and_r;
    wire notl_and_d;
    wire notd_and_lr;

    not(not_btnd, btnd);
    not(not_btnl, btnl);
    and(l_and_r, btnl, btnr);
    and(notl_and_d, not_btnl, btnd);
    and(notd_and_lr, not_btnd, l_and_r);
    or(alu_op[0], notl_and_d, notd_and_lr);
    //-----------------------//
    
    //------------alu_op[1]-------------//
    wire not_btnr;
    wire nr_or_nd;

    not(not_btnr, btnr);
    or(nr_or_nd, not_btnr, not_btnd);
    and(alu_op[1], btnl, nr_or_nd);
    //-----------------------//

    //------------alu_op[2]-------------//
    wire nl_and_r;
    wire d_xor_r;
    wire not_d_xor_r;
    wire l_and_not_d_xor_r;

    and(nl_and_r, not_btnl, btnr);
    xor(d_xor_r, btnr, btnd);
    not(not_d_xor_r, d_xor_r);
    and(l_and_not_d_xor_r, not_d_xor_r, btnl);
    or(alu_op[2], l_and_not_d_xor_r, nl_and_r);
    //-----------------------//

    //------------alu_op[3]-------------//
    wire l_and_d;

    and(l_and_d, btnl, btnd);
    or(alu_op[3], l_and_d, l_and_r);
    //-----------------------//
    
endmodule