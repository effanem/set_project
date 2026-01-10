`timescale 1ns/1ps

module tb_gf128_compare;

    reg  [127:0] a, b;
    wire [255:0] prod_naive;
    wire [255:0] prod_kara;

    integer i;
    integer test;

    // Golden reference: naive multiplier
    gf128_naive u_naive (
        .a(a),
        .b(b),
        .product(prod_naive)
    );

    // DUT: Karatsuba multiplier
    gf128_karatsuba u_kara (
        .a(a),
        .b(b),
        .product(prod_kara)
    );

    initial begin
        $display("Starting GF(2^128) Karatsuba vs Naive comparison...");

        // Simple sanity test
        a = 128'h1;
        b = 128'h1;
        #1;
        if (prod_naive !== prod_kara) begin
            $display("ERROR: 1 x 1 mismatch");
            $stop;
        end

        // Random tests
        for (test = 0; test < 500; test = test + 1) begin
            a = {$random, $random, $random, $random};
            b = {$random, $random, $random, $random};
            #1;

            if (prod_naive !== prod_kara) begin
                $display("Mismatch at test %0d", test);
                $display("a      = %032h", a);
                $display("b      = %032h", b);
                $display("Naive  = %064h", prod_naive);
                $display("Kara   = %064h", prod_kara);
                $stop;
            end
        end

        $display("PASS: Karatsuba matches naive for all tests.");
        $finish;
    end

endmodule

