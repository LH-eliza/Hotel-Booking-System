import { NextResponse } from "next/server";
import pool from "../../../../db";

// SQL query to get distinct neighborhoods
const neighborhoodQuery = `
SELECT 
  DISTINCT substring(address FROM ',\\s*([^,]+),') AS neighborhood
FROM 
  hotel;
`;

export async function GET(request) {
    try {
      // Run the predefined query to get neighborhoods
      const result = await pool.query(neighborhoodQuery);
  
      // Extract and send back the neighborhood data
      const destinations = result.rows.map((row) => row.neighborhood);
      return NextResponse.json(destinations);  // Return the list of destinations as JSON
    } catch (error) {
      console.error('Error executing query', error.stack);
      return NextResponse.json(
        { error: 'Database query failed', message: error.message },
        { status: 500 }
      );
    }
  }
