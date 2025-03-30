"use client";

import React, { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { User, CreditCard, Check } from "lucide-react";

import Header from "../components/header";
import Footer from "../components/footer";
import GuestInformationStep from "../components/booking/guest-information-step";
import PaymentStep from "../components/booking/payment-step";
import ConfirmationStep from "../components/booking/confirmation-step";
import BookingSummary from "../components/booking/booking-summary";

export interface DateRange {
  startDate: string;
  endDate: string;
}

export interface Room {
  id: number;
  name: string;
  price: number;
  discountPrice?: number;
  image: string;
}

export interface Hotel {
  id: number;
  name: string;
  address: string;
  image: string;
  starRating: number;
  hotelChain: string;
  checkInTime?: string;
  checkOutTime?: string;
}

export interface BookingDetails {
  hotel: Hotel;
  rooms: Room[];
  dateRange: string;
  guestInfo: string;
  numberOfNights: number;
}

export interface GuestInfo {
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

export interface PaymentInfo {
  method: string;
  cardNumber?: string;
  cardName?: string;
  expiryDate?: string;
  cvv?: string;
}

export default function BookingConfirmationPage({ searchParams, }: { searchParams: { [key: string]: string | string[] |  undefined }; }) {
  const router = useRouter();

  const [currentStep, setCurrentStep] = useState(1);
  const [bookingDetails, setBookingDetails] = useState<BookingDetails | null>(
    null
  );
  const [loading, setLoading] = useState(true);

  // Guest information
  const [guestInfo, setGuestInfo] = useState<GuestInfo>({
    firstName: "",
    lastName: "",
    email: "",
    phone: "",
    address: "",
    city: "",
    country: "",
    zipCode: "",
    idType: "passport",
    idNumber: "",
    specialRequests: "",
  });

  // Payment information
  const [paymentInfo, setPaymentInfo] = useState<PaymentInfo>({
    method: "credit-card",
    cardNumber: "",
    cardName: "",
    expiryDate: "",
    cvv: "",
  });

  // Booking confirmation info
  const [bookingNumber, setBookingNumber] = useState("");
  const [bookingDate, setBookingDate] = useState("");

  useEffect(() => {
    const hotelId = searchParams.hotelId as string ||  ""; 
    const searchRoomIds = searchParams.roomIds as string ||  "";
    const roomIds = searchRoomIds?.split(",") || [];
    const dates = searchParams.dates as string || "";
    const guests = searchParams.guests as string || "";
    console.log(hotelId)

    setTimeout(() => {
      const hotelData: Hotel = {
        id: 1,
        name: "Hilton Garden Inn",
        address: "1400 Queen Elizabeth Dr, Ottawa, ON K1S 5Z7",
        image: "/api/placeholder/400/250",
        starRating: 4,
        hotelChain: "Hilton",
        checkInTime: "3:00 PM",
        checkOutTime: "11:00 AM",
      };

      const roomsData: Room[] = [
        {
          id: 101,
          name: "Standard King Room",
          price: 169,
          image: "/api/placeholder/400/250",
        },
        {
          id: 102,
          name: "Double Queen Room",
          price: 189,
          image: "/api/placeholder/400/250",
        },
      ];

      // Filter rooms based on roomIds from URL
      const selectedRooms =
        roomIds.length > 0
          ? roomsData.filter((room) => roomIds.includes(room.id.toString()))
          : roomsData.slice(0, 1); // Default to first room if none specified

      // Calculate number of nights
      let numberOfNights = 1;
      const dateParts = dates.split(" | ");
      if (dateParts.length === 2) {
        const startDate = new Date(dateParts[0]);
        const endDate = new Date(dateParts[1]);
        const diffTime = Math.abs(endDate.getTime() - startDate.getTime());
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
        numberOfNights = diffDays || 1;
      }

      setBookingDetails({
        hotel: hotelData,
        rooms: selectedRooms,
        dateRange: dates,
        guestInfo: guests,
        numberOfNights,
      });

      setLoading(false);
    }, 500);
  }, [searchParams]);

  const goToNextStep = () => {
    if (currentStep === 2) {
      // Generate booking number and date when moving to confirmation step
      const bookingNum = `BK${Math.floor(Math.random() * 9000000) + 1000000}`;
      const today = new Date().toISOString().split("T")[0];

      setBookingNumber(bookingNum);
      setBookingDate(today);
    }

    setCurrentStep(currentStep + 1);
    window.scrollTo(0, 0);
  };

  const goToPreviousStep = () => {
    setCurrentStep(currentStep - 1);
    window.scrollTo(0, 0);
  };

  const handleCompleteBooking = () => {
    router.push("/booking-success");
  };

  const goToHomepage = () => {
    router.push("/");
  };

  const getTotalPrice = () => {
    if (!bookingDetails) return 0;

    return bookingDetails.rooms.reduce((total, room) => {
      return (
        total +
        (room.discountPrice || room.price) * bookingDetails.numberOfNights
      );
    }, 0);
  };

  const getTaxesAndFees = () => {
    return Math.round(getTotalPrice() * 0.15);
  };

  const getFinalTotal = () => {
    return getTotalPrice() + getTaxesAndFees();
  };

  const updateGuestInfo = (updatedInfo: Partial<GuestInfo>) => {
    setGuestInfo({ ...guestInfo, ...updatedInfo });
  };

  const updatePaymentInfo = (updatedInfo: Partial<PaymentInfo>) => {
    setPaymentInfo({ ...paymentInfo, ...updatedInfo });
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center min-h-screen">
        <div className="animate-spin rounded-full h-16 w-16 border-t-2 border-b-2 border-purple-500"></div>
      </div>
    );
  }

  if (!bookingDetails) {
    return (
      <div className="flex justify-center items-center min-h-screen">
        <div className="text-center">
          <h2 className="text-2xl font-bold text-gray-800">
            Booking Not Found
          </h2>
          <p className="text-gray-600 mt-2">
            We couldn&apos;t find the booking details you&apos;re looking for.
          </p>
          <button
            onClick={goToHomepage}
            className="mt-4 bg-purple-500 hover:bg-purple-600 text-white px-4 py-2 rounded"
          >
            Return to Homepage
          </button>
        </div>
      </div>
    );
  }

  return (
    <div>
      <Header />
      <div className="container mx-auto px-4 py-8">
        {/* Stepper */}
        <div className="mb-8">
          <div className="flex justify-between items-center relative">
            <div className="w-full absolute top-1/2 h-0.5 bg-gray-200"></div>
            <div className="flex justify-between relative w-full">
              <div className="flex flex-col items-center">
                <div
                  className={`w-10 h-10 rounded-full flex items-center justify-center z-10 ${
                    currentStep >= 1
                      ? "bg-purple-500 text-white"
                      : "bg-gray-200 text-gray-500"
                  }`}
                >
                  <User size={18} />
                </div>
                <span className="text-sm mt-2">Guest Info</span>
              </div>

              <div className="flex flex-col items-center">
                <div
                  className={`w-10 h-10 rounded-full flex items-center justify-center z-10 ${
                    currentStep >= 2
                      ? "bg-purple-500 text-white"
                      : "bg-gray-200 text-gray-500"
                  }`}
                >
                  <CreditCard size={18} />
                </div>
                <span className="text-sm mt-2">Payment</span>
              </div>

              <div className="flex flex-col items-center">
                <div
                  className={`w-10 h-10 rounded-full flex items-center justify-center z-10 ${
                    currentStep >= 3
                      ? "bg-purple-500 text-white"
                      : "bg-gray-200 text-gray-500"
                  }`}
                >
                  <Check size={18} />
                </div>
                <span className="text-sm mt-2">Confirmation</span>
              </div>
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Main Content */}
          <div className="lg:col-span-2">
            {/* Step 1: Guest Information */}
            {currentStep === 1 && (
              <GuestInformationStep
                guestInfo={guestInfo}
                updateGuestInfo={updateGuestInfo}
                onNext={goToNextStep}
              />
            )}

            {/* Step 2: Payment */}
            {currentStep === 2 && (
              <PaymentStep
                paymentInfo={paymentInfo}
                updatePaymentInfo={updatePaymentInfo}
                onNext={goToNextStep}
                onBack={goToPreviousStep}
              />
            )}

            {/* Step 3: Confirmation */}
            {currentStep === 3 && (
              <ConfirmationStep
                bookingDetails={bookingDetails}
                guestInfo={guestInfo}
                paymentInfo={paymentInfo}
                bookingNumber={bookingNumber}
                bookingDate={bookingDate}
                onBack={goToPreviousStep}
                onComplete={handleCompleteBooking}
              />
            )}
          </div>

          {/* Booking Summary */}
          <div className="lg:col-span-1">
            <BookingSummary
              bookingDetails={bookingDetails}
              getTotalPrice={getTotalPrice}
              getTaxesAndFees={getTaxesAndFees}
              getFinalTotal={getFinalTotal}
              isConfirmed={currentStep === 3}
            />
          </div>
        </div>
      </div>
      <Footer />
    </div>
  );
}
