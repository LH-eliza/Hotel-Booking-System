import { NextResponse } from "next/server";
import pool from "../../../../db";

const roomCapacityQuery = `
Select distinct capacity from room
`;

export async function GET() {
    try {
      const result = await pool.query(roomCapacityQuery);
  
      const capacities = result.rows.map((row => row.capacity));
      return NextResponse.json(capacities);
    } catch (error) {
      console.error('Error executing query', error.stack);
      return NextResponse.json(
        { error: 'Database query failed', message: error.message },
        { status: 500 }
      );
    }
  }
