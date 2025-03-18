import React from "react";
import { ArrowLeft, ArrowRight, Shield, Info } from "lucide-react";

// Fix the import path for interfaces
interface PaymentInfo {
  method: string;
  cardNumber?: string;
  cardName?: string;
  expiryDate?: string;
  cvv?: string;
}

interface PaymentStepProps {
  paymentInfo: PaymentInfo;
  updatePaymentInfo: (info: Partial<PaymentInfo>) => void;
  onNext: () => void;
  onBack: () => void;
}

export default function PaymentStep({
  paymentInfo,
  updatePaymentInfo,
  onNext,
  onBack,
}: PaymentStepProps) {
  const formatCardNumber = (value: string) => {
    // Remove all non-digits
    const digits = value.replace(/\D/g, "");

    // Split into groups of 4 and join with spaces
    const formatted = digits.match(/.{1,4}/g)?.join(" ") || digits;

    return formatted;
  };

  const handleCardNumberChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    // Limit to 19 characters (16 digits + 3 spaces)
    if (value.length <= 19) {
      updatePaymentInfo({ cardNumber: formatCardNumber(value) });
    }
  };

  const handleExpiryDateChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value.replace(/\D/g, "");
    if (value.length <= 4) {
      if (value.length > 2) {
        updatePaymentInfo({
          expiryDate: `${value.slice(0, 2)}/${value.slice(2)}`,
        });
      } else {
        updatePaymentInfo({ expiryDate: value });
      }
    }
  };

  const handleCvvChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value.replace(/\D/g, "").substring(0, 3);
    updatePaymentInfo({ cvv: value });
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    // Validate payment information if credit card is selected
    if (paymentInfo.method === "credit-card") {
      if (
        !paymentInfo.cardNumber ||
        !paymentInfo.cardName ||
        !paymentInfo.expiryDate ||
        !paymentInfo.cvv
      ) {
        alert("Please fill in all payment details.");
        return;
      }
    }

    onNext();
  };

  return (
    <form onSubmit={handleSubmit}>
      <h2 className="text-2xl font-bold text-gray-800 mb-6">Payment Method</h2>

      <div className="bg-white border border-gray-200 rounded-lg p-6 mb-6">
        <h3 className="text-lg font-medium text-gray-800 mb-4">
          Select a Payment Method
        </h3>

        <div className="space-y-4">
          <div>
            <label className="flex items-center cursor-pointer">
              <input
                type="radio"
                name="paymentMethod"
                className="h-5 w-5 text-purple-600"
                checked={paymentInfo.method === "credit-card"}
                onChange={() => updatePaymentInfo({ method: "credit-card" })}
              />
              <span className="ml-2 text-gray-700">Credit/Debit Card</span>
            </label>
          </div>

          <div>
            <label className="flex items-center cursor-pointer">
              <input
                type="radio"
                name="paymentMethod"
                className="h-5 w-5 text-purple-600"
                checked={paymentInfo.method === "pay-at-hotel"}
                onChange={() => updatePaymentInfo({ method: "pay-at-hotel" })}
              />
              <span className="ml-2 text-gray-700">Pay at Hotel</span>
            </label>
          </div>
        </div>
      </div>

      {paymentInfo.method === "credit-card" && (
        <div className="bg-white border border-gray-200 rounded-lg p-6 mb-6">
          <h3 className="text-lg font-medium text-gray-800 mb-4">
            Card Details
          </h3>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="md:col-span-2">
              <label
                htmlFor="cardNumber"
                className="block text-sm font-medium text-gray-700 mb-1"
              >
                Card Number <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                id="cardNumber"
                className="w-full p-2 border border-gray-300 rounded-md"
                placeholder="XXXX XXXX XXXX XXXX"
                value={paymentInfo.cardNumber}
                onChange={handleCardNumberChange}
                maxLength={19}
                required
              />
            </div>

            <div className="md:col-span-2">
              <label
                htmlFor="cardName"
                className="block text-sm font-medium text-gray-700 mb-1"
              >
                Name on Card <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                id="cardName"
                className="w-full p-2 border border-gray-300 rounded-md"
                value={paymentInfo.cardName}
                onChange={(e) =>
                  updatePaymentInfo({ cardName: e.target.value })
                }
                required
              />
            </div>

            <div>
              <label
                htmlFor="expiryDate"
                className="block text-sm font-medium text-gray-700 mb-1"
              >
                Expiry Date <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                id="expiryDate"
                className="w-full p-2 border border-gray-300 rounded-md"
                placeholder="MM/YY"
                value={paymentInfo.expiryDate}
                onChange={handleExpiryDateChange}
                maxLength={5}
                required
              />
            </div>

            <div>
              <label
                htmlFor="cvv"
                className="block text-sm font-medium text-gray-700 mb-1"
              >
                CVV <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                id="cvv"
                className="w-full p-2 border border-gray-300 rounded-md"
                placeholder="XXX"
                value={paymentInfo.cvv}
                onChange={handleCvvChange}
                maxLength={3}
                required
              />
            </div>
          </div>

          <div className="mt-4 flex items-center text-sm text-gray-600">
            <Shield size={16} className="text-gray-500 mr-2" />
            Your payment information is encrypted and secure.
          </div>
        </div>
      )}

      {paymentInfo.method === "pay-at-hotel" && (
        <div className="bg-white border border-gray-200 rounded-lg p-6 mb-6">
          <div className="flex items-start">
            <div className="flex-shrink-0 mt-0.5">
              <Info size={18} className="text-blue-500" />
            </div>
            <div className="ml-3">
              <h4 className="text-md font-medium text-gray-800">
                Pay at Hotel Information
              </h4>
              <p className="mt-1 text-sm text-gray-600">
                You will pay the full amount during check-in at the hotel.
                Please note that the hotel may pre-authorize your credit card to
                guarantee your booking.
              </p>
            </div>
          </div>
        </div>
      )}

      <div className="flex justify-between">
        <button
          type="button"
          onClick={onBack}
          className="border border-gray-300 text-gray-700 hover:bg-gray-50 px-6 py-3 rounded-lg flex items-center"
        >
          <ArrowLeft size={18} className="mr-2" />
          Back
        </button>

        <button
          type="submit"
          className="bg-purple-500 hover:bg-purple-600 text-white px-6 py-3 rounded-lg flex items-center"
        >
          Review Booking
          <ArrowRight size={18} className="ml-2" />
        </button>
      </div>
    </form>
  );
}
