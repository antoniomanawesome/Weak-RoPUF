//simple ring oscillator using LUTs (inferred inverter chain)
//have to mark as dont_touch so vivado doesn't optimize it away

module ring_osc #(
    parameter integer STAGES = 5
) (
    output logic ro_out
);
    //creating small chain of regs/wires forming oscillation using comb loops
    //using regs to keep it synthesizable and prevent optimization

    //many FPGAs will infer LUT feedback loops tho if you write it carefully
    (* dont_touch = "true", keep = "true" *) logic [STAGES-1:0] node;

    //connect as odd loop: node[i] = ~node[i-1]
    genvar i;
    generate
        for(i = 0; i < STAGES; i++) begin : l_gen
            if (i == 0) begin
                assign node[i] = ~node[STAGES-1];
            end else begin
                assign node[i] = ~node[i-1];
            end
        end
    endgenerate
    assign ro_out = node[STAGES-1];

endmodule