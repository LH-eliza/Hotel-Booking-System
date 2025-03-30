import React from "react";
import { MapPin, Calendar, Users } from "lucide-react";

// Define interfaces directly in this file
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
}

interface Room {
  id: number;
  name: string;
  price: number;
  discountPrice?: number;
  image: string;
}

interface BookingSummaryProps {
  bookingDetails: BookingDetails;
  getTotalPrice: () => number;
  getTaxesAndFees: () => number;
  getFinalTotal: () => number;
  isConfirmed: boolean;
}

export default function BookingSummary({
  bookingDetails,
  getTaxesAndFees,
  getFinalTotal,
  isConfirmed,
}: BookingSummaryProps) {
  return (
    <div className="bg-white border border-gray-200 rounded-lg shadow-sm p-6 sticky top-8">
      <h3 className="text-xl font-bold text-gray-800 mb-4">Booking Summary</h3>

      <div className="mb-6">
        <div className="flex items-center mb-2">
          <img
            src={bookingDetails.hotel.image}
            alt={bookingDetails.hotel.name}
            className="w-16 h-16 object-cover rounded mr-3"
          />
          <div>
            <h4 className="font-bold">{bookingDetails.hotel.name}</h4>
            <p className="text-sm text-gray-600">
              {bookingDetails.hotel.hotelChain}
            </p>
          </div>
        </div>
        <div className="text-sm text-gray-600 mt-1">
          <div className="flex items-start">
            <MapPin size={14} className="mt-0.5 mr-1" />
            <span>{bookingDetails.hotel.address}</span>
          </div>
        </div>
      </div>

      <div className="border-t border-gray-200 pt-4 mb-6">
        <div className="flex items-center justify-between mb-2">
          <div className="flex items-center">
            <Calendar size={16} className="text-gray-600 mr-2" />
            <span className="text-gray-800">Check-in / Check-out</span>
          </div>
        </div>
        <div className="text-sm text-gray-600 ml-6">
          {bookingDetails.dateRange}
        </div>

        <div className="flex items-center justify-between mt-3 mb-2">
          <div className="flex items-center">
            <Users size={16} className="text-gray-600 mr-2" />
            <span className="text-gray-800">Guests</span>
          </div>
        </div>
        <div className="text-sm text-gray-600 ml-6">
          {bookingDetails.guestInfo}
        </div>
      </div>

      <div className="border-t border-gray-200 pt-4">
        <h4 className="font-medium mb-3">Price Details</h4>

        {bookingDetails.rooms.map((room, index) => (
          <div key={index} className="flex justify-between mb-2 text-sm">
            <span>
              {room.name} x {bookingDetails.numberOfNights} night
              {bookingDetails.numberOfNights > 1 ? "s" : ""}
            </span>
            <span>
              $
              {(room.discountPrice || room.price) *
                bookingDetails.numberOfNights}
            </span>
          </div>
        ))}

        <div className="flex justify-between mb-2 text-sm">
          <span>Taxes &amp; Fees</span>
          <span>${getTaxesAndFees()}</span>
        </div>

        <div className="border-t border-gray-200 mt-3 pt-3 flex justify-between font-bold">
          <span>Total</span>
          <span>${getFinalTotal()}</span>
        </div>
      </div>

      {isConfirmed && (
        <div className="mt-6 bg-green-50 border border-green-200 p-4 rounded-lg">
          <p className="text-sm text-green-800">
            Your reservation is confirmed! A confirmation email has been sent to
            your inbox.
          </p>
        </div>
      )}
    </div>
  );
}
