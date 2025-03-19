import { NextResponse } from "next/server";
import pool from "../../../../db";

export async function GET(request) {
  const query = `
    select * from available_rooms_per_area
  `;

  try {
    const result = await pool.query(query);

    // Send the entire table as JSON
    console.log(result.rows);
    return NextResponse.json(result.rows);
  } catch (error) {
    console.error("Error executing query", error.stack);
    return NextResponse.json(
      { error: "Database query failed", message: error.message },
      { status: 500 }
    );
  }
}
