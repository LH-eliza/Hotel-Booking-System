"use client";

import React, { useState } from "react";
import { StarIcon, Search, ChevronDown, Check, Filter, X } from "lucide-react";
import Image from "next/image";
import { useRouter } from "next/navigation";

import SimpleDatePicker from "../components/datepicker";
import GuestSelector from "../components/guest";
import Header from "../components/header";
import Footer from "../components/footer";

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

interface Hotel {
  id: number;
  name: string;
  location: string;
  breakfast: boolean;
  refundable: boolean;
  rating: number;
  ratingText: string;
  reviews: number;
  originalPrice: number;
  discountPrice: number;
  tax: number;
  discount: number;
  image: string;
  amenities: string[];
  hotelChain: string;
  starRating: number;
  roomCount: number;
  availableRooms: number;
}

const HOTEL_CHAINS: string[] = [
  "Westin",
  "Hilton",
  "Marriott",
  "Four Seasons",
  "Hyatt",
];

const DESTINATIONS: string[] = [
  "New York",
  "Los Angeles",
  "Miami",
  "Chicago",
  "Las Vegas",
  "San Francisco",
  "Orlando",
  "Ottawa",
];

export default function HotelBookingPage(): React.ReactElement {
  const router = useRouter();
  const [hotelBrand, setHotelBrand] = useState<string>("Hilton");
  const [dateRange, setDateRange] = useState<string>("03-05-2025 | 03-06-2025");
  const [location, setLocation] = useState<string>("Ottawa, Canada");
  const [guests, setGuests] = useState<string>("2 Adults, 3 Kids");
  const [starRating, setStarRating] = useState<number>(0);
  const [priceMin, setPriceMin] = useState<string>("");
  const [priceMax, setPriceMax] = useState<string>("");
  const [sortBy, setSortBy] = useState<string>("Recommended");
  const [amenities, setAmenities] = useState<string[]>([]);
  const [mobileFiltersOpen, setMobileFiltersOpen] = useState<boolean>(false);
  const [activeFilters, setActiveFilters] = useState<string[]>([]);

  const [formData, setFormData] = useState<SearchFormData>({
    dates: null,
    hotel: "Hilton",
    destination: "Ottawa, Canada",
    guests: null,
  });
  const [openDropdown, setOpenDropdown] = useState<string | null>(null);

  // This would typically be fetched based on the filters
  const hotels: Hotel[] = [
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
      amenities: ["Free Wi-Fi", "Free Parking", "Breakfast", "Gym"],
      hotelChain: "Independent",
      starRating: 3,
      roomCount: 125,
      availableRooms: 42,
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
      amenities: ["Free Wi-Fi", "Breakfast", "Gym", "Swimming Pool", "Spa"],
      hotelChain: "Hilton",
      starRating: 4,
      roomCount: 240,
      availableRooms: 85,
    },
    {
      id: 3,
      name: "Fairmont Château Laurier",
      location: "Ottawa Central",
      breakfast: true,
      refundable: false,
      rating: 9.4,
      ratingText: "Exceptional",
      reviews: 4210,
      originalPrice: 299,
      discountPrice: 259,
      tax: 38,
      discount: 40,
      image: "/api/placeholder/400/250",
      amenities: [
        "Free Wi-Fi",
        "Swimming Pool",
        "Spa",
        "Pet Friendly",
        "Airport Shuttle",
      ],
      hotelChain: "Fairmont",
      starRating: 5,
      roomCount: 320,
      availableRooms: 55,
    },
    {
      id: 4,
      name: "Lord Elgin Hotel",
      location: "Ottawa",
      breakfast: false,
      refundable: true,
      rating: 8.5,
      ratingText: "Very Good",
      reviews: 1876,
      originalPrice: 159,
      discountPrice: 149,
      tax: 22,
      discount: 10,
      image: "/api/placeholder/400/250",
      amenities: ["Free Wi-Fi", "Gym"],
      hotelChain: "Independent",
      starRating: 3,
      roomCount: 180,
      availableRooms: 78,
    },
    {
      id: 5,
      name: "Andaz Ottawa ByWard Market",
      location: "ByWard Market",
      breakfast: true,
      refundable: true,
      rating: 9.0,
      ratingText: "Excellent",
      reviews: 1493,
      originalPrice: 229,
      discountPrice: 199,
      tax: 30,
      discount: 30,
      image: "/api/placeholder/400/250",
      amenities: ["Free Wi-Fi", "Breakfast", "Gym", "Pet Friendly"],
      hotelChain: "Hyatt",
      starRating: 4,
      roomCount: 210,
      availableRooms: 64,
    },
  ];

  const handleStarRatingChange = (stars: number): void => {
    // Toggle the filter if the same star is clicked
    const newStarRating = starRating === stars ? 0 : stars;
    setStarRating(newStarRating);

    if (newStarRating > 0) {
      const filterLabel = `${newStarRating} ${
        newStarRating === 1 ? "Star" : "Stars"
      }`;
      if (!activeFilters.includes(filterLabel)) {
        setActiveFilters([
          ...activeFilters.filter((f) => !f.includes("Star")),
          filterLabel,
        ]);
      }
    } else {
      setActiveFilters(activeFilters.filter((f) => !f.includes("Star")));
    }
  };

  const handleAmenityChange = (amenity: string): void => {
    let newAmenities;
    if (amenities.includes(amenity)) {
      newAmenities = amenities.filter((a) => a !== amenity);
      setActiveFilters(activeFilters.filter((f) => f !== amenity));
    } else {
      newAmenities = [...amenities, amenity];
      setActiveFilters([...activeFilters, amenity]);
    }
    setAmenities(newAmenities);
  };

  const handleDateSelect = (dateRange: DateRange): void => {
    setFormData((prev) => ({
      ...prev,
      dates: dateRange,
    }));
    setDateRange(`${dateRange.startDate} | ${dateRange.endDate}`);
  };

  const handleGuestSelect = (guestData: GuestData): void => {
    setFormData((prev) => ({
      ...prev,
      guests: guestData,
    }));
    setGuests(guestData.displayText || "2 Adults, 3 Kids");
  };

  const toggleDropdown = (name: string): void => {
    if (openDropdown === name) {
      setOpenDropdown(null);
    } else {
      setOpenDropdown(name);
    }
  };

  const selectOption = (name: "hotel" | "destination", value: string): void => {
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));

    if (name === "hotel") {
      setHotelBrand(value);
      const hotelFilterLabel = `Hotel: ${value}`;
      setActiveFilters([
        ...activeFilters.filter((f) => !f.startsWith("Hotel:")),
        hotelFilterLabel,
      ]);
    } else if (name === "destination") {
      setLocation(value);
      const locationFilterLabel = `Location: ${value}`;
      setActiveFilters([
        ...activeFilters.filter((f) => !f.startsWith("Location:")),
        locationFilterLabel,
      ]);
    }

    setOpenDropdown(null);
  };

  const handleSubmit = (e: React.FormEvent): void => {
    e.preventDefault();
    console.log("Search submitted:", formData);
    // This would typically fetch new hotel results based on search criteria
  };

  const handlePriceChange = () => {
    if (priceMin && priceMax) {
      const priceFilterLabel = `Price: $${priceMin}-$${priceMax}`;
      setActiveFilters([
        ...activeFilters.filter((f) => !f.startsWith("Price:")),
        priceFilterLabel,
      ]);
    }
  };

  const removeFilter = (filter: string) => {
    if (filter.includes("Star")) {
      setStarRating(0);
    } else if (filter.startsWith("Price:")) {
      setPriceMin("");
      setPriceMax("");
    } else if (filter.startsWith("Hotel:")) {
      setHotelBrand("");
      setFormData((prev) => ({ ...prev, hotel: "" }));
    } else if (filter.startsWith("Location:")) {
      setLocation("");
      setFormData((prev) => ({ ...prev, destination: "" }));
    } else {
      // It's an amenity
      setAmenities(amenities.filter((a) => a !== filter));
    }

    setActiveFilters(activeFilters.filter((f) => f !== filter));
  };

  const clearAllFilters = () => {
    setStarRating(0);
    setPriceMin("");
    setPriceMax("");
    setAmenities([]);
    setActiveFilters([]);
  };

  // Function to navigate to hotel detail page
  const navigateToHotelDetail = (hotelId: number) => {
    router.push(`/hotels/${hotelId}`);
  };

  // Function to sort hotels based on selected sort option
  const getSortedHotels = (): Hotel[] => {
    let sortedHotels = [...hotels];

    // Apply filters
    if (starRating > 0) {
      sortedHotels = sortedHotels.filter(
        (hotel) => hotel.starRating === starRating
      );
    }

    if (amenities.length > 0) {
      sortedHotels = sortedHotels.filter((hotel) =>
        amenities.every((amenity) => hotel.amenities.includes(amenity))
      );
    }

    if (priceMin && priceMax) {
      const min = parseInt(priceMin);
      const max = parseInt(priceMax);
      if (!isNaN(min) && !isNaN(max)) {
        sortedHotels = sortedHotels.filter(
          (hotel) => hotel.discountPrice >= min && hotel.discountPrice <= max
        );
      }
    }

    if (hotelBrand && hotelBrand !== "") {
      sortedHotels = sortedHotels.filter((hotel) =>
        hotel.hotelChain.toLowerCase().includes(hotelBrand.toLowerCase())
      );
    }

    // Apply sort
    switch (sortBy) {
      case "Price: Low to High":
        sortedHotels.sort((a, b) => a.discountPrice - b.discountPrice);
        break;
      case "Price: High to Low":
        sortedHotels.sort((a, b) => b.discountPrice - a.discountPrice);
        break;
      case "Rating: High to Low":
        sortedHotels.sort((a, b) => b.rating - a.rating);
        break;
      case "Availability":
        sortedHotels.sort((a, b) => b.availableRooms - a.availableRooms);
        break;
      default:
        // "Recommended" or any other option keeps the default order
        break;
    }

    return sortedHotels;
  };

  return (
    <div>
      <Header />
      <div className="container mx-auto px-4 font-sans">
        {/* Search Bar Section */}
        <div className="relative w-full max-w-6xl mx-auto mt-8 mb-8">
          <form onSubmit={handleSubmit} className="relative">
            {/* Desktop layout */}
            <div className="hidden md:flex bg-white rounded-2xl shadow-lg p-3 items-center">
              <div className="flex-1 px-3">
                <label
                  htmlFor="hotel"
                  className="block text-xs text-gray-500 mb-1"
                >
                  HOTEL CHAIN
                </label>
                <div className="relative">
                  <button
                    type="button"
                    className="w-full text-left text-sm flex items-center justify-between focus:outline-none cursor-pointer"
                    onClick={() => toggleDropdown("hotel")}
                  >
                    <span>{formData.hotel || "Any Chain"}</span>
                    <ChevronDown
                      size={16}
                      className={`ml-2 transition-transform duration-200 ${
                        openDropdown === "hotel" ? "transform rotate-180" : ""
                      }`}
                    />
                  </button>

                  {openDropdown === "hotel" && (
                    <div className="absolute top-full left-0 right-0 mt-1 bg-white shadow-lg rounded-lg py-1 z-10 max-h-48 overflow-y-auto">
                      <div
                        className="px-4 py-2 hover:bg-gray-100 cursor-pointer text-sm font-medium text-purple-600"
                        onClick={() => selectOption("hotel", "")}
                      >
                        Any Chain
                      </div>
                      {HOTEL_CHAINS.map((hotel) => (
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

              <div className="flex-1 px-3 border-l border-gray-200">
                <label
                  htmlFor="dates"
                  className="block text-xs text-gray-500 mb-1"
                >
                  DATES
                </label>
                <div
                  className="flex items-center justify-between cursor-pointer"
                  onClick={() => toggleDropdown("dates")}
                >
                  <span>{dateRange}</span>
                  <ChevronDown
                    size={16}
                    className={`ml-2 transition-transform duration-200 ${
                      openDropdown === "dates" ? "transform rotate-180" : ""
                    }`}
                  />
                </div>
                {openDropdown === "dates" && (
                  <div className="absolute top-full mt-1 bg-white shadow-lg rounded-lg py-1 z-10">
                    <SimpleDatePicker onDateChange={handleDateSelect} />
                  </div>
                )}
              </div>

              <div className="flex-1 px-3 border-l border-gray-200">
                <label
                  htmlFor="destination"
                  className="block text-xs text-gray-500 mb-1"
                >
                  DESTINATION
                </label>
                <div className="relative">
                  <button
                    type="button"
                    className="w-full text-left text-sm flex items-center justify-between focus:outline-none cursor-pointer"
                    onClick={() => toggleDropdown("destination")}
                  >
                    <span>{formData.destination || location}</span>
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
                      {DESTINATIONS.map((destination) => (
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

              <div className="flex-1 px-3 border-l border-gray-200">
                <label
                  htmlFor="guests"
                  className="block text-xs text-gray-500 mb-1"
                >
                  GUESTS
                </label>
                <div className="relative">
                  <div
                    className="w-full cursor-pointer text-sm flex items-center justify-between"
                    onClick={() => toggleDropdown("guests")}
                  >
                    <span>{guests}</span>
                    <ChevronDown
                      size={16}
                      className={`ml-2 transition-transform duration-200 ${
                        openDropdown === "guests" ? "transform rotate-180" : ""
                      }`}
                    />
                  </div>
                  {openDropdown === "guests" && (
                    <div className="absolute top-full left-0 right-0 mt-1 bg-white shadow-lg rounded-lg py-1 z-10">
                      <GuestSelector onSelect={handleGuestSelect} />
                    </div>
                  )}
                </div>
              </div>

              <button
                type="submit"
                className="ml-4 p-3 bg-purple-500 hover:bg-purple-600 rounded-full text-white transition-colors cursor-pointer"
                aria-label="Search hotels"
              >
                <Search size={20} />
              </button>
            </div>

            {/* Mobile layout */}
            <div className="md:hidden bg-white rounded-lg shadow-lg mb-6">
              <div className="p-4 space-y-4">
                <div>
                  <label className="block text-xs text-gray-500 mb-1">
                    HOTEL CHAIN
                  </label>
                  <input
                    type="text"
                    placeholder="E.g. Westin"
                    className="w-full border border-gray-300 rounded-lg py-2 px-3"
                    value={hotelBrand}
                    onChange={(e) => setHotelBrand(e.target.value)}
                  />
                </div>

                <div>
                  <label className="block text-xs text-gray-500 mb-1">
                    DATES
                  </label>
                  <input
                    type="text"
                    className="w-full border border-gray-300 rounded-lg py-2 px-3"
                    value={dateRange}
                    readOnly
                    onClick={() => toggleDropdown("dates-mobile")}
                  />
                  {openDropdown === "dates-mobile" && (
                    <div className="mt-1 bg-white shadow-lg rounded-lg py-1 z-10">
                      <SimpleDatePicker onDateChange={handleDateSelect} />
                    </div>
                  )}
                </div>

                <div>
                  <label className="block text-xs text-gray-500 mb-1">
                    DESTINATION
                  </label>
                  <input
                    type="text"
                    placeholder="Where to?"
                    className="w-full border border-gray-300 rounded-lg py-2 px-3"
                    value={location}
                    onChange={(e) => setLocation(e.target.value)}
                  />
                </div>

                <div>
                  <label className="block text-xs text-gray-500 mb-1">
                    GUESTS
                  </label>
                  <input
                    type="text"
                    className="w-full border border-gray-300 rounded-lg py-2 px-3"
                    value={guests}
                    readOnly
                    onClick={() => toggleDropdown("guests-mobile")}
                  />
                  {openDropdown === "guests-mobile" && (
                    <div className="mt-1 bg-white shadow-lg rounded-lg py-1 z-10">
                      <GuestSelector onSelect={handleGuestSelect} />
                    </div>
                  )}
                </div>

                <button
                  type="submit"
                  className="w-full py-3 bg-purple-400 hover:bg-purple-500 rounded-lg text-white transition-colors cursor-pointer flex items-center justify-center"
                  aria-label="Search hotels"
                >
                  <Search size={20} className="mr-2" />
                  <span>Search</span>
                </button>
              </div>
            </div>
          </form>
        </div>

        {/* Active Filters Section */}
        {activeFilters.length > 0 && (
          <div className="mb-4">
            <div className="flex flex-wrap items-center gap-2">
              <span className="text-sm font-medium">Active Filters:</span>
              {activeFilters.map((filter) => (
                <div
                  key={filter}
                  className="flex items-center bg-purple-100 text-purple-800 px-3 py-1 rounded-full text-sm"
                >
                  {filter}
                  <button
                    onClick={() => removeFilter(filter)}
                    className="ml-1 text-purple-800 hover:text-purple-900"
                  >
                    <X size={14} />
                  </button>
                </div>
              ))}
              <button
                onClick={clearAllFilters}
                className="text-sm text-purple-600 hover:text-purple-800 ml-2"
              >
                Clear All
              </button>
            </div>
          </div>
        )}

        {/* Mobile Filters Button */}
        <div className="md:hidden mb-4">
          <button
            className="flex items-center bg-white border border-gray-300 rounded-full px-4 py-2 text-gray-700"
            onClick={() => setMobileFiltersOpen(!mobileFiltersOpen)}
          >
            <Filter size={16} className="mr-2" />
            Filters
          </button>
        </div>

        {/* Content Grid */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          {/* Filters Section - Desktop */}
          <div
            className={`md:col-span-1 space-y-6 ${
              mobileFiltersOpen ? "block" : "hidden md:block"
            }`}
          >
            {/* Close button for mobile */}
            <div className="md:hidden flex justify-between items-center">
              <h3 className="font-bold text-lg">Filters</h3>
              <button onClick={() => setMobileFiltersOpen(false)}>
                <X size={24} />
              </button>
            </div>

            {/* Hotel Chain Search */}
            <div>
              <label
                htmlFor="hotel-brand"
                className="block text-sm font-medium text-gray-700"
              >
                Hotel Chain
              </label>
              <div className="mt-1 relative">
                <input
                  type="text"
                  id="hotel-brand"
                  placeholder="E.g. Westin"
                  className="w-full rounded-md border border-gray-300 py-2 px-3"
                  value={hotelBrand}
                  onChange={(e) => setHotelBrand(e.target.value)}
                  onBlur={() => {
                    if (hotelBrand) {
                      const hotelFilterLabel = `Hotel: ${hotelBrand}`;
                      setActiveFilters([
                        ...activeFilters.filter((f) => !f.startsWith("Hotel:")),
                        hotelFilterLabel,
                      ]);
                    }
                  }}
                />
              </div>
            </div>

            {/* Star Rating */}
            <div>
              <label className="block text-sm font-medium text-gray-700">
                Star Rating
              </label>
              <div className="flex space-x-2 mt-2">
                {[1, 2, 3, 4, 5].map((star) => (
                  <button
                    key={star}
                    onClick={() => handleStarRatingChange(star)}
                    className={`w-10 h-10 rounded flex items-center justify-center ${
                      starRating === star
                        ? "bg-purple-200 text-purple-600"
                        : "bg-white border border-gray-300"
                    }`}
                    aria-label={`${star} star rating`}
                  >
                    {star} <StarIcon className="w-4 h-4 ml-1" />
                  </button>
                ))}
              </div>
            </div>

            {/* Price Range */}
            <div>
              <label className="block text-sm font-medium text-gray-700">
                Price Per Night
              </label>
              <div className="flex space-x-2 mt-2">
                <div className="relative rounded-md shadow-sm">
                  <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <span className="text-gray-500 sm:text-sm">$</span>
                  </div>
                  <input
                    type="text"
                    className="pl-8 pr-3 py-2 border border-gray-300 rounded-md w-full"
                    placeholder="Min"
                    value={priceMin}
                    onChange={(e) => setPriceMin(e.target.value)}
                    onBlur={handlePriceChange}
                  />
                </div>
                <div className="relative rounded-md shadow-sm">
                  <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <span className="text-gray-500 sm:text-sm">$</span>
                  </div>
                  <input
                    type="text"
                    className="pl-8 pr-3 py-2 border border-gray-300 rounded-md w-full"
                    placeholder="Max"
                    value={priceMax}
                    onChange={(e) => setPriceMax(e.target.value)}
                    onBlur={handlePriceChange}
                  />
                </div>
              </div>
            </div>

            {/* Amenities */}
            <div>
              <label className="block text-sm font-medium text-gray-700">
                Amenities
              </label>
              <div className="mt-2 space-y-2 border border-gray-200 rounded-md p-4">
                {[
                  "Free Wi-Fi",
                  "Free Parking",
                  "Swimming Pool",
                  "Gym",
                  "Spa",
                  "Breakfast",
                  "Airport Shuttle",
                  "Pet Friendly",
                ].map((amenity, index) => (
                  <div key={index} className="flex items-center">
                    <input
                      id={`amenity-${index}`}
                      type="checkbox"
                      className="h-4 w-4 text-purple-600 focus:ring-purple-500 border-gray-300 rounded"
                      checked={amenities.includes(amenity)}
                      onChange={() => handleAmenityChange(amenity)}
                    />
                    <label
                      htmlFor={`amenity-${index}`}
                      className="ml-2 block text-sm text-gray-900"
                    >
                      {amenity}
                    </label>
                  </div>
                ))}
              </div>
            </div>

            {/* Room Capacity Section */}
            <div>
              <label className="block text-sm font-medium text-gray-700">
                Room Capacity
              </label>
              <div className="mt-2 space-y-2">
                {["Single", "Double", "Triple", "Quad", "Family"].map(
                  (capacity, index) => (
                    <div key={index} className="flex items-center">
                      <input
                        id={`capacity-${index}`}
                        type="checkbox"
                        className="h-4 w-4 text-purple-600 focus:ring-purple-500 border-gray-300 rounded"
                      />
                      <label
                        htmlFor={`capacity-${index}`}
                        className="ml-2 block text-sm text-gray-900"
                      >
                        {capacity}
                      </label>
                    </div>
                  )
                )}
              </div>
            </div>

            {/* View Type */}
            <div>
              <label className="block text-sm font-medium text-gray-700">
                View Type
              </label>
              <div className="mt-2 space-y-2">
                {["Sea View", "Mountain View", "City View", "Garden View"].map(
                  (view, index) => (
                    <div key={index} className="flex items-center">
                      <input
                        id={`view-${index}`}
                        type="checkbox"
                        className="h-4 w-4 text-purple-600 focus:ring-purple-500 border-gray-300 rounded"
                      />
                      <label
                        htmlFor={`view-${index}`}
                        className="ml-2 block text-sm text-gray-900"
                      >
                        {view}
                      </label>
                    </div>
                  )
                )}
              </div>
            </div>

            {/* Apply Filters Button - Mobile Only */}
            <div className="md:hidden">
              <button
                onClick={() => {
                  setMobileFiltersOpen(false);
                  handleSubmit(new Event("submit") as any);
                }}
                className="w-full py-3 bg-purple-500 hover:bg-purple-600 rounded-lg text-white transition-colors cursor-pointer"
              >
                Apply Filters
              </button>
            </div>
          </div>

          {/* Results Section */}
          <div className="md:col-span-3">
            {/* Top Filter Bar */}
            <div className="flex flex-col md:flex-row justify-between items-center mb-4 gap-2">
              <div className="text-gray-600 font-medium">
                {getSortedHotels().length} Properties Found
              </div>
              <div className="relative">
                <select
                  value={sortBy}
                  onChange={(e) => setSortBy(e.target.value)}
                  className="block appearance-none w-full bg-white border border-gray-300 text-gray-700 py-2 px-4 pr-8 rounded"
                >
                  <option>Recommended</option>
                  <option>Price: Low to High</option>
                  <option>Price: High to Low</option>
                  <option>Rating: High to Low</option>
                  <option>Availability</option>
                </select>
                <div className="pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-gray-700">
                  <svg
                    className="fill-current h-4 w-4"
                    xmlns="http://www.w3.org/2000/svg"
                    viewBox="0 0 20 20"
                  >
                    <path d="M9.293 12.95l.707.707L15.657 8l-1.414-1.414L10 10.828 5.757 6.586 4.343 8z" />
                  </svg>
                </div>
              </div>
            </div>

            {/* Hotel Cards */}
            {getSortedHotels().length > 0 ? (
              getSortedHotels().map((hotel) => (
                <div
                  key={hotel.id}
                  className="border border-gray-200 rounded-lg mb-8 overflow-hidden shadow-sm hover:shadow-md transition-shadow cursor-pointer"
                  onClick={() => navigateToHotelDetail(hotel.id)}
                >
                  <div className="flex flex-col md:flex-row">
                    {/* Hotel Image */}
                    <div className="relative md:w-1/3 h-48">
                      <img
                        src={hotel.image}
                        alt={hotel.name}
                        className="w-full h-full object-cover"
                      />
                      <button
                        className="absolute top-2 right-2 bg-white p-2 rounded-full"
                        onClick={(e) => {
                          e.stopPropagation(); // Prevent navigating to hotel detail
                          console.log("Added to favorites:", hotel.name);
                        }}
                      >
                        <svg
                          xmlns="http://www.w3.org/2000/svg"
                          className="h-5 w-5"
                          fill="none"
                          viewBox="0 0 24 24"
                          stroke="currentColor"
                        >
                          <path
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            strokeWidth={2}
                            d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"
                          />
                        </svg>
                      </button>
                      {/* Star Rating Badge */}
                      <div className="absolute bottom-2 left-2 bg-black bg-opacity-70 text-white px-2 py-1 rounded text-sm flex items-center">
                        {Array(hotel.starRating)
                          .fill(0)
                          .map((_, i) => (
                            <StarIcon
                              key={i}
                              className="w-4 h-4 text-yellow-400"
                            />
                          ))}
                      </div>
                    </div>

                    {/* Hotel Details */}
                    <div className="p-6 md:w-2/3 flex flex-col justify-between">
                      <div>
                        <div className="flex justify-between">
                          <div>
                            <h3 className="text-xl font-bold">{hotel.name}</h3>
                            <p className="text-gray-600">{hotel.location}</p>
                            <p className="text-sm text-gray-500 mt-1">
                              {hotel.hotelChain}
                            </p>
                          </div>
                          <div className="flex items-center">
                            <div className="bg-green-600 text-white text-xs px-2 py-1 rounded flex items-center">
                              <span className="font-bold mr-1">
                                {hotel.rating}
                              </span>
                              <span>/10</span>
                            </div>
                          </div>
                        </div>

                        {/* Amenities */}
                        <div className="flex flex-wrap gap-2 mt-3">
                          {hotel.amenities.slice(0, 3).map((amenity, index) => (
                            <span
                              key={index}
                              className="bg-gray-100 text-gray-800 text-xs px-2 py-1 rounded"
                            >
                              {amenity}
                            </span>
                          ))}
                          {hotel.amenities.length > 3 && (
                            <span className="bg-gray-100 text-gray-800 text-xs px-2 py-1 rounded">
                              +{hotel.amenities.length - 3} more
                            </span>
                          )}
                        </div>

                        <div className="flex items-center mt-2">
                          {hotel.breakfast && (
                            <div className="flex items-center text-gray-600 text-sm mr-4">
                              <Check
                                size={16}
                                className="text-green-500 mr-1"
                              />
                              <span>Breakfast included</span>
                            </div>
                          )}
                        </div>

                        {hotel.refundable && (
                          <div className="mt-2">
                            <span className="text-green-600 text-sm font-medium">
                              Fully refundable
                            </span>
                          </div>
                        )}

                        <div className="mt-2">
                          <span className="bg-green-100 text-green-800 font-bold px-2 py-1 rounded text-sm">
                            {hotel.ratingText}
                          </span>
                          <span className="text-sm text-gray-500 ml-2">
                            {hotel.reviews} reviews
                          </span>
                        </div>

                        {/* Available Rooms Info */}
                        <div className="mt-2 text-sm">
                          <span className="text-gray-700">
                            <strong>{hotel.availableRooms}</strong> rooms
                            available out of {hotel.roomCount}
                          </span>
                        </div>
                      </div>

                      <div className="flex justify-between items-end mt-4">
                        <button
                          className="bg-purple-100 text-purple-700 px-4 py-2 rounded-lg text-sm font-medium hover:bg-purple-200"
                          onClick={(e) => {
                            e.stopPropagation(); // Prevent navigating to hotel detail
                            console.log("View rooms for:", hotel.name);
                          }}
                        >
                          View Rooms
                        </button>

                        <div className="text-right">
                          {hotel.discount > 0 && (
                            <div className="bg-green-100 text-green-800 text-xs font-bold px-2 py-1 rounded">
                              ${hotel.discount} off
                            </div>
                          )}
                          <div className="mt-1">
                            {hotel.originalPrice > hotel.discountPrice && (
                              <span className="text-gray-500 line-through text-sm">
                                ${hotel.originalPrice}
                              </span>
                            )}
                            <span className="text-xl font-bold ml-2">
                              ${hotel.discountPrice}
                            </span>
                          </div>
                          <div className="text-xs text-gray-500">
                            ${hotel.tax + hotel.discountPrice} total
                          </div>
                          <div className="text-xs text-gray-500">
                            includes taxes & fees
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              ))
            ) : (
              <div className="bg-white p-8 rounded-lg shadow text-center">
                <div className="text-4xl mb-4">🏨</div>
                <h3 className="text-xl font-bold mb-2">
                  No hotels match your filters
                </h3>
                <p className="text-gray-600 mb-4">
                  Try adjusting your search criteria or clearing some filters
                </p>
                <button
                  onClick={clearAllFilters}
                  className="bg-purple-500 hover:bg-purple-600 text-white font-medium py-2 px-4 rounded"
                >
                  Clear All Filters
                </button>
              </div>
            )}
          </div>
        </div>
      </div>
      <Footer />
    </div>
  );
}
