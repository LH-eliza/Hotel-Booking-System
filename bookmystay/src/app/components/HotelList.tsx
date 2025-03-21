"use client";

import React from 'react';
import { Heart } from 'lucide-react';

interface FilterState {
  starRating: number[];
  priceRange: {
    min: string;
    max: string;
  };
  amenities: string[];
  roomCapacity: string[];
  viewType: string[];
}

interface HotelListProps {
  propertiesFound?: number;
  sortOption: string;
  onSortChange: (value: string) => void;
  filterState: FilterState;
}

interface Room {
  hotelId: string;
  chainId: string;
  price: string | number;
  capacity: string;
  isAvailable: boolean;
  amenities?: string[];
  view?: string;
  starCategory: number;
}

const StarDisplay = ({ count }: { count: number }) => (
  <div className="flex items-center gap-2">
    <span className="text-yellow-400">{Array(count).fill('★').join('')}</span>
    <span className="text-sm text-gray-600">({count}-Star)</span>
  </div>
);

const HotelList: React.FC<HotelListProps> = ({
  propertiesFound,
  sortOption,
  onSortChange,
  filterState,
}) => {
  const [rooms, setRooms] = React.useState<Room[]>([]);
  const [loading, setLoading] = React.useState(true);
  const [error, setError] = React.useState<string | null>(null);

  React.useEffect(() => {
    fetchRooms();
  }, [sortOption]);

  const fetchRooms = async () => {
    try {
      setLoading(true);
      const response = await fetch('/api/rooms');
      if (!response.ok) {
        throw new Error('Failed to fetch rooms');
      }
      const data = await response.json();
      const formattedData = data.map((room: Room) => ({
        ...room,
        price: typeof room.price === 'string' ? parseFloat(room.price) : room.price
      }));
      setRooms(formattedData);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
    } finally {
      setLoading(false);
    }
  };

  const formatPrice = (price: string | number): string => {
    const numPrice = typeof price === 'string' ? parseFloat(price) : price;
    return isNaN(numPrice) ? '0.00' : numPrice.toFixed(2);
  };

  const filterRooms = (rooms: Room[]): Room[] => {
    return rooms.filter(room => {
      // Star Rating Filter
      if (filterState.starRating.length > 0 && !filterState.starRating.includes(room.starCategory)) {
        return false;
      }

      // Price Range Filter
      const price = parseFloat(formatPrice(room.price));
      const minPrice = filterState.priceRange.min ? parseFloat(filterState.priceRange.min) : 0;
      const maxPrice = filterState.priceRange.max ? parseFloat(filterState.priceRange.max) : Infinity;
      if (price < minPrice || price > maxPrice) return false;

      // Room Capacity Filter
      if (filterState.roomCapacity.length > 0 && !filterState.roomCapacity.includes(room.capacity)) {
        return false;
      }

      // Amenities Filter
      if (filterState.amenities.length > 0) {
        if (!room.amenities) return false;
        if (!filterState.amenities.every(amenity => room.amenities?.includes(amenity))) {
          return false;
        }
      }

      // View Type Filter
      if (filterState.viewType.length > 0) {
        if (!room.view) return false;
        if (!filterState.viewType.includes(room.view)) {
          return false;
        }
      }

      return true;
    });
  };

  const sortRooms = (rooms: Room[]): Room[] => {
    const sortedRooms = [...rooms];
    switch (sortOption) {
      case 'Price: Low to High':
        return sortedRooms.sort((a, b) => parseFloat(formatPrice(a.price)) - parseFloat(formatPrice(b.price)));
      case 'Price: High to Low':
        return sortedRooms.sort((a, b) => parseFloat(formatPrice(b.price)) - parseFloat(formatPrice(a.price)));
      default:
        return sortedRooms;
    }
  };

  if (loading) {
    return (
      <div className="flex-1 flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-gray-900"></div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex-1 flex items-center justify-center text-red-600">
        Error: {error}
      </div>
    );
  }

  const filteredAndSortedRooms = sortRooms(filterRooms(rooms));

  return (
    <div className="flex-1">
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-xl font-medium">{filteredAndSortedRooms.length} Rooms Found</h2>
        <div className="relative">
          <select
            value={sortOption}
            onChange={(e) => onSortChange(e.target.value)}
            className="appearance-none bg-white border border-gray-300 rounded px-4 py-2 pr-8"
          >
            <option>Recommended</option>
            <option>Price: Low to High</option>
            <option>Price: High to Low</option>
          </select>
          <svg
            className="absolute right-2 top-1/2 transform -translate-y-1/2 pointer-events-none"
            width="16"
            height="16"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
          >
            <path d="m6 9 6 6 6-6"/>
          </svg>
        </div>
      </div>

      {/* Room Cards */}
      <div className="space-y-6">
        {filteredAndSortedRooms.map((room, index) => (
          <div key={`${room.hotelId}-${index}`} className="bg-white rounded-lg shadow-md p-4 hover:shadow-lg transition-shadow">
            <div className="flex justify-between items-start">
              <div className="flex-1">
                <div className="flex justify-between">
                  <div>
                    <h3 className="text-lg font-medium">Chain ID: {room.chainId}</h3>
                    <p className="text-lg font-medium">Hotel ID: {room.hotelId}</p>
                    <div className="mt-1">
                      <StarDisplay count={room.starCategory} />
                    </div>
                    <div className="text-sm text-gray-600 mt-1">Capacity: {room.capacity}</div>
                    {room.view && (
                      <div className="text-sm text-gray-600">View: {room.view}</div>
                    )}
                  </div>
                  <button className="p-2">
                    <Heart className="text-gray-400 hover:text-red-500 transition-colors" />
                  </button>
                </div>
                <div className="mt-4 flex justify-between items-end">
                  <div>
                    <div className="text-sm text-gray-600">
                      Status: {room.isAvailable ? 'Available' : 'Not Available'}
                    </div>
                    {room.amenities && room.amenities.length > 0 && (
                      <div className="text-sm text-gray-600 mt-2">
                        Amenities: {room.amenities.join(', ')}
                      </div>
                    )}
                  </div>
                  <div className="text-right">
                    <div className="text-2xl font-bold text-purple-700">
                      ${formatPrice(room.price)}
                    </div>
                    <div className="text-sm text-gray-600">
                      /night
                    </div>
                    <div className="text-xs text-gray-500">
                      includes taxes & fees
                    </div>
                    <button 
                      className={`mt-2 px-4 py-2 rounded-full text-sm font-medium transition-colors
                        ${room.isAvailable 
                          ? 'bg-purple-100 text-purple-700 hover:bg-purple-200' 
                          : 'bg-gray-100 text-gray-500 cursor-not-allowed'}`}
                      disabled={!room.isAvailable}
                    >
                      {room.isAvailable ? 'Book Now' : 'Not Available'}
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default HotelList; 