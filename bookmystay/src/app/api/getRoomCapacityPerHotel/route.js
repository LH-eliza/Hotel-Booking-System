import { NextResponse } from "next/server";
import pool from "../../../../db";

export async function GET(request) {
  const query = `
    select * from aggregated_room_capacity_per_hotel
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
