'use client';

import React, { useState, useEffect, Suspense } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { Search, ChevronDown } from 'lucide-react';
import SimpleDatePicker from '../components/datepicker';
import Header from '../components/header';
import Footer from '../components/footer';
import HotelList from '../components/HotelList';

interface DateRange {
  startDate: string;
  endDate: string;
}

interface SearchFormData {
  dates: DateRange | null;
  hotel: string;
  destination: string;
  capacity: string;
}

interface FilterState {
  starRating: number[];
  priceRange: {
    min: string;
    max: string;
  };
  amenities: string[];
  roomCapacity: string[];
  viewType: string[];
  destination: string;
  hotelChain: string;
}

export default function HotelBookingPage(): React.ReactElement {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [destinations, setDestinations] = useState([]);
  const [hotels, setHotels] = useState([]);
  const [roomCapacity, setRoomCapacity] = useState([]);
  const [amenities, setAmenities] = useState([]);
  const [viewTypes, setViewTypes] = useState([]);
  const [error, setError] = useState('');

  useEffect(() => {
    fetchNeighborhoods();
    fetchHotelChainID();
    fetchRoomCapacity();
    fetchAmenities();
    fetchViewTypes();
    console.log(error);
  }, []);

  // Update the form data effect to also update filter state
  useEffect(() => {
    const startDate = searchParams.get('startDate') || undefined;
    const endDate = searchParams.get('endDate') || undefined;
    const hotel = searchParams.get('hotel') || undefined;
    const destination = searchParams.get('destination') || undefined;
    const capacity = searchParams.get('capacity') || undefined;

    if (startDate && endDate) {
      setFormData(prev => ({
        ...prev,
        dates: {
          startDate,
          endDate,
        },
      }));
    }
    if (hotel) {
      setFormData(prev => ({ ...prev, hotel }));
      setFilterState(prev => ({ ...prev, hotelChain: hotel }));
    }
    if (destination) {
      setFormData(prev => ({ ...prev, destination }));
      setFilterState(prev => ({ ...prev, destination }));
    }
    if (capacity) {
      setFormData(prev => ({ ...prev, capacity }));
      setFilterState(prev => ({ ...prev, roomCapacity: [capacity] }));
    }
  }, [searchParams]);

  const fetchNeighborhoods = async () => {
    try {
      const response = await fetch('/api/destinations');
      if (response.ok) {
        const data = await response.json();
        setDestinations(data);
      } else {
        throw new Error('Failed to fetch destinations');
      }
    } catch (error) {
      if (error instanceof Error) {
        console.log(error.message);
        setError(error.message);
      } else {
        setError('An unknown error occurred');
      }
    }
  };

  const fetchHotelChainID = async () => {
    try {
      const response = await fetch('/api/hotel_chain');
      if (response.ok) {
        const data = await response.json();
        setHotels(data);
      } else {
        throw new Error('Failed to fetch hotel ids');
      }
    } catch (error) {
      if (error instanceof Error) {
        console.log(error.message);
        setError(error.message);
      } else {
        setError('An unknown error occurred');
      }
    }
  };

  const fetchRoomCapacity = async () => {
    try {
      const response = await fetch('/api/room_capacity');
      if (response.ok) {
        const data = await response.json();
        setRoomCapacity(data);
      } else {
        throw new Error('Failed to fetch rooms');
      }
    } catch (error) {
      if (error instanceof Error) {
        console.log(error.message);
        setError(error.message);
      } else {
        setError('An unknown error occurred');
      }
    }
  };

  const fetchAmenities = async () => {
    try {
      const response = await fetch('/api/room_amenity');
      if (response.ok) {
        const data = await response.json();
        setAmenities(data);
      } else {
        throw new Error('Failed to fetch amenities');
      }
    } catch (error) {
      if (error instanceof Error) {
        console.log(error.message);
        setError(error.message);
      } else {
        setError('An unknown error occurred');
      }
    }
  };

  const fetchViewTypes = async () => {
    try {
      const response = await fetch('/api/rooms');
      if (response.ok) {
        const data = await response.json();
        setViewTypes(data.viewTypes);
      } else {
        throw new Error('Failed to fetch view types');
      }
    } catch (error) {
      if (error instanceof Error) {
        console.log(error.message);
        setError(error.message);
      } else {
        setError('An unknown error occurred');
      }
    }
  };

  const [formData, setFormData] = useState<SearchFormData>({
    dates: null,
    hotel: '',
    destination: '',
    capacity: '',
  });

  const [openDropdown, setOpenDropdown] = useState<string | null>(null);

  const handleDateSelect = (dateRange: DateRange): void => {
    setFormData(prev => ({
      ...prev,
      dates: dateRange,
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
    toggleDropdown('dates');
  };

  const selectOption = (name: 'hotel' | 'destination' | 'capacity', value: string): void => {
    setFormData(prev => ({
      ...prev,
      [name]: value,
    }));
    setOpenDropdown(null);

    // Update filter state when selecting options
    if (name === 'destination') {
      setFilterState(prev => ({ ...prev, destination: value }));
    }
    if (name === 'hotel') {
      setFilterState(prev => ({ ...prev, hotelChain: value }));
    }
    if (name === 'capacity') {
      setFilterState(prev => ({ ...prev, roomCapacity: [value] }));
    }
  };

  const handleSubmit = (e: React.FormEvent): void => {
    e.preventDefault();
    const query = new URLSearchParams({
      startDate: formData.dates?.startDate || '',
      endDate: formData.dates?.endDate || '',
      hotel: formData.hotel || '',
      destination: formData.destination || '',
      capacity: formData.capacity || '',
    }).toString();

    router.push(`/booking?${query}`);
  };

  const [filterState, setFilterState] = useState<FilterState>({
    starRating: [],
    priceRange: {
      min: '',
      max: '',
    },
    amenities: [],
    roomCapacity: [],
    viewType: [],
    destination: '',
    hotelChain: '',
  });

  const [sortOption, setSortOption] = useState('Recommended');

  const handleSortChange = (value: string) => {
    setSortOption(value);
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
                <label htmlFor="dates" className="block text-xs text-gray-500 mb-1">
                  DATES
                </label>
                <div
                  className="flex items-center justify-between cursor-pointer"
                  onClick={() => toggleDateDropdown()}
                >
                  <SimpleDatePicker
                    onDateChange={handleDateSelect}
                    initialDateRange={formData.dates || undefined}
                  />
                  <ChevronDown
                    size={16}
                    className={`ml-2 transition-transform duration-200 ${
                      openDropdown === 'dates' ? 'transform rotate-180' : ''
                    }`}
                  />
                </div>
              </div>

              <div className="flex-1 px-3 border-l border-gray-200">
                <label className="block text-xs text-gray-500 mb-1">HOTEL CHAIN</label>
                <div className="relative">
                  <button
                    type="button"
                    className="w-full text-left text-sm flex items-center justify-between focus:outline-none cursor-pointer"
                    onClick={() => toggleDropdown('hotel')}
                  >
                    <span>{formData.hotel || 'Select hotel'}</span>
                    <ChevronDown
                      size={16}
                      className={`ml-2 transition-transform duration-200 ${
                        openDropdown === 'hotel' ? 'transform rotate-180' : ''
                      }`}
                    />
                  </button>

                  {openDropdown === 'hotel' && (
                    <div className="absolute top-full left-0 right-0 mt-1 bg-white shadow-lg rounded-lg py-1 z-10 max-h-48 overflow-y-auto">
                      {hotels.map(hotel => (
                        <div
                          key={hotel}
                          className="px-4 py-2 hover:bg-gray-100 cursor-pointer text-sm"
                          onClick={() => selectOption('hotel', hotel)}
                        >
                          {hotel}
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              </div>

              <div className="flex-1 px-3 border-l border-gray-200">
                <label className="block text-xs text-gray-500 mb-1">NEIGHBOURHOOD</label>
                <div className="relative">
                  <button
                    type="button"
                    className="w-full text-left text-sm flex items-center justify-between focus:outline-none cursor-pointer"
                    onClick={() => toggleDropdown('destination')}
                  >
                    <span>{formData.destination || 'Where to?'}</span>
                    <ChevronDown
                      size={16}
                      className={`ml-2 transition-transform duration-200 ${
                        openDropdown === 'destination' ? 'transform rotate-180' : ''
                      }`}
                    />
                  </button>

                  {openDropdown === 'destination' && (
                    <div className="absolute top-full left-0 right-0 mt-1 bg-white shadow-lg rounded-lg py-1 z-10 max-h-48 overflow-y-auto">
                      {destinations.map(destination => (
                        <div
                          key={destination}
                          className="px-4 py-2 hover:bg-gray-100 cursor-pointer text-sm"
                          onClick={() => selectOption('destination', destination)}
                        >
                          {destination}
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              </div>

              <div className="flex-1 px-3 border-l border-gray-200">
                <label className="block text-xs text-gray-500 mb-1">CAPACITY</label>
                <div className="relative">
                  <button
                    type="button"
                    className="w-full text-left text-sm flex items-center justify-between focus:outline-none cursor-pointer"
                    onClick={() => toggleDropdown('capacity')}
                  >
                    <span>{formData.capacity || 'Select Capacity'}</span>
                    <ChevronDown
                      size={16}
                      className={`ml-2 transition-transform duration-200 ${
                        openDropdown === 'capacity' ? 'transform rotate-180' : ''
                      }`}
                    />
                  </button>

                  {openDropdown === 'capacity' && (
                    <div className="absolute top-full left-0 right-0 mt-1 bg-white shadow-lg rounded-lg py-1 z-10 max-h-48 overflow-y-auto">
                      {roomCapacity.map(capacity => (
                        <div
                          key={capacity}
                          className="px-4 py-2 hover:bg-gray-100 cursor-pointer text-sm"
                          onClick={() => selectOption('capacity', capacity)}
                        >
                          {capacity}
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              </div>

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
                  <label className="block text-xs text-gray-500 mb-1">DATES</label>
                  <div
                    className="flex items-center justify-between border border-gray-200 rounded px-3 py-2 cursor-pointer"
                    onClick={() => toggleDropdown('dates-mobile')}
                  >
                    <SimpleDatePicker
                      onDateChange={handleDateSelect}
                      initialDateRange={formData.dates || undefined}
                    />
                    <ChevronDown
                      size={16}
                      className={`ml-2 transition-transform duration-200 ${
                        openDropdown === 'dates-mobile' ? 'transform rotate-180' : ''
                      }`}
                    />
                  </div>
                </div>

                <div className="mb-4">
                  <label className="block text-xs text-gray-500 mb-1">HOTEL CHAIN</label>
                  <div className="relative">
                    <button
                      type="button"
                      className="w-full text-left text-sm py-2 border border-gray-200 rounded px-3 flex items-center justify-between focus:outline-none"
                      onClick={() => toggleDropdown('hotel-mobile')}
                    >
                      <span>{formData.hotel || 'Select hotel'}</span>
                      <ChevronDown
                        size={16}
                        className={`ml-2 transition-transform duration-200 ${
                          openDropdown === 'hotel-mobile' ? 'transform rotate-180' : ''
                        }`}
                      />
                    </button>

                    {openDropdown === 'hotel-mobile' && (
                      <div className="absolute top-full left-0 right-0 mt-1 bg-white shadow-lg rounded-lg py-1 z-10 max-h-48 overflow-y-auto">
                        {hotels.map(hotel => (
                          <div
                            key={hotel}
                            className="px-4 py-2 hover:bg-gray-100 cursor-pointer text-sm"
                            onClick={() => selectOption('hotel', hotel)}
                          >
                            {hotel}
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                </div>

                <div className="mb-4">
                  <label className="block text-xs text-gray-500 mb-1">DESTINATION</label>
                  <div className="relative">
                    <button
                      type="button"
                      className="w-full text-left text-sm py-2 border border-gray-200 rounded px-3 flex items-center justify-between focus:outline-none"
                      onClick={() => toggleDropdown('destination-mobile')}
                    >
                      <span>{formData.destination || 'Where to?'}</span>
                      <ChevronDown
                        size={16}
                        className={`ml-2 transition-transform duration-200 ${
                          openDropdown === 'destination-mobile' ? 'transform rotate-180' : ''
                        }`}
                      />
                    </button>

                    {openDropdown === 'destination-mobile' && (
                      <div className="absolute top-full left-0 right-0 mt-1 bg-white shadow-lg rounded-lg py-1 z-10 max-h-48 overflow-y-auto">
                        {destinations.map(destination => (
                          <div
                            key={destination}
                            className="px-4 py-2 hover:bg-gray-100 cursor-pointer text-sm"
                            onClick={() => selectOption('destination', destination)}
                          >
                            {destination}
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                </div>

                <div className="mb-4">
                  <label className="block text-xs text-gray-500 mb-1">CAPACITY</label>
                  <div className="relative">
                    <button
                      type="button"
                      className="w-full text-left text-sm py-2 border border-gray-200 rounded px-3 flex items-center justify-between focus:outline-none"
                      onClick={() => toggleDropdown('capacity-mobile')}
                    >
                      <span>{formData.capacity || 'Select Capacity'}</span>
                      <ChevronDown
                        size={16}
                        className={`ml-2 transition-transform duration-200 ${
                          openDropdown === 'capacity-mobile' ? 'transform rotate-180' : ''
                        }`}
                      />
                    </button>

                    {openDropdown === 'capacity-mobile' && (
                      <div className="absolute top-full left-0 right-0 mt-1 bg-white shadow-lg rounded-lg py-1 z-10 max-h-48 overflow-y-auto">
                        {roomCapacity.map(capacity => (
                          <div
                            key={capacity}
                            className="px-4 py-2 hover:bg-gray-100 cursor-pointer text-sm"
                            onClick={() => selectOption('capacity', capacity)}
                          >
                            {capacity}
                          </div>
                        ))}
                      </div>
                    )}
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

        {/* Main Content */}
        <div className="flex flex-col md:flex-row gap-8 mt-8">
          {/* Filters Section */}
          <div className="w-full md:w-1/4">
            {/* Hotel Chain Filter */}
            <div className="mb-6">
              <h3 className="text-lg font-medium mb-3">Hotel Chain</h3>
              <input
                type="text"
                placeholder="E.g. CH001"
                className="w-full p-2 border border-gray-300 rounded"
              />
            </div>

            {/* Star Rating Filter */}
            <div className="mb-6">
              <h3 className="text-lg font-medium mb-3">Star Rating</h3>
              <div className="flex flex-wrap gap-2">
                {[1, 2, 3, 4, 5].map(stars => (
                  <button
                    key={stars}
                    className={`px-4 py-2 border rounded ${
                      filterState.starRating.includes(stars)
                        ? 'bg-purple-500 text-white'
                        : 'border-gray-300'
                    }`}
                    onClick={() => {
                      const newStarRating = filterState.starRating.includes(stars)
                        ? filterState.starRating.filter(s => s !== stars)
                        : [...filterState.starRating, stars];
                      setFilterState({ ...filterState, starRating: newStarRating });
                    }}
                  >
                    {stars} ★
                  </button>
                ))}
              </div>
            </div>

            {/* Price Per Night Filter */}
            <div className="mb-6">
              <h3 className="text-lg font-medium mb-3">Price Per Night</h3>
              <div className="flex gap-2">
                <div className="flex-1">
                  <div className="relative">
                    <span className="absolute left-3 top-2">$</span>
                    <input
                      type="number"
                      placeholder="Min"
                      className="w-full pl-7 p-2 border border-gray-300 rounded"
                      value={filterState.priceRange.min}
                      onChange={e =>
                        setFilterState({
                          ...filterState,
                          priceRange: { ...filterState.priceRange, min: e.target.value },
                        })
                      }
                    />
                  </div>
                </div>
                <div className="flex-1">
                  <div className="relative">
                    <span className="absolute left-3 top-2">$</span>
                    <input
                      type="number"
                      placeholder="Max"
                      className="w-full pl-7 p-2 border border-gray-300 rounded"
                      value={filterState.priceRange.max}
                      onChange={e =>
                        setFilterState({
                          ...filterState,
                          priceRange: { ...filterState.priceRange, max: e.target.value },
                        })
                      }
                    />
                  </div>
                </div>
              </div>
            </div>

            {/* Amenities Filter */}
            <div className="mb-6">
              <h3 className="text-lg font-medium mb-3">Amenities</h3>
              <div className="space-y-2">
                {amenities.map(amenity => (
                  <label key={amenity} className="flex items-center">
                    <input
                      type="checkbox"
                      className="mr-2"
                      checked={filterState.amenities.includes(amenity)}
                      onChange={() => {
                        const newAmenities = filterState.amenities.includes(amenity)
                          ? filterState.amenities.filter(a => a !== amenity)
                          : [...filterState.amenities, amenity];
                        setFilterState({ ...filterState, amenities: newAmenities });
                      }}
                    />
                    {amenity}
                  </label>
                ))}
              </div>
            </div>

            {/* Room Capacity Filter */}
            <div className="mb-6">
              <h3 className="text-lg font-medium mb-3">Room Capacity</h3>
              <div className="space-y-2">
                {roomCapacity.map(capacity => (
                  <label key={capacity} className="flex items-center">
                    <input
                      type="checkbox"
                      className="mr-2"
                      checked={filterState.roomCapacity.includes(capacity)}
                      onChange={() => {
                        const newCapacity = filterState.roomCapacity.includes(capacity)
                          ? filterState.roomCapacity.filter(c => c !== capacity)
                          : [...filterState.roomCapacity, capacity];
                        setFilterState({ ...filterState, roomCapacity: newCapacity });
                      }}
                    />
                    {capacity}
                  </label>
                ))}
              </div>
            </div>

            {/* View Type Filter */}
            <div className="mb-6">
              <h3 className="text-lg font-medium mb-3">View Type</h3>
              <div className="space-y-2">
                {viewTypes.map(view => (
                  <label key={view} className="flex items-center">
                    <input
                      type="checkbox"
                      className="mr-2"
                      checked={filterState.viewType.includes(view)}
                      onChange={() => {
                        const newViewTypes = filterState.viewType.includes(view)
                          ? filterState.viewType.filter(v => v !== view)
                          : [...filterState.viewType, view];
                        setFilterState({ ...filterState, viewType: newViewTypes });
                      }}
                    />
                    {view}
                  </label>
                ))}
              </div>
            </div>
          </div>

          {/* Hotels List Section */}
          <Suspense fallback={<div>Loading hotels...</div>}>
            <HotelList
              sortOption={sortOption}
              onSortChange={handleSortChange}
              filterState={filterState}
            />
          </Suspense>
        </div>
      </div>
      <Footer />
    </div>
  );
}
