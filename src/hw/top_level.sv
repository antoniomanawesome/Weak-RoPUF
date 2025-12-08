module top_level (
    input logic CLK_100MHZ,
    input logic[3:0] BTN,
    output logic[15:0] LED,
    output logic UART_TXD
);

    // logic [63:0] puf_data;
    logic [15:0] puf_data;
    logic [7:0] tx_data;
    logic tx_valid;
    logic tx_ready;
    logic send_high_byte;

    // assign LED = puf_data[15:0];
    assign LED = puf_data;

    ro_puf inst (
        .clk_ref(CLK_100MHZ),
        .start(BTN[0]),
        .puf_response(puf_data)
    );

    uart_tx #(.CLK_FREQ(100000000), .BAUD(115200)) uart_inst (
        .clk(CLK_100MHZ),
        .rst(1'b0),
        .tx_data(tx_data),
        .tx_valid(tx_valid),
        .tx_ready(tx_ready),
        .tx(UART_TXD)
    );

    always_ff @(posedge CLK_100MHZ) begin
        tx_valid <= 1'b0;

        if(BTN[0] && tx_ready) begin
            if(!send_high_byte) begin
                // axi_wdata <= puf_data[63:32]; //high half
                tx_data <= puf_data[15:8]; //high byte
                send_high_byte <= 1'b1;
                tx_valid <= 1'b1;
            end else begin
                // axi_wdata <= puf_data[31:0] //low half
                tx_data <= puf_data[7:0]; //low byte
                send_high_byte <= 1'b0;
                tx_valid <= 1'b1;
            end
        end
    end
endmodule