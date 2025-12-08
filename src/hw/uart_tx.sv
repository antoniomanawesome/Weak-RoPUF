module uart_tx #(
    parameter CLK_FREQ = 100_000_000,   // 100 MHz
    parameter BAUD = 115200
)(
    input  logic clk,
    input  logic rst,
    input  logic [7:0] tx_data,
    input  logic tx_valid,
    output logic tx_ready,
    output logic tx
);

    localparam integer CLKS_PER_BIT = CLK_FREQ / BAUD;
    typedef enum logic [1:0]{
        IDLE, 
        START, 
        DATA, 
        STOP
    } state_t;
    
    state_t state;
    logic [15:0] clk_cnt;
    logic [2:0] bit_index;
    logic [7:0] data_buf;
    logic tx_reg;

    assign tx = tx_reg;
    assign tx_ready = (state == IDLE);

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            tx_reg <= 1'b1;
            clk_cnt <= 0;
            bit_index <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx_reg <= 1'b1;
                    clk_cnt <= '0;
                    bit_index <= 0;
                    if (tx_valid) begin
                        data_buf <= tx_data;
                        state <= START;
                    end
                end

                START: begin
                    tx_reg <= 1'b0; // start bit
                    if (clk_cnt < CLKS_PER_BIT-1)
                        clk_cnt <= clk_cnt + 1;
                    else begin
                        clk_cnt <= '0;
                        state <= DATA;
                    end
                end

                DATA: begin
                    tx_reg <= data_buf[bit_index];
                    if (clk_cnt < CLKS_PER_BIT-1)
                        clk_cnt <= clk_cnt + 1;
                    else begin
                        clk_cnt <= '0;
                        if (bit_index < 7)
                            bit_index <= bit_index + 1;
                        else
                            state <= STOP;
                    end
                end

                STOP: begin
                    tx_reg <= 1'b1; // stop bit
                    if (clk_cnt < CLKS_PER_BIT-1)
                        clk_cnt <= clk_cnt + 1;
                    else begin
                        clk_cnt <= '0;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

endmodule
