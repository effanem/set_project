// GF(2^128) multiplier with AES-GCM reduction
// Uses Karatsuba multiplication + optimized reduction
// Final output is 128-bit

module gf128_mul_reduced (
    input  wire [127:0] a,
    input  wire [127:0] b,
    output wire [127:0] result
);

    wire [255:0] product_full;

    // Karatsuba multiplier instantiation
    gf128_karatsuba u_mul (
        .a(a),
        .b(b),
        .product(product_full)
    );

    // Optimized AES-GCM reduction
    gf128_reduce_opt u_reduce (
        .in(product_full),
        .out(result)
    );

endmodule

