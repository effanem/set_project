`timescale 1ns/1ps

module tb_gf64_pipe2;

    reg clk;
    reg rst;
    reg valid_in;
    reg [63:0] a;
    reg [63:0] b;

    wire valid_out;
    wire [127:0] product;

    // -------------------------
    // DUT
    // -------------------------
    gf64_mul_pipe2 dut (
        .clk(clk),
        .rst(rst),
        .valid_in(valid_in),
        .a(a),
        .b(b),
        .valid_out(valid_out),
        .product(product)
    );

    // -------------------------
    // Golden reference (original combinational)
    // -------------------------
    wire [127:0] golden_product;

    gf64_mul ref_model (
        .a(a),
        .b(b),
        .product(golden_product)
    );

    // -------------------------
    // Pipeline delay registers (2-cycle latency)
    // -------------------------
    reg [127:0] golden_d1, golden_d2;
    reg valid_d1, valid_d2;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            golden_d1 <= 0;
            golden_d2 <= 0;
            valid_d1  <= 0;
            valid_d2  <= 0;
        end else begin
            golden_d1 <= golden_product;
            golden_d2 <= golden_d1;

            valid_d1  <= valid_in;
            valid_d2  <= valid_d1;
        end
    end

    // -------------------------
    // Clock generation (100 MHz)
    // -------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // -------------------------
    // Stimulus
    // -------------------------
    integer i;

    initial begin
        rst = 1;
        valid_in = 0;
        a = 0;
        b = 0;

        #20;
        rst = 0;

        // -------------------------
        // Single transaction test
        // -------------------------
        @(posedge clk);
        valid_in = 1;
        a = 64'h123456789ABCDEF0;
        b = 64'h0FEDCBA987654321;

        @(posedge clk);
        valid_in = 0;

        // wait some cycles
        repeat (5) @(posedge clk);

        // -------------------------
        // Continuous streaming test
        // -------------------------
        for (i = 0; i < 100; i = i + 1) begin
            @(posedge clk);
            valid_in = 1;
            a = $random;
            b = $random;
        end

        @(posedge clk);
        valid_in = 0;

        // Drain pipeline
        repeat (5) @(posedge clk);

        $display("=====================================");
        $display(" ALL TESTS PASSED SUCCESSFULLY ");
        $display("=====================================");
        $finish;
    end

    // -------------------------
    // Checker
    // -------------------------
    always @(posedge clk) begin
        if (!rst) begin

            // Valid alignment check
            if (valid_out !== valid_d2) begin
                $display("VALID MISALIGNMENT at time %0t", $time);
                $stop;
            end

            // Data check
            if (valid_out) begin
                if (product !== golden_d2) begin
                    $display("DATA MISMATCH at time %0t", $time);
                    $display("Expected = %h", golden_d2);
                    $display("Got      = %h", product);
                    $stop;
                end
            end

        end
    end

endmodule

