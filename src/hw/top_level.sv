module top_level (
    input logic CLK_100MHZ,
    input logic[3:0] BTN,
    output logic[15:0] LED
);

    ro_puf inst (
        .clk_ref(CLK_100MHZ),
        .start(BTN[0]),
        .puf_response(LED)
    );

endmodule