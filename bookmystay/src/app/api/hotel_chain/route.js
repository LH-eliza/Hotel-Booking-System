import { NextResponse } from "next/server";
import pool from "../../../../db";

const hotelChainQuery = `
Select chain_id from hotelchain
`;

export async function GET() {
    try {
      const result = await pool.query(hotelChainQuery);
  
      const hotelchains = result.rows.map((row => row.chain_id));
      return NextResponse.json(hotelchains);
    } catch (error) {
      console.error('Error executing query', error.stack);
      return NextResponse.json(
        { error: 'Database query failed', message: error.message },
        { status: 500 }
      );
    }
  }
