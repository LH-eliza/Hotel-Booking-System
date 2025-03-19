import { NextResponse } from "next/server";
import pool from "../../../../db";

export async function GET(request) {
  const countQuery = `
    SELECT COUNT(*) AS total FROM booking;
  `;

  try {
    const result = await pool.query(countQuery);

    // Extract the total count from the query result
    const totalCount = result.rows[0].total;

    return NextResponse.json({ total: Number(totalCount) });  // Return as JSON
  } catch (error) {
    console.error("Error executing query", error.stack);
    return NextResponse.json(
      { error: "Database query failed", message: error.message },
      { status: 500 }
    );
  }
}
