import React from "react";
import {
  Check,
  ArrowLeft,
  User,
  Mail,
  Phone,
  MapPin,
  Calendar,
  Users,
} from "lucide-react";

// Define interfaces directly in this file instead of importing
interface BookingDetails {
  hotel: Hotel;
  rooms: Room[];
  dateRange: string;
  guestInfo: string;
  numberOfNights: number;
}

interface Hotel {
  id: number;
  name: string;
  address: string;
  image: string;
  starRating: number;
  hotelChain: string;
  checkInTime?: string;
  checkOutTime?: string;
}

interface Room {
  id: number;
  name: string;
  price: number;
  discountPrice?: number;
  image: string;
}

interface GuestInfo {
  firstName: string;
  lastName: string;
  email: string;
  phone: string;
  address: string;
  city: string;
  country: string;
  zipCode: string;
  idType: string;
  idNumber: string;
  specialRequests: string;
}

interface PaymentInfo {
  method: string;
  cardNumber?: string;
  cardName?: string;
  expiryDate?: string;
  cvv?: string;
}

interface ConfirmationStepProps {
  bookingDetails: BookingDetails;
  guestInfo: GuestInfo;
  paymentInfo: PaymentInfo;
  bookingNumber: string;
  bookingDate: string;
  onBack: () => void;
  onComplete: () => void;
}

export default function ConfirmationStep({
  bookingDetails,
  guestInfo,
  paymentInfo,
  bookingNumber,
  bookingDate,
  onBack,
  onComplete,
}: ConfirmationStepProps) {
  return (
    <div>
      <h2 className="text-2xl font-bold text-gray-800 mb-6">
        Booking Confirmation
      </h2>

      <div className="bg-white border border-gray-200 rounded-lg p-6 mb-6">
        <div className="flex items-center mb-4">
          <div className="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center mr-4">
            <Check size={24} className="text-green-500" />
          </div>
          <div>
            <h3 className="text-lg font-medium text-gray-800">
              Your booking is confirmed!
            </h3>
            <p className="text-gray-600">
              Booking #{bookingNumber} • {bookingDate}
            </p>
          </div>
        </div>

        <div className="border-t border-gray-200 pt-4 mt-4">
          <h4 className="font-medium text-gray-800 mb-2">Guest Information</h4>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-2 text-sm">
            <div className="flex items-start">
              <User size={16} className="text-gray-500 mr-2 mt-0.5" />
              <span>
                {guestInfo.firstName} {guestInfo.lastName}
              </span>
            </div>
            <div className="flex items-start">
              <Mail size={16} className="text-gray-500 mr-2 mt-0.5" />
              <span>{guestInfo.email}</span>
            </div>
            <div className="flex items-start">
              <Phone size={16} className="text-gray-500 mr-2 mt-0.5" />
              <span>{guestInfo.phone}</span>
            </div>
            {guestInfo.address && (
              <div className="flex items-start">
                <MapPin size={16} className="text-gray-500 mr-2 mt-0.5" />
                <span>
                  {guestInfo.address}, {guestInfo.city}, {guestInfo.country}{" "}
                  {guestInfo.zipCode}
                </span>
              </div>
            )}
          </div>
        </div>

        <div className="border-t border-gray-200 pt-4 mt-4">
          <h4 className="font-medium text-gray-800 mb-2">Booking Details</h4>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-2 text-sm">
            <div className="flex items-start">
              <Calendar size={16} className="text-gray-500 mr-2 mt-0.5" />
              <div>
                <div className="font-medium">Check-in/Check-out</div>
                <div>{bookingDetails.dateRange}</div>
              </div>
            </div>
            <div className="flex items-start">
              <Users size={16} className="text-gray-500 mr-2 mt-0.5" />
              <div>
                <div className="font-medium">Guests</div>
                <div>{bookingDetails.guestInfo}</div>
              </div>
            </div>
          </div>
        </div>

        <div className="border-t border-gray-200 pt-4 mt-4">
          <h4 className="font-medium text-gray-800 mb-2">
            Payment Information
          </h4>
          <div className="text-sm">
            <p className="mb-1">
              <span className="font-medium">Payment Method:</span>{" "}
              {paymentInfo.method === "credit-card"
                ? "Credit/Debit Card"
                : "Pay at Hotel"}
            </p>
            {paymentInfo.method === "credit-card" && paymentInfo.cardNumber && (
              <p>
                <span className="font-medium">Card:</span> **** **** ****{" "}
                {paymentInfo.cardNumber.slice(-4)}
              </p>
            )}
          </div>
        </div>
      </div>

      <div className="bg-blue-50 border border-blue-200 rounded-lg p-6 mb-6">
        <h3 className="text-lg font-medium text-blue-800 mb-2">What's Next?</h3>
        <p className="text-blue-700 mb-3">
          A confirmation email has been sent to {guestInfo.email} with all your
          booking details.
        </p>
        <ul className="text-blue-700 space-y-2">
          <li className="flex items-start">
            <Check size={16} className="text-blue-500 mr-2 mt-1" />
            Present your ID during check-in at the hotel
          </li>
          <li className="flex items-start">
            <Check size={16} className="text-blue-500 mr-2 mt-1" />
            {paymentInfo.method === "pay-at-hotel"
              ? "Payment will be collected at the hotel"
              : "Your card has been charged the full amount"}
          </li>
          <li className="flex items-start">
            <Check size={16} className="text-blue-500 mr-2 mt-1" />
            Check-in time starts at{" "}
            {bookingDetails.hotel.checkInTime || "3:00 PM"}
          </li>
        </ul>
      </div>

      <div className="flex justify-between">
        <button
          onClick={onBack}
          className="border border-gray-300 text-gray-700 hover:bg-gray-50 px-6 py-3 rounded-lg flex items-center"
        >
          <ArrowLeft size={18} className="mr-2" />
          Back
        </button>

        <button
          onClick={onComplete}
          className="bg-green-500 hover:bg-green-600 text-white px-6 py-3 rounded-lg"
        >
          Complete Booking
        </button>
      </div>
    </div>
  );
}
