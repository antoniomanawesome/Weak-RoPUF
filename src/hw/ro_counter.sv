//RO counter that counts toggles of ro_out

module ro_counter (
    input  logic clk_ref,
    input  logic start,         //start measurement pulse
    input  logic ro_in,         //async oscillator signal
    input  int   window_cycles, //# clk_ref cycles
    output logic [31:0] count,
    output logic done
);
    //detect rising edge of ro_in------------

    logic ro_sync_0, ro_sync_1, ro_rise;
    always_ff @(posedge clk_ref) begin
        ro_sync_0 <= ro_in;
        ro_sync_1 <= ro_sync_0;
    end
    
    assign ro_rise = ro_sync_0 & ~ro_sync_1;

    //end of rising edge ro_in---------------

    //it's counter time----------------------
    logic [31:0] sample_ticks;
    logic measuring;

    always_ff @(posedge clk_ref) begin
        if (start) begin //start is pulsed, assert measuring, restart the count, reg the cycles
            measuring <= 1'b1;
            sample_ticks <= window_cycles;
            count <= '0;
            done <= 1'b0;
        end else if (measuring) begin //if measuring asserted, count++ if rising edge and if ticks are done, assert done
            if (ro_rise) count <= count + 1'b1;
            if (sample_ticks == '0) begin
                measuring <= 1'b0;
                done <= 1'b1;
            end else sample_ticks <= sample_ticks - 1'b1; //if sample ticks is non zero tick--
        end else begin
            done <= 1'b0;
        end
    end
    
endmodule