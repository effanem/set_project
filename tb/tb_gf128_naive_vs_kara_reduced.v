
`timescale 1ns/1ps

module tb_gf128_naive_vs_kara_reduced;

    reg  [127:0] a, b;
    wire [127:0] naive_result;
    wire [127:0] kara_result;

    integer test;

    // Naive modular multiplier
    gf128_naive_reduced u_naive (
        .a(a),
        .b(b),
        .result(naive_result)
    );

    // Karatsuba modular multiplier
    gf128_mul_reduced u_kara (
        .a(a),
        .b(b),
        .result(kara_result)
    );

    initial begin
        $display("Comparing GF(2^128) modular multipliers: Naive vs Karatsuba");

        // -------------------
        // Sanity test
        // -------------------
        a = 128'h1;
        b = 128'h1;
        #1;

        if (naive_result !== kara_result) begin
            $display("Sanity test mismatch!");
            $display("Naive      = %032h", naive_result);
            $display("Karatsuba  = %032h", kara_result);
            $stop;
        end

        // -------------------
        // Random tests
        // -------------------
        for (test = 0; test < 500; test = test + 1) begin
            a = {$random, $random, $random, $random};
            b = {$random, $random, $random, $random};
            #1;

            if (naive_result !== kara_result) begin
                $display("Mismatch at test %0d", test);
                $display("a          = %032h", a);
                $display("b          = %032h", b);
                $display("Naive      = %032h", naive_result);
                $display("Karatsuba  = %032h", kara_result);
                $stop;
            end
        end

        $display("PASS: Naive and Karatsuba modular multipliers match.");
        $finish;
    end

endmodule
