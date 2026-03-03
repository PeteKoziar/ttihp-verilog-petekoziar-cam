`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Pete Koziar
//
// Create Date: 05/12/2023 12:29:36 PM
// Design Name:
// Module Name: CamBlock
// Project Name:
// Target Devices:
// Tool Versions:
// Description: Unites content addressable memory cells together into a block.
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module CamBlock
    #(parameter PATTERN_WIDTH = 8, ROWS = 8, COLUMNS = 8)
    (
    input  wire nReset,
    input  wire lookup_strobe,    // Kicks it off.
    input  wire [PATTERN_WIDTH-1:0] pattern,
    input  wire [PATTERN_WIDTH-1:0] notPattern,
    input  wire store,
    input  wire nStore,
    output wire [$clog2(ROWS*COLUMNS)-1:0] location,
    output wire found,
    output wire full
    );

    wire [COLUMNS-1:0 ]column_found[ROWS-1:0];
    wire [ROWS-1:0] row_free;
    wire [ROWS-1:0] row_found;
    genvar rows;
    integer row_bit_check;
    integer column_bit_check;

    assign found = ((row_found != {ROWS{1'b0}}) && (column_found[ROWS-1] != {COLUMNS{1'b0}}) && (nReset != 0)) ? 1:0;
    assign full = !row_free[ROWS-1];

    // Edge case: first row of cells
    CamRow #(.WIDTH(PATTERN_WIDTH), .COLUMNS(COLUMNS)) cr0
    (
    .nReset(nReset),
    .pattern(pattern),
    .notPattern(notPattern),
    .last_column_found({COLUMNS{1'b0}}),
    .last_free(1'b0),
    .store(store),
    .nStore(nStore),
    .row_found(row_found[0]),
    .column_found(column_found[0]),
    .free(row_free[0])
    );

    generate
        for(rows = 1; rows < ROWS; rows = rows + 1)
        begin
            CamRow #(.WIDTH(PATTERN_WIDTH), .COLUMNS(COLUMNS)) crr
            (
            .nReset(nReset),
            .pattern(pattern),
            .notPattern(notPattern),
            .last_column_found(column_found[rows-1]),
            .last_free(row_free[rows-1]),
            .store(store),
            .nStore(nStore),
            .row_found(row_found[rows]),
            .column_found(column_found[rows]),
            .free(row_free[rows])
            );
            end
    endgenerate

    // Encode the row lines:
    always @(*)
    begin
        for(row_bit_check = 0; row_bit_check < ROWS; row_bit_check = row_bit_check + 1)
        begin
            if(row_found[row_bit_check] != 0)
            begin
                location[$clog2(ROWS*COLUMNS)-1:$clog2(ROWS)] <= row_bit_check;
            end
        end
    end

    // Encode the column lines:
    always @(*)
    begin
        for(column_bit_check = 0; column_bit_check < COLUMNS; column_bit_check = column_bit_check + 1)
        begin
            if(column_found[ROWS-1][column_bit_check] != 0)
            begin
                location[$clog2(ROWS)-1:0] <= column_bit_check;
            end
        end
    end


endmodule
