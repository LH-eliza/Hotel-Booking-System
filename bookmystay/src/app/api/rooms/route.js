import { NextResponse } from "next/server";
import pool from "../../../../db";

const roomQuery = `
  SELECT 
    hotel_id,
    price,
    capacity,
    status
  FROM 
    room
  WHERE
    status = 'Available'
  ORDER BY
    price ASC
`;

export async function GET(request) {
  try {
    const result = await pool.query(roomQuery);
    
    // Transform the data if needed
    const availableRooms = result.rows.map(row => ({
      hotelId: row.hotel_id,
      price: row.price,
      capacity: row.capacity,
      isAvailable: row.status === 'Available'
    }));
    
    return NextResponse.json(availableRooms);
  } catch (error) {
    console.error('Error executing query', error.stack);
    return NextResponse.json(
      { error: 'Database query failed', message: error.message },
      { status: 500 }
    );
  }
}