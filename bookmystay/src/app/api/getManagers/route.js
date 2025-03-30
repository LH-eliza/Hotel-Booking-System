import { NextResponse } from "next/server";
import pool from "../../../../db";

export async function GET() {
  const query = `
    SELECT 
    m.ssn,
    m.hotel_id,
    e.first_name,
    e.last_name
FROM 
    manages m
JOIN 
    employee e ON m.ssn = e.ssn;

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
