//top-level 
//instantiate 128 ROs, count, compare

module ro_puf (
    input logic clk_ref,
    input logic start,
    output logic [63:0] puf_response
    //do we need to add UART or some interface to stream responses??
);
    localparam RO_COUNT = 128;
    localparam PAIRS = 64;

    //raw oscillator outputs
    logic [RO_COUNT-1:0] ro_out;

    //instantiate ROs (have to place each ro instance using constraints in XDC)
    //0-127
    genvar ri;
    generate
        for(ri = 0; ri < RO_COUNT; ri++) begin : l_ro_inst
            ring_osc #(.STAGES(5)) ro_i (.ro_out(ro_out[ri]));
        end
    endgenerate

    //counters and comparators
    logic [31:0] counts [RO_COUNT-1:0];
    logic done_flags [RO_COUNT-1:0];

    generate
        for (ri = 0; ri < RO_COUNT; ri++) begin : l_counters
            ro_counter rc (
                .clk_ref(clk_ref),
                .start(start),
                .ro_in(ro_out[ri]),
                .window_cycles(50000), //depends on our clk_ref freq
                .count(counts[ri]),
                .done(done_flags[ri])
            );
        end
    endgenerate

    //compare pairs (pair mapping: 0 vs 64, 1 vs 65, let's choose the mapping later)
    genvar pi;
    generate
        for (pi = 0; pi < PAIRS; pi++) begin : l_cmp
            always_comb begin
                puf_response[pi] = (counts[pi] > counts[pi + PAIRS]) ? 1'b1 : 1'b0;
            end
        end
    endgenerate

endmodule
