import { NextResponse } from "next/server";
import pool from "../../../../db";

export async function POST(request) {
  try {
    const { query, values } = await request.json();

    if (!query) {
      return NextResponse.json(
        { error: "SQL query is required" },
        { status: 400 }
      );
    }

    // Use parameterized query with values to prevent SQL injection
    const result = await pool.query(query, values || []);

    return NextResponse.json(result.rows);  // Return the query result
  } catch (error) {
    console.error("Database error:", error);
    return NextResponse.json(
      { error: "Failed to run query", message: error.message },
      { status: 500 }
    );
  }
}
