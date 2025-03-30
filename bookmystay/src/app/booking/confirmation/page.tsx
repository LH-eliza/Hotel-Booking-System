"use client";

import React, { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import Header from "../../components/header";
import Footer from "../../components/footer";

interface GuestInfo {
  firstName: string;
  lastName: string;
  email: string;
  phone: string;
  street: string;
  city: string;
  state: string;
  postalCode: string;
  country: string;
  idType: string;
  idNumber: string;
  registrationDate: string;
  specialRequests: string;
}

interface BookingDetails {
  hotelId: string;
  chainId: string;
  roomNumber: string;
  price: number;
  checkIn: string;
  checkOut: string;
  amenities: string[];
  starCategory: number;
  neighborhood: string;
  address: string;
  capacity: string;
  view: string;
  isAvailable: boolean;
}

export default function BookingConfirmationPage({ searchParams, }: { searchParams: { [key: string]: string | string[] |  undefined }; }) {
  const router = useRouter();
  const [guestInfo, setGuestInfo] = useState<GuestInfo>({
    firstName: "",
    lastName: "",
    email: "",
    phone: "",
    street: "",
    city: "",
    state: "",
    postalCode: "",
    country: "",
    idType: "SSN",
    idNumber: "",
    registrationDate: new Date().toISOString().split('T')[0],
    specialRequests: "",
  });
  const [bookingDetails, setBookingDetails] = useState<BookingDetails | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    // Get booking details from URL parameters
    const hotelId = searchParams.hotelId as string | undefined;
    const chainId = searchParams.chainId as string | undefined;
    const roomNumber = searchParams.roomNumber as string | undefined;
    const price = searchParams.price as string | undefined;
    const checkIn = searchParams.checkIn as string | undefined;
    const checkOut = searchParams.checkOut as string | undefined;
    const amenitiesSearch = searchParams.amenities as string | undefined;
    const amenities = amenitiesSearch?.split(',') || [];
    const starCategory = searchParams.starCategory as string | undefined;
    const neighborhood = searchParams.neighborhood as string | undefined;
    const address = searchParams.address as string | undefined;
    const capacity = searchParams.capacity as string | undefined;
    const view = searchParams.view as string | undefined;
    const availableSearch = searchParams.isAvailable as string | undefined;
    const isAvailable = availableSearch === 'true';

    // Log the parameters for debugging
    console.log('URL Parameters:', {
      hotelId,
      chainId,
      roomNumber,
      price,
      checkIn,
      checkOut,
      amenities,
      starCategory,
      neighborhood,
      address,
      capacity,
      view,
      isAvailable
    });

    // Set default dates if not provided
    const defaultCheckIn = new Date().toISOString().split('T')[0];
    const defaultCheckOut = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];

    // Create booking details with defaults where needed
    const bookingData: BookingDetails = {
      hotelId: hotelId || '',
      chainId: chainId || '',
      roomNumber: roomNumber || '',
      price: price ? parseFloat(price) : 0,
      checkIn: checkIn || defaultCheckIn,
      checkOut: checkOut || defaultCheckOut,
      amenities: amenities,
      starCategory: starCategory ? parseInt(starCategory) : 0,
      neighborhood: neighborhood || '',
      address: address || '',
      capacity: capacity || '',
      view: view || '',
      isAvailable: isAvailable,
    };

    // Validate required fields
    if (!hotelId || !chainId) {
      setError("Missing required hotel information. Please try booking again.");
    } else {
      setBookingDetails(bookingData);
    }
    setLoading(false);
  }, [searchParams]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
  
    try {
      // Step 1: Check if customer exists
      const checkCustomerQuery = {
        query: `
          SELECT customer_id 
          FROM customer 
          WHERE id_type = $1 AND id_number = $2
        `,
        values: [guestInfo.idType, guestInfo.idNumber],
      };
  
      const customerResponse = await fetch('/api/runQuery', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(checkCustomerQuery),
      });
  
      if (!customerResponse.ok) {
        throw new Error('Failed to check customer existence');
      }
  
      const customerData = await customerResponse.json();
      let customerId;
  
      if (customerData.length > 0) {
        // Customer exists
        customerId = customerData[0].customer_id;
        console.log('Existing customer ID:', customerId);
      } else {
        // Step 2: Create a new customer
        const fullAddress = `${guestInfo.street}, ${guestInfo.city}, ${guestInfo.state}, ${guestInfo.postalCode}, ${guestInfo.country}`.trim();
        const newCustomerId = `CUST${Math.floor(1000 + Math.random() * 9000)}`;
  
        const createCustomerQuery = {
          query: `
            INSERT INTO customer (customer_id, first_name, last_name, address, id_type, id_number, registration_date)
            VALUES ($1, $2, $3, $4, $5, $6, CURRENT_DATE)
          `,
          values: [
            newCustomerId,
            guestInfo.firstName,
            guestInfo.lastName,
            fullAddress,
            guestInfo.idType,
            guestInfo.idNumber,
          ],
        };
  
        const createCustomerResponse = await fetch('/api/runQuery', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(createCustomerQuery),
        });
  
        if (!createCustomerResponse.ok) {
          throw new Error('Failed to create new customer');
        }
  
        customerId = newCustomerId;
        console.log('New customer ID:', customerId);
      }
  
      // Step 3: Create booking
      const bookingId = Math.floor(1000 + Math.random() * 9000);

      const bookingQuery = {
        query: `
          INSERT INTO booking (booking_id, customer_id, start_date, end_date, room_id)
          VALUES ($1, $2, $3, $4, $5)
        `,
        values: [
          bookingId,
          customerId,
          bookingDetails?.checkIn,
          bookingDetails?.checkOut,
          bookingDetails?.roomNumber,
        ],
      };
  
      const bookingResponse = await fetch('/api/runQuery', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(bookingQuery),
      });
  
      if (!bookingResponse.ok) {
        throw new Error('Failed to create booking');
      }
  
      // Success Message & Redirect
      alert("Booking confirmed! Thank you for choosing our service.");
      router.push('/');
  
    } catch (error) {
      console.error('Error:', error);
      alert('An error occurred. Please try again.');
    }
  };
  

  if (loading) {
    return (
      <div>
        <Header />
        <div className="container mx-auto px-4 py-8">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-gray-900 mx-auto"></div>
        </div>
        <Footer />
      </div>
    );
  }

  if (error || !bookingDetails) {
    return (
      <div>
        <Header />
        <div className="container mx-auto px-4 py-8">
          <div className="text-red-600 text-center">{error || "Booking details not found"}</div>
        </div>
        <Footer />
      </div>
    );
  }

  return (
    <div>
      <Header />
      <div className="container mx-auto px-4 py-8">
        <div className="flex justify-between items-center mb-8">
          <h1 className="text-3xl font-bold">Confirm Your Booking</h1>
          <button
            onClick={() => router.back()}
            className="px-4 py-2 text-purple-700 hover:text-purple-800 flex items-center gap-2"
          >
            <svg
              className="w-5 h-5"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M10 19l-7-7m0 0l7-7m-7 7h18"
              />
            </svg>
            Back to Search
          </button>
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          {/* Booking Details */}
          <div className="bg-white rounded-lg shadow-md p-6">
            <h2 className="text-xl font-semibold mb-4">Booking Details</h2>
            <div className="space-y-4">
              <div>
                <h3 className="font-medium">Hotel Information</h3>
                <p>Chain ID: {bookingDetails.chainId}</p>
                <p>Hotel ID: {bookingDetails.hotelId}</p>
                <p>Room Number: {bookingDetails.roomNumber}</p>
                <p>Address: {bookingDetails.address}</p>
                <p className="text-sm text-gray-600">Neighborhood: {bookingDetails.neighborhood}</p>
                <div className="flex items-center gap-2 mt-2">
                  <span className="text-yellow-400">{Array(bookingDetails.starCategory).fill('★').join('')}</span>
                  <span className="text-sm text-gray-600">({bookingDetails.starCategory}-Star)</span>
                </div>
                <p className="mt-2">Capacity: {bookingDetails.capacity}</p>
                {bookingDetails.view && <p>View: {bookingDetails.view}</p>}
                <p className={`mt-2 ${bookingDetails.isAvailable ? 'text-green-600' : 'text-red-600'}`}>
                  Status: {bookingDetails.isAvailable ? 'Available' : 'Not Available'}
                </p>
              </div>
              
              <div>
                <h3 className="font-medium">Dates</h3>
                <p>Check-in: {new Date(bookingDetails.checkIn).toLocaleDateString()}</p>
                <p>Check-out: {new Date(bookingDetails.checkOut).toLocaleDateString()}</p>
              </div>

              <div>
                <h3 className="font-medium">Amenities</h3>
                <ul className="list-disc list-inside">
                  {bookingDetails.amenities.map((amenity, index) => (
                    <li key={index}>{amenity}</li>
                  ))}
                </ul>
              </div>

              <div>
                <h3 className="font-medium">Price</h3>
                <p className="text-2xl font-bold text-purple-700">${bookingDetails.price.toFixed(2)}</p>
                <p className="text-sm text-gray-600">per night</p>
              </div>
            </div>
          </div>

          {/* Guest Information Form */}
          <div className="bg-white rounded-lg shadow-md p-6">
            <h2 className="text-xl font-semibold mb-4">Guest Information</h2>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700">First Name</label>
                  <input
                    type="text"
                    required
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                    value={guestInfo.firstName}
                    onChange={(e) => setGuestInfo({ ...guestInfo, firstName: e.target.value })}
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">Last Name</label>
                  <input
                    type="text"
                    required
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                    value={guestInfo.lastName}
                    onChange={(e) => setGuestInfo({ ...guestInfo, lastName: e.target.value })}
                  />
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">Email</label>
                <input
                  type="email"
                  required
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                  value={guestInfo.email}
                  onChange={(e) => setGuestInfo({ ...guestInfo, email: e.target.value })}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">Phone</label>
                <input
                  type="tel"
                  required
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                  value={guestInfo.phone}
                  onChange={(e) => setGuestInfo({ ...guestInfo, phone: e.target.value })}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">Street Address</label>
                <input
                  type="text"
                  required
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                  value={guestInfo.street}
                  onChange={(e) => setGuestInfo({ ...guestInfo, street: e.target.value })}
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700">City</label>
                  <input
                    type="text"
                    required
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                    value={guestInfo.city}
                    onChange={(e) => setGuestInfo({ ...guestInfo, city: e.target.value })}
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">State/Province</label>
                  <input
                    type="text"
                    required
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                    value={guestInfo.state}
                    onChange={(e) => setGuestInfo({ ...guestInfo, state: e.target.value })}
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700">Postal Code</label>
                  <input
                    type="text"
                    required
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                    value={guestInfo.postalCode}
                    onChange={(e) => setGuestInfo({ ...guestInfo, postalCode: e.target.value })}
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">Country</label>
                  <input
                    type="text"
                    required
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                    value={guestInfo.country}
                    onChange={(e) => setGuestInfo({ ...guestInfo, country: e.target.value })}
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700">ID Type</label>
                  <select
                    required
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                    value={guestInfo.idType}
                    onChange={(e) => setGuestInfo({ ...guestInfo, idType: e.target.value })}
                  >
                    <option value="">Select ID Type</option>
                    <option value="SSN">Social Security Number (SSN)</option>
                    <option value="SIN">Social Insurance Number (SIN)</option>
                    <option value="DL">Driver's License</option>
                    <option value="Passport">Passport</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">ID Number</label>
                  <input
                    type="text"
                    required
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                    value={guestInfo.idNumber}
                    onChange={(e) => setGuestInfo({ ...guestInfo, idNumber: e.target.value })}
                  />
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">Registration Date</label>
                <input
                  type="date"
                  required
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                  value={guestInfo.registrationDate}
                  onChange={(e) => setGuestInfo({ ...guestInfo, registrationDate: e.target.value })}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">Special Requests</label>
                <textarea
                  className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-purple-500 focus:ring-purple-500"
                  rows={4}
                  value={guestInfo.specialRequests}
                  onChange={(e) => setGuestInfo({ ...guestInfo, specialRequests: e.target.value })}
                />
              </div>

              <div className="flex gap-4">
                <button
                  type="button"
                  onClick={() => router.back()}
                  className="flex-1 px-4 py-2 border border-purple-600 text-purple-600 rounded-md hover:bg-purple-50 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:ring-offset-2"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="flex-1 bg-purple-600 text-white py-2 px-4 rounded-md hover:bg-purple-700 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:ring-offset-2"
                >
                  Confirm Booking
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
      <Footer />
    </div>
  );
} 