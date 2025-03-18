import React from "react";
import { ArrowRight } from "lucide-react";

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

interface GuestInformationStepProps {
  guestInfo: GuestInfo;
  updateGuestInfo: (info: Partial<GuestInfo>) => void;
  onNext: () => void;
}

export default function GuestInformationStep({
  guestInfo,
  updateGuestInfo,
  onNext,
}: GuestInformationStepProps) {
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    // Validate required fields
    if (
      !guestInfo.firstName ||
      !guestInfo.lastName ||
      !guestInfo.email ||
      !guestInfo.phone
    ) {
      alert("Please fill in all required fields.");
      return;
    }

    onNext();
  };

  return (
    <form onSubmit={handleSubmit}>
      <h2 className="text-2xl font-bold text-gray-800 mb-6">
        Guest Information
      </h2>

      <div className="bg-white border border-gray-200 rounded-lg p-6 mb-6">
        <h3 className="text-lg font-medium text-gray-800 mb-4">
          Personal Details
        </h3>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label
              htmlFor="firstName"
              className="block text-sm font-medium text-gray-700 mb-1"
            >
              First Name <span className="text-red-500">*</span>
            </label>
            <input
              type="text"
              id="firstName"
              className="w-full p-2 border border-gray-300 rounded-md"
              value={guestInfo.firstName}
              onChange={(e) => updateGuestInfo({ firstName: e.target.value })}
              required
            />
          </div>

          <div>
            <label
              htmlFor="lastName"
              className="block text-sm font-medium text-gray-700 mb-1"
            >
              Last Name <span className="text-red-500">*</span>
            </label>
            <input
              type="text"
              id="lastName"
              className="w-full p-2 border border-gray-300 rounded-md"
              value={guestInfo.lastName}
              onChange={(e) => updateGuestInfo({ lastName: e.target.value })}
              required
            />
          </div>

          <div>
            <label
              htmlFor="email"
              className="block text-sm font-medium text-gray-700 mb-1"
            >
              Email <span className="text-red-500">*</span>
            </label>
            <input
              type="email"
              id="email"
              className="w-full p-2 border border-gray-300 rounded-md"
              value={guestInfo.email}
              onChange={(e) => updateGuestInfo({ email: e.target.value })}
              required
            />
          </div>

          <div>
            <label
              htmlFor="phone"
              className="block text-sm font-medium text-gray-700 mb-1"
            >
              Phone Number <span className="text-red-500">*</span>
            </label>
            <input
              type="tel"
              id="phone"
              className="w-full p-2 border border-gray-300 rounded-md"
              value={guestInfo.phone}
              onChange={(e) => updateGuestInfo({ phone: e.target.value })}
              required
            />
          </div>
        </div>
      </div>

      <div className="bg-white border border-gray-200 rounded-lg p-6 mb-6">
        <h3 className="text-lg font-medium text-gray-800 mb-4">
          Address Information
        </h3>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="md:col-span-2">
            <label
              htmlFor="address"
              className="block text-sm font-medium text-gray-700 mb-1"
            >
              Address
            </label>
            <input
              type="text"
              id="address"
              className="w-full p-2 border border-gray-300 rounded-md"
              value={guestInfo.address}
              onChange={(e) => updateGuestInfo({ address: e.target.value })}
            />
          </div>

          <div>
            <label
              htmlFor="city"
              className="block text-sm font-medium text-gray-700 mb-1"
            >
              City
            </label>
            <input
              type="text"
              id="city"
              className="w-full p-2 border border-gray-300 rounded-md"
              value={guestInfo.city}
              onChange={(e) => updateGuestInfo({ city: e.target.value })}
            />
          </div>

          <div>
            <label
              htmlFor="country"
              className="block text-sm font-medium text-gray-700 mb-1"
            >
              Country
            </label>
            <input
              type="text"
              id="country"
              className="w-full p-2 border border-gray-300 rounded-md"
              value={guestInfo.country}
              onChange={(e) => updateGuestInfo({ country: e.target.value })}
            />
          </div>

          <div>
            <label
              htmlFor="zipCode"
              className="block text-sm font-medium text-gray-700 mb-1"
            >
              Zip/Postal Code
            </label>
            <input
              type="text"
              id="zipCode"
              className="w-full p-2 border border-gray-300 rounded-md"
              value={guestInfo.zipCode}
              onChange={(e) => updateGuestInfo({ zipCode: e.target.value })}
            />
          </div>
        </div>
      </div>

      <div className="bg-white border border-gray-200 rounded-lg p-6 mb-6">
        <h3 className="text-lg font-medium text-gray-800 mb-4">
          Identification
        </h3>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label
              htmlFor="idType"
              className="block text-sm font-medium text-gray-700 mb-1"
            >
              ID Type
            </label>
            <select
              id="idType"
              className="w-full p-2 border border-gray-300 rounded-md"
              value={guestInfo.idType}
              onChange={(e) => updateGuestInfo({ idType: e.target.value })}
            >
              <option value="passport">Passport</option>
              <option value="driver_license">Driver's License</option>
              <option value="national_id">National ID</option>
              <option value="ssn">Social Security Number</option>
            </select>
          </div>

          <div>
            <label
              htmlFor="idNumber"
              className="block text-sm font-medium text-gray-700 mb-1"
            >
              ID Number
            </label>
            <input
              type="text"
              id="idNumber"
              className="w-full p-2 border border-gray-300 rounded-md"
              value={guestInfo.idNumber}
              onChange={(e) => updateGuestInfo({ idNumber: e.target.value })}
            />
          </div>
        </div>
      </div>

      <div className="bg-white border border-gray-200 rounded-lg p-6 mb-6">
        <h3 className="text-lg font-medium text-gray-800 mb-4">
          Special Requests
        </h3>

        <div>
          <label
            htmlFor="specialRequests"
            className="block text-sm font-medium text-gray-700 mb-1"
          >
            Any special requests?
          </label>
          <textarea
            id="specialRequests"
            rows={4}
            className="w-full p-2 border border-gray-300 rounded-md"
            placeholder="Let us know if you have any specific requirements or preferences."
            value={guestInfo.specialRequests}
            onChange={(e) =>
              updateGuestInfo({ specialRequests: e.target.value })
            }
          ></textarea>
        </div>
      </div>

      <div className="flex justify-end">
        <button
          type="submit"
          className="bg-purple-500 hover:bg-purple-600 text-white px-6 py-3 rounded-lg flex items-center"
        >
          Continue to Payment
          <ArrowRight size={18} className="ml-2" />
        </button>
      </div>
    </form>
  );
}
