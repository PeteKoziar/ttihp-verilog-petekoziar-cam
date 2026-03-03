`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Pete Koziar
//
// Create Date: 05/12/2023 10:07:15 AM
// Design Name:
// Module Name: CamRow
// Project Name:
// Target Devices:
// Tool Versions:
// Description: One row of Content Addressable Memory cells
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module CamRow
    #(parameter WIDTH = 64, COLUMNS = 32)
    (
    input wire nReset,
    input wire [WIDTH-1:0] pattern,
    input wire [WIDTH-1:0] notPattern,
    input wire [COLUMNS-1:0] last_column_found,
    input wire last_free,
    input wire store,
    input wire nStore,
    output wire row_found,
    output wire [COLUMNS-1:0] column_found,
    output wire free
    );

    wire cell_found[COLUMNS-1:0];
    wire cell_free[COLUMNS-1:0];
    genvar rows;

    assign row_found = cell_found[COLUMNS-1];
    assign free = cell_free[COLUMNS-1];

    // The first cell, 0, is special:
    CamCell #(.WIDTH(WIDTH)) cc0
    (
    .pattern(pattern),
    .notPattern(notPattern),
    .nReset(nReset),
    .last_row_found(1'b0),
    .last_column_found(last_column_found[0]),
    .last_free(last_free),
    .store(store),
    .nStore(nStore),
    .row_found(cell_found[0]),
    .column_found(column_found[0]),
    .free(cell_free[0])
    );

    // Now, generate all the usual ones:
    generate
        for(rows = 1; rows < COLUMNS; rows = rows + 1)
            CamCell #(.WIDTH(WIDTH)) ccc
            (
            .pattern(pattern),
            .notPattern(notPattern),
            .reset(not nReset),
            .last_row_found(cell_found[rows-1]),
            .last_column_found(last_column_found[rows]),
            .last_free(cell_free[rows-1]),
            .store(store),
            .nStore(nStore),
            .row_found(cell_found[rows]),
            .column_found(column_found[rows]),
            .free(cell_free[rows])
            );

    endgenerate
endmodule
