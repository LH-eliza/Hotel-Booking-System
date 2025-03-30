import { NextResponse } from "next/server";
import pool from "../../../../db";

// Handling GET request
export async function GET(request) {
    
  const { searchParams } = new URL(request.url);
  const query = searchParams.get("query"); // Get the query parameter from the URL

  if (!query) {
    return NextResponse.json(
      { error: "Query parameter is missing" },
      { status: 400 }
    );
  }

  try {
    // Execute the query passed from the frontend
    const result = await pool.query(query);
    return NextResponse.json(result.rows); // Return the query results as JSON
  } catch (error) {
    console.error(error);
    // Handle any errors that occur during the database query
    return NextResponse.json(
      { error: "Database query failed", message: error.message },
      { status: 500 }
    );
  }
}