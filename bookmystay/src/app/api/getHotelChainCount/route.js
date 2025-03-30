import { NextResponse } from "next/server";
import pool from "../../../../db";

export async function GET() {
  const countQuery = `
    SELECT COUNT(*) AS total FROM hotelchain;
  `;

  try {
    const result = await pool.query(countQuery);

    // Extract the total count from the query result
    const totalCount = result.rows[0].total;

    //console.log(`Total rows: ${totalCount}`);
    return NextResponse.json({ total: Number(totalCount) });  // Return as JSON
  } catch (error) {
    console.error("Error executing query", error.stack);
    return NextResponse.json(
      { error: "Database query failed", message: error.message },
      { status: 500 }
    );
  }
}
