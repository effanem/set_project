`timescale 1ns/1ps

module tb_gf128_naive;

    reg  [127:0] a, b;
    wire [255:0] product;

    gf128_naive dut (
        .a(a),
        .b(b),
        .product(product)
    );

    integer i, test;
    reg [255:0] expected;

    initial begin
        $display("Starting gf128_naive self-check...");

        // Simple sanity check
        a = 128'h1;
        b = 128'h1;
        #1;
        if (product != 256'h1)
            $display("ERROR: 1 x 1 failed");

        // Random tests
        for (test = 0; test < 500; test = test + 1) begin
            a = {$random, $random, $random, $random};
            b = {$random, $random, $random, $random};
            #1;

            expected = 256'b0;
            for (i = 0; i < 128; i = i + 1) begin
                if (b[i])
                    expected = expected ^ ({128'b0, a} << i);
            end

            if (product !== expected) begin
                $display("Mismatch at test %0d", test);
                $display("a = %032h", a);
                $display("b = %032h", b);
                $display("DUT = %064h", product);
                $display("EXP = %064h", expected);
                $stop;
            end
        end

        $display("All gf128_naive tests passed.");
        $finish;
    end

endmodule

