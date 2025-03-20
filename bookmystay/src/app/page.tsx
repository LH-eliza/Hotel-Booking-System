"use client";

import React, { use, useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { Search, ChevronDown, Menu } from "lucide-react";
import Background from "./components/background";
import SimpleDatePicker from "./components/datepicker";
import GuestSelector from "./components/guest";
import Header from "./components/header";
import Footer from "./components/footer";

interface DateRange {
  startDate: string;
  endDate: string;
}

interface Room {
  id: number;
  name: string;
  adults: number;
  children: number;
}

interface GuestData {
  rooms: Room[];
  displayText: string;
}

interface SearchFormData {
  dates: DateRange | null;
  hotel: string;
  destination: string;
  guests: GuestData | null;
}

// Sample data for dropdowns
// const HOTELS: string[] = [
//   "Westin",
//   "Hilton",
//   "Marriott",
//   "Four Seasons",
//   "Hyatt",
//   "Ritz-Carlton",
// ];

// const DESTINATIONS: string[] = [
//   'Centretown', 'The Glebe', 'Byward Market', 'Rockcliffe Park', 'Westboro', 'Old Ottawa East',
//   'Orleans', 'Kanata', 'Barrhaven', 'Nepean', 'Manotick', 'Stittsville', 'New Edinburgh',
//   'Sandy Hill', 'Carleton Heights', 'Carp', 'Alta Vista', 'Little Italy', 'Overbrook', 'Cumberland'
// ];

const HotelSearchPage: React.FC = () => {
  const [destinations, setDestinations] = useState([]);
  const [hotels, setHotels] = useState([]);
  const [query, setQuery] = useState("SELECT * FROM Customer"); // State to hold the query string
  const [data, setData] = useState(null); // State to hold the API response
  const [error, setError] = useState(""); // State to hold any errors
  const router = useRouter();

  useEffect(() => {
    fetchNeighborhoods();
    fetchHotelChainID();
    fetchData(); // Fetch data when the component mounts
  }, [query]); // Re-fetch data when the query state changes

  const fetchNeighborhoods = async () => {
    try {
      const response = await fetch("/api/destinations");
      if (response.ok) {
        const data = await response.json();
        setDestinations(data); // Store the destinations from the response
      } else {
        throw new Error("Failed to fetch destinations");
      }
    } catch (error) {
      console.log(error.message);
      setError(error.message);
    }
  };

  const fetchHotelChainID = async () => {
    try {
      const response = await fetch("/api/hotel_chain");
      if (response.ok) {
        const data = await response.json();
        setHotels(data); // Store the hotel ids from the response
      } else {
        throw new Error("Failed to fetch hotel ids");
      }
    } catch (error) {
      console.log(error.message);
      setError(error.message);
    }
  };

  const fetchData = async () => {
    if (!query) {
      setError("Query cannot be empty");
      return;
    }

    try {
      // Send the query to the backend via GET request
      const response = await fetch(
        `/api/data?query=${encodeURIComponent(query)}`
      );

      if (response.ok) {
        const jsonData = await response.json();
        setData(jsonData); // Store the data in state
        setError(""); // Clear any previous errors
      } else {
        throw new Error("Failed to fetch data");
      }
    } catch (error) {
      setError(error.message); // Set the error message
    }
  };

  const [formData, setFormData] = useState<SearchFormData>({
    dates: null,
    hotel: "",
    destination: "",
    guests: null,
  });

  const [openDropdown, setOpenDropdown] = useState<string | null>(null);
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  const handleDateSelect = (dateRange: DateRange): void => {
    setFormData((prev) => ({
      ...prev,
      dates: dateRange,
    }));
  };

  const handleGuestSelect = (guestData: GuestData): void => {
    setFormData((prev) => ({
      ...prev,
      guests: guestData,
    }));
  };

  const toggleDropdown = (name: string): void => {
    if (openDropdown === name) {
      setOpenDropdown(null);
    } else {
      setOpenDropdown(name);
    }
  };

  const toggleDateDropdown = (): void => {
    toggleDropdown("dates");
    // You may need to add logic here to open/close your date picker component
  };

  const selectOption = (name: "hotel" | "destination", value: string): void => {
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));
    setOpenDropdown(null);
  };

  const handleSubmit = (e: React.FormEvent): void => {
    e.preventDefault();

    // Construct query parameters from formData
    const query = new URLSearchParams({
      startDate: formData.dates?.startDate || "",
      endDate: formData.dates?.endDate || "",
      hotel: formData.hotel || "",
      destination: formData.destination || "",
      guests: JSON.stringify(formData.guests || {}),
    }).toString();

    // Navigate to the /booking page with query parameters
    router.push(`/booking?${query}`);
  };

  return (
    <div>
      <Header />
      <div className="relative w-full max-w-6xl mx-auto px-4 mb-20 md:mb-32">
        <Background />
        <div className="absolute bottom-0 left-0 right-0 transform mb-6 md:mb-12 px-4 md:px-8">
          <form onSubmit={handleSubmit} className="relative">
            {/* Desktop layout */}
            <div className="hidden md:flex bg-white rounded-full shadow-lg p-3 items-center">
              <div className="flex-1 px-3">
                <label
                  htmlFor="dates"
                  className="block text-xs text-gray-500 mb-1"
                >
                  DATES
                </label>
                <div
                  className="flex items-center justify-between cursor-pointer"
                  onClick={() => toggleDateDropdown()}
                >
                  <SimpleDatePicker onDateChange={handleDateSelect} />
                  <ChevronDown
                    size={16}
                    className={`ml-2 transition-transform duration-200 ${
                      openDropdown === "dates" ? "transform rotate-180" : ""
                    }`}
                  />
                </div>
              </div>
              <div className="flex-1 px-3 border-l border-gray-200">
                <label className="block text-xs text-gray-500 mb-1">
                  HOTEL CHAIN
                </label>
                <div className="relative">
                  <button
                    type="button"
                    className="w-full text-left text-sm flex items-center justify-between focus:outline-none cursor-pointer"
                    onClick={() => toggleDropdown("hotel")}
                  >
                    <span>{formData.hotel || "Select hotel"}</span>
                    <ChevronDown
                      size={16}
                      className={`ml-2 transition-transform duration-200 ${
                        openDropdown === "hotel" ? "transform rotate-180" : ""
                      }`}
                    />
                  </button>

                  {openDropdown === "hotel" && (
                    <div className="absolute top-full left-0 right-0 mt-1 bg-white shadow-lg rounded-lg py-1 z-10 max-h-48 overflow-y-auto">
                      {hotels.map((hotel) => (
                        <div
                          key={hotel}
                          className="px-4 py-2 hover:bg-gray-100 cursor-pointer text-sm"
                          onClick={() => selectOption("hotel", hotel)}
                        >
                          {hotel}
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              </div>

              {/* Destination Dropdown */}
              <div className="flex-1 px-3 border-l border-gray-200">
                <label className="block text-xs text-gray-500 mb-1">
                  NEIGHBORHOOD
                </label>
                <div className="relative">
                  <button
                    type="button"
                    className="w-full text-left text-sm flex items-center justify-between focus:outline-none cursor-pointer"
                    onClick={() => toggleDropdown("destination")}
                  >
                    <span>{formData.destination || "Where to?"}</span>
                    <ChevronDown
                      size={16}
                      className={`ml-2 transition-transform duration-200 ${
                        openDropdown === "destination"
                          ? "transform rotate-180"
                          : ""
                      }`}
                    />
                  </button>

                  {openDropdown === "destination" && (
                    <div className="absolute top-full left-0 right-0 mt-1 bg-white shadow-lg rounded-lg py-1 z-10 max-h-48 overflow-y-auto">
                      {destinations.map((destination) => (
                        <div
                          key={destination}
                          className="px-4 py-2 hover:bg-gray-100 cursor-pointer text-sm"
                          onClick={() =>
                            selectOption("destination", destination)
                          }
                        >
                          {destination}
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              </div>

              {/* CAPACITY Dropdown */}
              <div className="flex-1 px-3 border-l border-gray-200">
                <label className="block text-xs text-gray-500 mb-1">
                  CAPACITY
                </label>
                <div className="relative">
                  <div className="w-full cursor-pointer">
                    <GuestSelector onSelect={handleGuestSelect} />
                  </div>
                </div>
              </div>

              {/* Search Button */}
              <button
                type="submit"
                className="ml-4 p-3 bg-[#A7AACC] hover:bg-[#9095D3] rounded-full text-white transition-colors cursor-pointer"
                aria-label="Search hotels"
              >
                <Search size={20} />
              </button>
            </div>

            {/* Mobile layout */}
            <div className="md:hidden bg-white rounded-lg shadow-lg">
              <div className="p-4">
                <div className="mb-4">
                  <label className="block text-xs text-gray-500 mb-1">
                    DATES
                  </label>
                  <div
                    className="flex items-center justify-between border border-gray-200 rounded px-3 py-2 cursor-pointer"
                    onClick={() => toggleDropdown("dates-mobile")}
                  >
                    <SimpleDatePicker onDateChange={handleDateSelect} />
                    <ChevronDown
                      size={16}
                      className={`ml-2 transition-transform duration-200 ${
                        openDropdown === "dates-mobile"
                          ? "transform rotate-180"
                          : ""
                      }`}
                    />
                  </div>
                </div>

                <div className="mb-4">
                  <label className="block text-xs text-gray-500 mb-1">
                    HOTEL CHAIN
                  </label>
                  <div className="relative">
                    <button
                      type="button"
                      className="w-full text-left text-sm py-2 border border-gray-200 rounded px-3 flex items-center justify-between focus:outline-none"
                      onClick={() => toggleDropdown("hotel-mobile")}
                    >
                      <span>{formData.hotel || "Select hotel"}</span>
                      <ChevronDown
                        size={16}
                        className={`ml-2 transition-transform duration-200 ${
                          openDropdown === "hotel-mobile"
                            ? "transform rotate-180"
                            : ""
                        }`}
                      />
                    </button>

                    {openDropdown === "hotel-mobile" && (
                      <div className="absolute top-full left-0 right-0 mt-1 bg-white shadow-lg rounded-lg py-1 z-10 max-h-48 overflow-y-auto">
                        {hotels.map((hotel) => (
                          <div
                            key={hotel}
                            className="px-4 py-2 hover:bg-gray-100 cursor-pointer text-sm"
                            onClick={() => selectOption("hotel", hotel)}
                          >
                            {hotel}
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                </div>

                <div className="mb-4">
                  <label className="block text-xs text-gray-500 mb-1">
                    DESTINATION
                  </label>
                  <div className="relative">
                    <button
                      type="button"
                      className="w-full text-left text-sm py-2 border border-gray-200 rounded px-3 flex items-center justify-between focus:outline-none"
                      onClick={() => toggleDropdown("destination-mobile")}
                    >
                      <span>{formData.destination || "Where to?"}</span>
                      <ChevronDown
                        size={16}
                        className={`ml-2 transition-transform duration-200 ${
                          openDropdown === "destination-mobile"
                            ? "transform rotate-180"
                            : ""
                        }`}
                      />
                    </button>

                    {openDropdown === "destination-mobile" && (
                      <div className="absolute top-full left-0 right-0 mt-1 bg-white shadow-lg rounded-lg py-1 z-10 max-h-48 overflow-y-auto">
                        {destinations.map((destination) => (
                          <div
                            key={destination}
                            className="px-4 py-2 hover:bg-gray-100 cursor-pointer text-sm"
                            onClick={() =>
                              selectOption("destination", destination)
                            }
                          >
                            {destination}
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                </div>

                <div className="mb-4">
                  <label className="block text-xs text-gray-500 mb-1">
                    CAPACITY
                  </label>
                  <div className="relative">
                    <div className="w-full cursor-pointer">
                      <GuestSelector onSelect={handleGuestSelect} />
                    </div>
                  </div>
                </div>

                <button
                  type="submit"
                  className="w-full py-3 bg-[#A7AACC] hover:bg-[#9095D3] rounded-lg text-white transition-colors cursor-pointer flex items-center justify-center"
                  aria-label="Search hotels"
                >
                  <Search size={20} className="mr-2" />
                  <span>Search</span>
                </button>
              </div>
            </div>
          </form>
        </div>
      </div>
      <Footer />
    </div>
  );
};

export default HotelSearchPage;
