import { NextResponse } from "next/server";
import pool from "../../../../db";

const roomAmenityQuery = `
Select distinct amenity from roomamenity
`;

export async function GET() {
    try {
      const result = await pool.query(roomAmenityQuery);

      const amenity= result.rows.map((row => row.amenity));
      return NextResponse.json(amenity);
    } catch (error) {
      console.error('Error executing query', error.stack);
      return NextResponse.json(
        { error: 'Database query failed', message: error.message },
        { status: 500 }
      );
    }
  }
