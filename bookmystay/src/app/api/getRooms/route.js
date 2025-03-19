import { NextResponse } from "next/server";
import pool from "../../../../db";

export async function GET(request) {
  const query = `
    select * from room
  `;

  try {
    const result = await pool.query(query);

    // Send the entire table as JSON
    return NextResponse.json(result.rows);
  } catch (error) {
    console.error("Error executing query", error.stack);
    return NextResponse.json(
      { error: "Database query failed", message: error.message },
      { status: 500 }
    );
  }
}
