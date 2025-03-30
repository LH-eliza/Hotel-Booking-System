"use client";

import React, { useState, useEffect } from "react";
import { useParams, useRouter, useSearchParams } from "next/navigation";
import {
  StarIcon,
  ArrowLeft,
  Check,
  MapPin,
  Info,
  PhoneCall,
  Mail,
  Calendar,
  Users,
} from "lucide-react";

import Header from "../../components/header";
import Footer from "../../components/footer";
import SimpleDatePicker from "../../components/datepicker";
import GuestSelector from "../../components/guest";

// Mock data - in a real app, this would be fetched from an API
const hotels = [
  {
    id: 1,
    name: "The Business Inn",
    location: "Ottawa",
    breakfast: true,
    refundable: true,
    rating: 9.1,
    ratingText: "Exceptional",
    reviews: 3295,
    originalPrice: 148,
    discountPrice: 139,
    tax: 21,
    discount: 7,
    image: "/api/placeholder/400/250",
    images: [
      "/api/placeholder/800/500",
      "/api/placeholder/800/500",
      "/api/placeholder/800/500",
    ],
    amenities: ["Free Wi-Fi", "Free Parking", "Breakfast", "Gym"],
    hotelChain: "Independent",
    starRating: 3,
    roomCount: 125,
    availableRooms: 42,
    checkIn: "3:00 PM",
    checkOut: "11:00 AM",
    address: "180 MacLaren St, Ottawa, ON K2P 0L3",
    email: "info@thebusinessinn.com",
    phone: "+1 (613) 555-1234",
    description:
      "Located in downtown Ottawa, The Business Inn offers spacious suites with fully equipped kitchens and complimentary breakfast.",
    policies: [
      "Check-in time: 3:00 PM",
      "Check-out time: 11:00 AM",
      "Cancellation: Free cancellation up to 24 hours before check-in",
      "Children: Children of all ages are welcome",
      "Pets: Pets are not allowed",
    ],
    rooms: [
      {
        id: 101,
        name: "Standard Studio Suite",
        capacity: "Single",
        price: 139,
        size: "400 sq ft",
        maxGuests: 2,
        amenities: [
          "Free Wi-Fi",
          "TV",
          "Air conditioning",
          "Mini-fridge",
          "Microwave",
          "Kitchenette",
        ],
        bedType: "1 Queen Bed",
        image: "/api/placeholder/400/250",
        description:
          "Comfortable suite with queen bed, work desk, and kitchenette.",
        available: true,
        view: "City View",
        extendable: false,
        issues: [],
      },
      {
        id: 102,
        name: "Deluxe One-Bedroom Suite",
        capacity: "Double",
        price: 169,
        size: "550 sq ft",
        maxGuests: 3,
        amenities: [
          "Free Wi-Fi",
          "TV",
          "Air conditioning",
          "Full kitchen",
          "Washer/Dryer",
        ],
        bedType: "1 Queen Bed + Sofa Bed",
        image: "/api/placeholder/400/250",
        description:
          "Spacious suite with separate bedroom, living area, and full kitchen.",
        available: true,
        view: "City View",
        extendable: true,
        issues: [],
      },
    ],
  },
  {
    id: 2,
    name: "Hilton Garden Inn",
    location: "Ottawa Downtown",
    breakfast: true,
    refundable: true,
    rating: 8.7,
    ratingText: "Excellent",
    reviews: 2157,
    originalPrice: 189,
    discountPrice: 169,
    tax: 25,
    discount: 20,
    image: "/api/placeholder/400/250",
    images: [
      "/api/placeholder/800/500",
      "/api/placeholder/800/500",
      "/api/placeholder/800/500",
    ],
    amenities: ["Free Wi-Fi", "Breakfast", "Gym", "Swimming Pool", "Spa"],
    hotelChain: "Hilton",
    starRating: 4,
    roomCount: 240,
    availableRooms: 85,
    checkIn: "3:00 PM",
    checkOut: "12:00 PM",
    address: "1400 Queen Elizabeth Dr, Ottawa, ON K1S 5Z7",
    email: "reservations@hiltongarden-ottawa.com",
    phone: "+1 (613) 555-0123",
    description:
      "Located in downtown Ottawa, this contemporary hotel is within walking distance to major attractions, shops, and restaurants.",
    policies: [
      "Check-in time: 3:00 PM",
      "Check-out time: 12:00 PM",
      "Cancellation: Free cancellation up to 24 hours before check-in",
      "Children: Children of all ages are welcome",
      "Pets: Pets are not allowed",
    ],
    rooms: [
      {
        id: 201,
        name: "Standard King Room",
        capacity: "Single",
        price: 169,
        size: "330 sq ft",
        maxGuests: 2,
        amenities: [
          "Free Wi-Fi",
          "TV",
          "Air conditioning",
          "Mini-fridge",
          "Coffee maker",
        ],
        bedType: "1 King Bed",
        image: "/api/placeholder/400/250",
        description:
          "Comfortable room with city view, work desk, and modern amenities.",
        available: true,
        view: "City View",
        extendable: false,
        issues: [],
      },
      {
        id: 202,
        name: "Double Queen Room",
        capacity: "Double",
        price: 189,
        size: "400 sq ft",
        maxGuests: 4,
        amenities: [
          "Free Wi-Fi",
          "TV",
          "Air conditioning",
          "Mini-fridge",
          "Coffee maker",
        ],
        bedType: "2 Queen Beds",
        image: "/api/placeholder/400/250",
        description:
          "Spacious room with two queen beds, perfect for families or groups.",
        available: true,
        view: "City View",
        extendable: true,
        issues: [],
      },
      {
        id: 203,
        name: "Deluxe King Suite",
        capacity: "Double",
        price: 249,
        discountPrice: 229,
        size: "550 sq ft",
        maxGuests: 3,
        amenities: [
          "Free Wi-Fi",
          "TV",
          "Air conditioning",
          "Mini-fridge",
          "Coffee maker",
          "Sofa bed",
          "Bathrobes",
        ],
        bedType: "1 King Bed + Sofa Bed",
        image: "/api/placeholder/400/250",
        description:
          "Luxurious suite with separate living area and panoramic views.",
        available: true,
        view: "Mountain View",
        extendable: true,
        issues: [],
      },
    ],
  },
  // Add more hotels as needed
];

interface DateRange {
  startDate: string;
  endDate: string;
}

interface GuestData {
  rooms: {
    id: number;
    name: string;
    adults: number;
    children: number;
  }[];
  displayText: string;
}

export default function HotelDetailPage() {
  const params = useParams();
  const router = useRouter();
  const searchParams = useSearchParams();
  const hotelId = typeof params.id === "string" ? parseInt(params.id) : -1;

  const [hotel, setHotel] = useState(null);
  const [loading, setLoading] = useState(true);
  const [activeImageIndex, setActiveImageIndex] = useState(0);
  const [dateRange, setDateRange] = useState<string>("03-05-2025 | 03-06-2025");
  const [guests, setGuests] = useState<string>("2 Adults, 0 Children");
  const [openDatePicker, setOpenDatePicker] = useState(false);
  const [openGuestSelector, setOpenGuestSelector] = useState(false);
  const [selectedTab, setSelectedTab] = useState("rooms");
  const [filteredRooms, setFilteredRooms] = useState([]);
  const [priceSort, setPriceSort] = useState<"asc" | "desc" | null>(null);
  const [selectedRoomIds, setSelectedRoomIds] = useState<number[]>([]);

  // Get the initial tab from query param if available
  useEffect(() => {
    const tab = searchParams.get("tab");
    if (tab && ["rooms", "details", "amenities", "policies"].includes(tab)) {
      setSelectedTab(tab);
    }
  }, [searchParams]);

  // Fetch hotel data based on ID
  useEffect(() => {
    // Simulating API call to fetch hotel details
    setTimeout(() => {
      const foundHotel = hotels.find((h) => h.id === hotelId);

      if (foundHotel) {
        setHotel(foundHotel);
        setFilteredRooms(foundHotel.rooms);
      }

      setLoading(false);
    }, 500);
  }, [hotelId]);

  useEffect(() => {
    if (hotel && hotel.rooms) {
      const rooms = [...hotel.rooms];

      // Apply price sorting if selected
      if (priceSort === "asc") {
        rooms.sort(
          (a, b) => (a.discountPrice || a.price) - (b.discountPrice || b.price)
        );
      } else if (priceSort === "desc") {
        rooms.sort(
          (a, b) => (b.discountPrice || b.price) - (a.discountPrice || a.price)
        );
      }

      setFilteredRooms(rooms);
    }
  }, [hotel, priceSort]);

  const handleDateSelect = (dateRange: DateRange): void => {
    setDateRange(`${dateRange.startDate} | ${dateRange.endDate}`);
    setOpenDatePicker(false);
  };

  const handleGuestSelect = (guestData: GuestData): void => {
    setGuests(guestData.displayText || "2 Adults, 0 Children");
    setOpenGuestSelector(false);
  };

  const toggleRoomSelection = (roomId: number) => {
    if (selectedRoomIds.includes(roomId)) {
      setSelectedRoomIds(selectedRoomIds.filter((id) => id !== roomId));
    } else {
      setSelectedRoomIds([...selectedRoomIds, roomId]);
    }
  };

  const getTotalPrice = () => {
    if (!hotel) return 0;

    return selectedRoomIds.reduce((total, roomId) => {
      const room = hotel.rooms.find((r) => r.id === roomId);
      if (room) {
        return total + (room.discountPrice || room.price);
      }
      return total;
    }, 0);
  };

  const handleBookNow = () => {
    if (selectedRoomIds.length === 0) {
      alert("Please select at least one room to book.");
      return;
    }

    router.push(
      `/confirmation?hotelId=${hotelId}&roomIds=${selectedRoomIds.join(
        ","
      )}&dates=${encodeURIComponent(dateRange)}&guests=${encodeURIComponent(
        guests
      )}`
    );
  };

  // Navigate to room detail page
  const navigateToRoomDetail = (roomId: number) => {
    router.push(
      `/hotels/${hotelId}/rooms/${roomId}?dates=${encodeURIComponent(
        dateRange
      )}&guests=${encodeURIComponent(guests)}`
    );
  };

  const goBack = () => {
    router.back();
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center min-h-screen">
        <div className="animate-spin rounded-full h-16 w-16 border-t-2 border-b-2 border-purple-500"></div>
      </div>
    );
  }

  if (!hotel) {
    return (
      <div className="flex justify-center items-center min-h-screen">
        <div className="text-center">
          <h2 className="text-2xl font-bold text-gray-800">Hotel Not Found</h2>
          <p className="text-gray-600 mt-2">
            The hotel you&apos;re looking for doesn&apos;t exist or has been removed.
          </p>
          <button
            onClick={goBack}
            className="mt-4 bg-purple-500 hover:bg-purple-600 text-white px-4 py-2 rounded"
          >
            Go Back
          </button>
        </div>
      </div>
    );
  }

  return (
    <div>
      <Header />
      <div className="container mx-auto px-4 py-8">
        {/* Back Button */}
        <button
          onClick={goBack}
          className="flex items-center text-purple-600 hover:text-purple-800 mb-6"
        >
          <ArrowLeft size={18} className="mr-2" />
          Back to Search Results
        </button>

        {/* Hotel Name and Rating */}
        <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-4">
          <div>
            <h1 className="text-3xl font-bold text-gray-800">{hotel.name}</h1>
            <div className="flex items-center mt-2">
              <div className="flex mr-2">
                {Array(hotel.starRating)
                  .fill(0)
                  .map((_, i) => (
                    <StarIcon key={i} className="w-5 h-5 text-yellow-400" />
                  ))}
              </div>
              <span className="text-gray-500">{hotel.hotelChain}</span>
            </div>
            <div className="flex items-center mt-2">
              <MapPin size={16} className="text-gray-500 mr-1" />
              <span className="text-gray-600">{hotel.address}</span>
            </div>
          </div>
          <div className="mt-4 md:mt-0 flex items-center">
            <div className="bg-green-600 text-white px-3 py-2 rounded flex items-center">
              <span className="font-bold text-xl mr-1">{hotel.rating}</span>
              <div className="flex flex-col text-xs">
                <span>/10</span>
                <span>{hotel.ratingText}</span>
              </div>
            </div>
            <div className="ml-3 text-sm text-gray-600">
              Based on
              <br />
              {hotel.reviews} reviews
            </div>
          </div>
        </div>

        {/* Main Image Gallery */}
        <div className="mb-8">
          <div className="relative h-96 rounded-xl overflow-hidden">
            <img
              src={hotel.images[activeImageIndex] || hotel.image}
              alt={hotel.name}
              className="w-full h-full object-cover"
            />
          </div>
          <div className="flex mt-2 space-x-2 overflow-x-auto pb-2">
            {hotel.images.map((image: string, index: number) => (
              <div
                key={index}
                className={`flex-shrink-0 w-24 h-16 rounded-lg overflow-hidden cursor-pointer border-2 ${
                  activeImageIndex === index
                    ? "border-purple-500"
                    : "border-transparent"
                }`}
                onClick={() => setActiveImageIndex(index)}
              >
                <img
                  src={image}
                  alt={`${hotel.name} ${index + 1}`}
                  className="w-full h-full object-cover"
                />
              </div>
            ))}
          </div>
        </div>

        {/* Booking Parameters */}
        <div className="bg-white rounded-xl shadow-md p-6 mb-8">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div className="border-b md:border-b-0 md:border-r border-gray-200 pb-4 md:pb-0 md:pr-4">
              <label className="block text-sm text-gray-500 mb-1">
                CHECK IN - CHECK OUT
              </label>
              <div
                className="flex items-center justify-between cursor-pointer"
                onClick={() => setOpenDatePicker(!openDatePicker)}
              >
                <div className="flex items-center">
                  <Calendar size={18} className="text-gray-700 mr-2" />
                  <span className="text-gray-800">{dateRange}</span>
                </div>
                <svg
                  className="w-5 h-5 text-gray-400"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M19 9l-7 7-7-7"
                  />
                </svg>
              </div>
              {openDatePicker && (
                <div className="absolute z-10 mt-2 bg-white shadow-lg rounded-lg py-1">
                  <SimpleDatePicker onDateChange={handleDateSelect} />
                </div>
              )}
            </div>

            <div className="border-b md:border-b-0 md:border-r border-gray-200 pb-4 md:pb-0 md:pr-4">
              <label className="block text-sm text-gray-500 mb-1">GUESTS</label>
              <div
                className="flex items-center justify-between cursor-pointer"
                onClick={() => setOpenGuestSelector(!openGuestSelector)}
              >
                <div className="flex items-center">
                  <Users size={18} className="text-gray-700 mr-2" />
                  <span className="text-gray-800">{guests}</span>
                </div>
                <svg
                  className="w-5 h-5 text-gray-400"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M19 9l-7 7-7-7"
                  />
                </svg>
              </div>
              {openGuestSelector && (
                <div className="absolute z-10 mt-2 bg-white shadow-lg rounded-lg py-1">
                  <GuestSelector onSelect={handleGuestSelect} />
                </div>
              )}
            </div>

            <div className="col-span-1 md:col-span-2">
              <div className="h-full flex flex-col justify-center">
                <div className="font-medium mb-1">Price:</div>
                <div className="flex items-baseline">
                  <span className="text-2xl font-bold text-gray-800">
                    ${getTotalPrice()}
                  </span>
                  <span className="text-gray-500 ml-2">for selected rooms</span>
                </div>
                <button
                  onClick={handleBookNow}
                  className={`mt-2 py-2 px-4 rounded font-medium ${
                    selectedRoomIds.length > 0
                      ? "bg-purple-500 hover:bg-purple-600 text-white"
                      : "bg-gray-200 text-gray-500 cursor-not-allowed"
                  }`}
                  disabled={selectedRoomIds.length === 0}
                >
                  Book Now
                </button>
              </div>
            </div>
          </div>
        </div>

        {/* Tabs Navigation */}
        <div className="border-b border-gray-200 mb-6">
          <nav className="flex space-x-8">
            <button
              onClick={() => setSelectedTab("rooms")}
              className={`py-4 px-1 border-b-2 font-medium text-sm ${
                selectedTab === "rooms"
                  ? "border-purple-500 text-purple-600"
                  : "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
              }`}
            >
              Rooms
            </button>
            <button
              onClick={() => setSelectedTab("details")}
              className={`py-4 px-1 border-b-2 font-medium text-sm ${
                selectedTab === "details"
                  ? "border-purple-500 text-purple-600"
                  : "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
              }`}
            >
              Hotel Details
            </button>
            <button
              onClick={() => setSelectedTab("amenities")}
              className={`py-4 px-1 border-b-2 font-medium text-sm ${
                selectedTab === "amenities"
                  ? "border-purple-500 text-purple-600"
                  : "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
              }`}
            >
              Amenities
            </button>
            <button
              onClick={() => setSelectedTab("policies")}
              className={`py-4 px-1 border-b-2 font-medium text-sm ${
                selectedTab === "policies"
                  ? "border-purple-500 text-purple-600"
                  : "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
              }`}
            >
              Policies
            </button>
          </nav>
        </div>

        {/* Tab Content */}
        <div className="mb-12">
          {/* Rooms Tab */}
          {selectedTab === "rooms" && (
            <div>
              <div className="flex justify-between items-center mb-4">
                <h2 className="text-xl font-bold text-gray-800">
                  Available Rooms
                </h2>
                <div className="flex items-center">
                  <span className="text-sm text-gray-600 mr-2">
                    Sort by price:
                  </span>
                  <button
                    onClick={() =>
                      setPriceSort(priceSort === "asc" ? null : "asc")
                    }
                    className={`text-sm px-3 py-1 rounded-l border ${
                      priceSort === "asc"
                        ? "bg-purple-100 text-purple-700 border-purple-300"
                        : "bg-white text-gray-700 border-gray-300"
                    }`}
                  >
                    Low to High
                  </button>
                  <button
                    onClick={() =>
                      setPriceSort(priceSort === "desc" ? null : "desc")
                    }
                    className={`text-sm px-3 py-1 rounded-r border-t border-r border-b ${
                      priceSort === "desc"
                        ? "bg-purple-100 text-purple-700 border-purple-300"
                        : "bg-white text-gray-700 border-gray-300"
                    }`}
                  >
                    High to Low
                  </button>
                </div>
              </div>

              {filteredRooms.map((room) => (
                <div
                  key={room.id}
                  className={`border border-gray-200 rounded-lg mb-4 overflow-hidden hover:shadow transition-shadow ${
                    !room.available ? "opacity-60" : ""
                  }`}
                >
                  <div className="flex flex-col md:flex-row">
                    <div
                      className="md:w-1/4 h-48 md:h-auto cursor-pointer"
                      onClick={() => navigateToRoomDetail(room.id)}
                    >
                      <img
                        src={room.image}
                        alt={room.name}
                        className="w-full h-full object-cover"
                      />
                    </div>
                    <div className="p-6 md:w-3/4 flex flex-col md:flex-row justify-between">
                      <div
                        className="md:w-2/3 cursor-pointer"
                        onClick={() => navigateToRoomDetail(room.id)}
                      >
                        <h3 className="text-xl font-bold">{room.name}</h3>
                        <div className="flex items-center mt-1 text-sm text-gray-600">
                          <span className="mr-4">{room.bedType}</span>
                          <span className="mr-4">{room.size}</span>
                          <span>{room.maxGuests} max guests</span>
                        </div>

                        <div className="flex items-center mt-2">
                          <span className="bg-blue-100 text-blue-800 text-xs px-2 py-1 rounded">
                            {room.view}
                          </span>
                          {room.extendable && (
                            <span className="bg-green-100 text-green-800 text-xs px-2 py-1 rounded ml-2">
                              Extendable
                            </span>
                          )}
                        </div>

                        <p className="text-gray-600 mt-2 text-sm">
                          {room.description}
                        </p>

                        <div className="mt-3">
                          <div className="text-sm font-medium mb-1">
                            Amenities:
                          </div>
                          <div className="flex flex-wrap gap-1">
                            {room.amenities
                              .slice(0, 4)
                              .map((amenity: string, i: number) => (
                                <span
                                  key={i}
                                  className="inline-flex items-center text-xs text-gray-600"
                                >
                                  <Check
                                    size={12}
                                    className="text-green-500 mr-1"
                                  />
                                  {amenity}
                                  {i < room.amenities.length - 1 && i < 3 && (
                                    <span className="mx-1">•</span>
                                  )}
                                </span>
                              ))}
                            {room.amenities.length > 4 && (
                              <span className="text-xs text-purple-600">
                                +{room.amenities.length - 4} more
                              </span>
                            )}
                          </div>
                        </div>

                        {room.issues && room.issues.length > 0 && (
                          <div className="mt-3">
                            <div className="text-sm font-medium text-red-600 flex items-center">
                              <Info size={14} className="mr-1" />
                              Issues:
                            </div>
                            <ul className="text-xs text-red-600 list-disc list-inside">
                              {room.issues.map((issue: string, i: number) => (
                                <li key={i}>{issue}</li>
                              ))}
                            </ul>
                          </div>
                        )}
                      </div>

                      <div className="md:w-1/3 mt-4 md:mt-0 flex flex-col items-end justify-between">
                        <div className="text-right">
                          {room.discountPrice &&
                            room.price !== room.discountPrice && (
                              <span className="text-gray-500 line-through text-sm">
                                ${room.price}
                              </span>
                            )}
                          <div className="text-2xl font-bold text-gray-800">
                            ${room.discountPrice || room.price}
                            <span className="text-sm font-normal text-gray-500">
                              /night
                            </span>
                          </div>
                        </div>

                        <div className="mt-4">
                          <div className="flex flex-col space-y-2">
                            {room.available ? (
                              <>
                                <button
                                  onClick={() => toggleRoomSelection(room.id)}
                                  className={`px-6 py-2 rounded font-medium ${
                                    selectedRoomIds.includes(room.id)
                                      ? "bg-purple-500 text-white"
                                      : "border border-purple-500 text-purple-500 hover:bg-purple-50"
                                  }`}
                                >
                                  {selectedRoomIds.includes(room.id)
                                    ? "Selected"
                                    : "Select Room"}
                                </button>
                                <button
                                  onClick={() => navigateToRoomDetail(room.id)}
                                  className="px-6 py-2 bg-gray-100 hover:bg-gray-200 rounded text-gray-700 font-medium"
                                >
                                  View Details
                                </button>
                              </>
                            ) : (
                              <div className="text-red-600 font-medium text-center">
                                Not Available
                              </div>
                            )}
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}

          {/* Hotel Details Tab */}
          {selectedTab === "details" && (
            <div>
              <h2 className="text-xl font-bold text-gray-800 mb-4">
                About {hotel.name}
              </h2>
              <p className="text-gray-600 mb-6">{hotel.description}</p>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <h3 className="text-lg font-semibold text-gray-800 mb-3">
                    Hotel Information
                  </h3>
                  <ul className="space-y-3">
                    <li className="flex items-start">
                      <MapPin
                        size={18}
                        className="text-gray-500 mr-2 mt-1 flex-shrink-0"
                      />
                      <div>
                        <div className="font-medium">Address</div>
                        <div className="text-gray-600">{hotel.address}</div>
                      </div>
                    </li>
                    <li className="flex items-start">
                      <Mail
                        size={18}
                        className="text-gray-500 mr-2 mt-1 flex-shrink-0"
                      />
                      <div>
                        <div className="font-medium">Email</div>
                        <div className="text-gray-600">{hotel.email}</div>
                      </div>
                    </li>
                    <li className="flex items-start">
                      <PhoneCall
                        size={18}
                        className="text-gray-500 mr-2 mt-1 flex-shrink-0"
                      />
                      <div>
                        <div className="font-medium">Phone</div>
                        <div className="text-gray-600">{hotel.phone}</div>
                      </div>
                    </li>
                  </ul>
                </div>

                <div>
                  <h3 className="text-lg font-semibold text-gray-800 mb-3">
                    Check-in & Check-out
                  </h3>
                  <ul className="space-y-3">
                    <li className="flex items-center">
                      <div className="w-32 font-medium">Check-in</div>
                      <div className="text-gray-600">{hotel.checkIn}</div>
                    </li>
                    <li className="flex items-center">
                      <div className="w-32 font-medium">Check-out</div>
                      <div className="text-gray-600">{hotel.checkOut}</div>
                    </li>
                    <li className="flex items-center">
                      <div className="w-32 font-medium">Total Rooms</div>
                      <div className="text-gray-600">{hotel.roomCount}</div>
                    </li>
                    <li className="flex items-center">
                      <div className="w-32 font-medium">Available</div>
                      <div className="text-gray-600">
                        {hotel.availableRooms} rooms
                      </div>
                    </li>
                  </ul>
                </div>
              </div>
            </div>
          )}

          {/* Amenities Tab */}
          {selectedTab === "amenities" && (
            <div>
              <h2 className="text-xl font-bold text-gray-800 mb-4">
                Hotel Amenities
              </h2>
              <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-y-4">
                {hotel.amenities.map((amenity: string, index: number) => (
                  <div key={index} className="flex items-center">
                    <Check size={18} className="text-green-500 mr-2" />
                    <span>{amenity}</span>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Policies Tab */}
          {selectedTab === "policies" && (
            <div>
              <h2 className="text-xl font-bold text-gray-800 mb-4">
                Hotel Policies
              </h2>
              <div className="bg-gray-50 rounded-lg p-6">
                <ul className="space-y-4">
                  {hotel.policies.map((policy: string, index: number) => (
                    <li key={index} className="flex items-start">
                      <Info
                        size={18}
                        className="text-gray-500 mr-2 mt-0.5 flex-shrink-0"
                      />
                      <span>{policy}</span>
                    </li>
                  ))}
                </ul>
              </div>
            </div>
          )}
        </div>
      </div>
      <Footer />
    </div>
  );
}
