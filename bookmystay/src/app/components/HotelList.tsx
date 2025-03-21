import React from 'react';
import { Heart } from 'lucide-react';

interface HotelListProps {
  propertiesFound: number;
  sortOption: string;
  onSortChange: (value: string) => void;
}

const HotelList: React.FC<HotelListProps> = ({
  propertiesFound,
  sortOption,
  onSortChange,
}) => {
  return (
    <div className="flex-1">
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-xl font-medium">{propertiesFound} Properties Found</h2>
        <div className="relative">
          <select
            value={sortOption}
            onChange={(e) => onSortChange(e.target.value)}
            className="appearance-none bg-white border border-gray-300 rounded px-4 py-2 pr-8"
          >
            <option>Recommended</option>
            <option>Price: Low to High</option>
            <option>Price: High to Low</option>
            <option>Rating: High to Low</option>
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

      {/* Hotel Cards */}
      <div className="space-y-6">
        {[1, 2, 3].map((hotel) => (
          <div key={hotel} className="bg-white rounded-lg shadow-md p-4">
            <div className="flex justify-between items-start">
              <div className="flex-1">
                <div className="flex justify-between">
                  <div>
                    <h3 className="text-lg font-medium">Hotel Name</h3>
                    <div className="text-sm text-gray-600">Location</div>
                  </div>
                  <button className="p-2">
                    <Heart className="text-gray-400" />
                  </button>
                </div>
                <div className="mt-4 flex justify-between items-end">
                  <div>
                    <div className="text-sm text-gray-600">
                      {Math.floor(Math.random() * 5)} reviews
                    </div>
                    <div className="text-sm text-gray-600">
                      {Math.floor(Math.random() * 10)} rooms available
                    </div>
                  </div>
                  <div className="text-right">
                    <div className="text-2xl font-bold">
                      ${Math.floor(Math.random() * 500)}
                    </div>
                    <div className="text-sm text-gray-600">
                      /night total
                    </div>
                    <div className="text-xs text-gray-500">
                      includes taxes & fees
                    </div>
                    <button className="mt-2 bg-purple-100 text-purple-700 px-4 py-2 rounded-full text-sm font-medium">
                      View Rooms
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