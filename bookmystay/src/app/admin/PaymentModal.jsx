import { useState, useEffect } from 'react';

const PaymentModal = ({ isOpen, closeModal }) => {
  const [formData, setFormData] = useState({
    cardNumber: '',
    expirationDate: '',
    cvv: '',
    cardholderName: '',
  });

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData((prevState) => ({
      ...prevState,
      [name]: value,
    }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    // Handle payment form submission logic here
    console.log('Payment Data Submitted:', formData);
    closeModal(); // Close modal on successful submission
  };
  useEffect(() => {
    if (!isOpen) {
      setFormData({
        cardNumber: '',
        expirationDate: '',
        cvv: '',
        cardholderName: '',
      });
    }
  }, [isOpen]);

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex justify-center items-center z-50">
      <div className="bg-white p-8 rounded-lg shadow-xl max-w-sm w-full">
        <h2 className="text-2xl font-semibold text-center mb-6">Payment Details</h2>
        <form onSubmit={handleSubmit}>
          <div className="mb-4">
            <label htmlFor="cardholderName" className="block text-sm font-medium text-gray-700">
              Cardholder Name
            </label>
            <input
              type="text"
              id="cardholderName"
              name="cardholderName"
              value={formData.cardholderName}
              onChange={handleInputChange}
              required
              className="w-full p-2 border border-gray-300 rounded-md mt-2"
              placeholder="John Doe"
            />
          </div>

          <div className="mb-4">
            <label htmlFor="cardNumber" className="block text-sm font-medium text-gray-700">
              Credit Card Number
            </label>
            <input
              type="text"
              id="cardNumber"
              name="cardNumber"
              value={formData.cardNumber}
              onChange={handleInputChange}
              required
              className="w-full p-2 border border-gray-300 rounded-md mt-2"
              placeholder="1234 5678 9101 1121"
            />
          </div>

          <div className="mb-4 flex space-x-4">
            <div className="w-1/2">
              <label htmlFor="expirationDate" className="block text-sm font-medium text-gray-700">
                Expiration Date
              </label>
              <input
                type="month"
                id="expirationDate"
                name="expirationDate"
                value={formData.expirationDate}
                onChange={handleInputChange}
                required
                className="w-full p-2 border border-gray-300 rounded-md mt-2"
              />
            </div>

            <div className="w-1/2">
              <label htmlFor="cvv" className="block text-sm font-medium text-gray-700">
                CVV
              </label>
              <input
                type="text"
                id="cvv"
                name="cvv"
                value={formData.cvv}
                onChange={handleInputChange}
                required
                className="w-full p-2 border border-gray-300 rounded-md mt-2"
                placeholder="123"
              />
            </div>
          </div>

          <div className="flex justify-between items-center">
            <button
              type="button"
              onClick={closeModal}
              className="text-gray-600 hover:text-gray-900 focus:outline-none"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
              onClick={closeModal}
            >
              Submit Payment
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default PaymentModal;
