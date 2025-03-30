import db from "../../../../db";

export default async function handler(req, res) {
  console.log(req.method);
  console.log(req.body);
  if (req.method === 'POST') {
    const { idType, idNumber } = req.body;

    try {
      const [result] = await db.query(
        `SELECT customer_id FROM customer WHERE id_type = ? AND id_number = ?`,
        [idType, idNumber]
      );

      if (result.length > 0) {
        res.status(200).json({ exists: true, customer_id: result[0].customer_id });
      } else {
        res.status(200).json({ exists: false });
      }
    } catch (error) {
      console.error('Error fetching customer:', error);
      res.status(500).json({ error: 'Database error' });
    }
  } else {
    res.status(405).json({ message: 'Method not allowed' });
  }
}
