import { NextResponse } from "next/server";
import pool from "../../../../db";

const roomQuery = `
  SELECT 
    r.room_id,
    r.hotel_id,
    r.price,
    r.capacity,
    r.status,
    h.star_category,
    h.chain_id,
    SPLIT_PART(h.address, ',', 2) AS neighborhood,
    ARRAY_AGG(ra.amenity) AS amenities
  FROM 
    room r
  JOIN 
    hotel h ON r.hotel_id = h.hotel_id
  LEFT JOIN 
    roomamenity ra ON r.room_id = ra.room_id
  WHERE
    r.status = 'Available'
    AND h.address IS NOT NULL
  GROUP BY
    r.room_id, r.hotel_id, r.price, r.capacity, r.status, h.star_category, h.chain_id, h.address
  ORDER BY
    r.price ASC
`;

export async function GET(request) {
  try {
    const result = await pool.query(roomQuery);
    
    const availableRooms = result.rows.map(row => ({
      roomId: row.room_id,
      hotelId: row.hotel_id,
      price: row.price,
      capacity: row.capacity,
      isAvailable: row.status === 'Available',
      starCategory: row.star_category,
      chainId: row.chain_id,
      neighborhood: row.neighborhood ? row.neighborhood.trim() : null,
      amenities: row.amenities || []
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