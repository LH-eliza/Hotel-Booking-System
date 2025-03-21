import { NextResponse } from "next/server";
import pool from "../../../../db";

const roomQuery = `
  SELECT 
    r.room_id,
    r.hotel_id,
    r.price,
    r.capacity,
    r.status,
    r.view,
    h.address,
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
    r.room_id, r.hotel_id, r.price, r.capacity, r.status, h.star_category, h.chain_id, h.address, r.view
  ORDER BY
    r.price ASC
`;

const viewTypesQuery = `
  SELECT DISTINCT view
  FROM room
  WHERE view IS NOT NULL
  ORDER BY view;
`;

export async function GET(request) {
  try {
    const result = await pool.query(roomQuery);
    const viewTypesResult = await pool.query(viewTypesQuery);
    
    const availableRooms = result.rows.map(row => ({
      roomId: row.room_id,
      hotelId: row.hotel_id,
      price: row.price,
      capacity: row.capacity,
      isAvailable: row.status === 'Available',
      starCategory: row.star_category,
      chainId: row.chain_id,
      neighborhood: row.neighborhood ? row.neighborhood.trim() : null,
      view: row.view,
      address: row.address,
      amenities: row.amenities || []
    }));
    
    const viewTypes = viewTypesResult.rows.map(row => row.view);
    return NextResponse.json({
      rooms: availableRooms,
      viewTypes: viewTypes
    });
  } catch (error) {
    console.error('Error executing query', error.stack);
    return NextResponse.json(
      { error: 'Database query failed', message: error.message },
      { status: 500 }
    );
  }
}