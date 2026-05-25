`timescale 1ns/1ps

module tb_gf128_mul_reduced;

    reg  [127:0] a, b;
    wire [255:0] prod_naive;
    wire [127:0] result;

    reg  [127:0] expected;
    integer test;

    // Golden raw multiplier
    gf128_naive u_naive (
        .a(a),
        .b(b),
        .product(prod_naive)
    );

    // DUT
    gf128_mul_reduced u_dut (
        .a(a),
        .b(b),
        .result(result)
    );

    // Manual AES-GCM reduction
    function [127:0] gf128_reduce;
        input [255:0] in;
        reg [255:0] r;
        integer k;   // <-- declare loop variable here
        begin
            r = in;

            for (k = 255; k >= 128; k = k - 1) begin
                if (r[k]) begin
                    r[k] = 1'b0;

                    r[k-128]     = r[k-128]     ^ 1'b1;
                    r[k-128 + 1] = r[k-128 + 1] ^ 1'b1;
                    r[k-128 + 2] = r[k-128 + 2] ^ 1'b1;
                    r[k-128 + 7] = r[k-128 + 7] ^ 1'b1;
                end
            end

            gf128_reduce = r[127:0];
        end
    endfunction


    initial begin
        $display("Starting GF(2^128) Modular Multiplication Test...");

        // Sanity test
        a = 128'h1;
        b = 128'h1;
        #1;

        expected = gf128_reduce(prod_naive);

        if (result !== expected) begin
            $display("ERROR: 1 x 1 mismatch");
            $display("Expected = %032h", expected);
            $display("DUT      = %032h", result);
            $stop;
        end

        // Random tests
        for (test = 0; test < 500; test = test + 1) begin
            a = {$random, $random, $random, $random};
            b = {$random, $random, $random, $random};
            #1;

            expected = gf128_reduce(prod_naive);

            if (result !== expected) begin
                $display("Mismatch at test %0d", test);
                $display("a        = %032h", a);
                $display("b        = %032h", b);
                $display("Expected = %032h", expected);
                $display("DUT      = %032h", result);
                $stop;
            end
        end

        $display("PASS: gf128_mul_reduced verified successfully.");
        $finish;
    end

endmodule
