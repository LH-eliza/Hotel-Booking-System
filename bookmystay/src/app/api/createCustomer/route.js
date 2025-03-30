import db from "../../../../db";

export default async function handler(req, res) {
  if (req.method === 'POST') {
    const {
      firstName, lastName, address,
      idType, idNumber, registrationDate
    } = req.body;

    try {
      // Generate customer ID in format: CUSTxxxx
      const randomID = Math.floor(1000 + Math.random() * 9000);
      const customerID = `CUST${randomID}`;

      await db.query(
        `INSERT INTO customer (
          customer_id, first_name, last_name, address,
          id_type, id_number, registration_date
        ) VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [
          customerID, firstName, lastName, address,
          idType, idNumber, registrationDate
        ]
      );

      res.status(201).json({ customer_id: customerID });
    } catch (error) {
      console.error('Error creating customer:', error);
      res.status(500).json({ error: 'Failed to create customer' });
    }
  } else {
    res.status(405).json({ message: 'Method not allowed' });
  }
}
