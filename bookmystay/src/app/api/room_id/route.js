import { NextResponse } from "next/server";
import pool from "../../../../db";

const hotelChainQuery = `
Select room_id from room
`;

export async function GET() {
    try {
      const result = await pool.query(hotelChainQuery);
  
      const hotel= result.rows.map((row => row.room_id));
      return NextResponse.json(hotel);
    } catch (error) {
      console.error('Error executing query', error.stack);
      return NextResponse.json(
        { error: 'Database query failed', message: error.message },
        { status: 500 }
      );
    }
  }
