import db from "../../../../db";

export default async function handler(req, res) {
  if (req.method === 'POST') {
    const { customerId, startDate, endDate, roomId } = req.body;
    const bookingID = Math.floor(1000 + Math.random() * 9000);

    try {
      await db.query(
        `INSERT INTO booking (booking_id, customer_id, start_date, end_date, room_id)
         VALUES (?, ?, ?, ?, ?)`,
        [bookingID, customerId, startDate, endDate, roomId]
      );

      res.status(201).json({ message: 'Booking created successfully' });
    } catch (error) {
      console.error('Error creating booking:', error);
      res.status(500).json({ error: 'Failed to create booking' });
    }
  } else {
    res.status(405).json({ message: 'Method not allowed' });
  }
}
