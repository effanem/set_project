`timescale 1ns/1ps
module tb_gf64_mul;

    reg  [63:0] a, b;
    wire [127:0] product;

    // Instantiate DUT
    gf64_mul dut (
        .a(a),
        .b(b),
        .product(product)
    );

    // Reference model computed in TB
    integer i, test;
    reg [127:0] expected;
    reg [63:0] A, B;

    initial begin
        $display("Starting gf64_mul self-check...");

        // A few fixed checks (sanity)
        a = 64'h0000_0000_0000_0001; b = 64'h0000_0000_0000_0001; #1;
        if (product != 128'h0000_0000_0000_0001) $display("ERROR fixed1");

        a = 64'hFFFF_FFFF_FFFF_FFFF; b = 64'h0000_0000_0000_0001; #1;
        // product should be a concatenation of a (shifted by 0)
        if (product[63:0] != 64'hFFFF_FFFF_FFFF_FFFF) $display("ERROR fixed2");

        // Randomized tests
        for (test = 0; test < 2000; test = test + 1) begin
            // random vectors (change seed if desired)
            a = {$random, $random}; // 64-bit random
            b = {$random, $random};
            #1; // wait combinational evaluate

            // compute reference expected
            expected = 128'b0;
            for (i = 0; i < 64; i = i + 1) begin
                if (b[i])
                    expected = expected ^ ({64'b0, a} << i);
            end

            if (product !== expected) begin
                $display("Mismatch at test %0d: a=%h b=%h", test, a, b);
                $display(" DUT product = %032h", product);
                $display(" EXP product = %032h", expected);
                $stop;
            end
        end

        $display("All tests passed (2000 random vectors).");
        $finish;
    end

endmodule
