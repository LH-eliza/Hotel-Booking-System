import { NextResponse } from "next/server";
import pool from "../../../../db";

const hotelChainQuery = `
Select customer_id from customer
`;

export async function GET(request) {
    try {
      const result = await pool.query(hotelChainQuery);
  
      const hotel= result.rows.map((row => row.customer_id));
      return NextResponse.json(hotel);
    } catch (error) {
      console.error('Error executing query', error.stack);
      return NextResponse.json(
        { error: 'Database query failed', message: error.message },
        { status: 500 }
      );
    }
  }
