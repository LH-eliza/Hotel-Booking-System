import React from "react";
import Image from "next/image";

const HotelBackground: React.FC = () => {
  return (
    <div className="flex w-full max-w-6xl m-20 mx-auto rounded-xl overflow-hidden bg-white shadow-lg border-19 border-[#A7AACC]">
      {/* Left side - Ocean Image */}
      <div className="w-1/2 relative h-120">
        <Image
          src="/ocean.png"
          alt="Serene ocean view"
          fill
          style={{ objectFit: "cover" }}
          priority
        />
      </div>

      {/* Right side - Text Content */}
      <div className="w-1/2 p-16 flex flex-col justify-center">
        <div>
          <h1 className="text-5xl font-semibold text-gray-700 mb-2">
            Find the
            <span className="text-[#A7AACC]"> best stay</span> for you.
          </h1>
          <p className="text-gray-600 mt-6">
            Find your perfect getaway in seconds with our smart hotel finder
            that matches your preferences with the best accommodations at
            unbeatable prices worldwide.
          </p>
        </div>
      </div>
    </div>
  );
};

export default HotelBackground;
