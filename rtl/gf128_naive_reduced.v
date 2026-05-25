// ==========================================================
// GF(2^128) Naive Modular Multiplier
// Naive 128x128 multiply + AES-GCM reduction
// ==========================================================

module gf128_naive_reduced (
    input  wire [127:0] a,
    input  wire [127:0] b,
    output wire [127:0] result
);

    wire [255:0] product_full;

    // Naive polynomial multiplier
    gf128_naive u_mul (
        .a(a),
        .b(b),
        .product(product_full)
    );

    // AES-GCM reduction
    gf128_reduce_opt u_reduce (
        .in(product_full),
        .out(result)
    );

endmodule

