// src/pages/index.tsx
import Head from "next/head";
import Image from "next/image";
import { useState, ChangeEvent } from "react";
import { Search } from "lucide-react";
import Header from "../components/header";
import Footer from "../components/footer";

const Home: React.FC = () => {
  const [checkInOut, setCheckInOut] = useState<string>("");
  const [hotel, setHotel] = useState<string>("");
  const [destination, setDestination] = useState<string>("");
  const [guests, setGuests] = useState<string>("");

  const handleCheckInOutChange = (e: ChangeEvent<HTMLInputElement>): void => {
    setCheckInOut(e.target.value);
  };

  const handleHotelChange = (e: ChangeEvent<HTMLInputElement>): void => {
    setHotel(e.target.value);
  };

  const handleDestinationChange = (e: ChangeEvent<HTMLInputElement>): void => {
    setDestination(e.target.value);
  };

  const handleGuestsChange = (e: ChangeEvent<HTMLInputElement>): void => {
    setGuests(e.target.value);
  };

  return (
    <div className="min-h-screen flex flex-col">
      <Head>
        <title>BookMyStay - Find the best stay for you</title>
        <meta
          name="description"
          content="Find your perfect getaway in seconds with our smart hotel finder"
        />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <Header />

      <main className="flex-1">
        {/* Hero Section */}
        <section className="max-w-4xl mx-auto text-center py-16 px-4">
          <h1 className="text-4xl font-medium text-gray-800 mb-4">
            Find the <span className="text-red-400">best stay</span> for you.
          </h1>
          <p className="text-gray-600 max-w-2xl mx-auto">
            Find your perfect getaway in seconds with our smart hotel finder
            that matches your preferences with the best accommodations at
            unbeatable prices worldwide.
          </p>

          {/* Search Box */}
          <div className="mt-10 bg-white p-6 rounded-lg shadow-sm border">
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
              <div className="relative">
                <div className="text-xs text-gray-500 mb-1">DATES</div>
                <input
                  type="text"
                  placeholder="Check-in | Check-out"
                  className="w-full border rounded p-2 text-gray-800"
                  value={checkInOut}
                  onChange={handleCheckInOutChange}
                />
              </div>
              <div className="relative">
                <div className="text-xs text-gray-500 mb-1">HOTEL NAME</div>
                <input
                  type="text"
                  placeholder="E.g. Westin"
                  className="w-full border rounded p-2 text-gray-800"
                  value={hotel}
                  onChange={handleHotelChange}
                />
              </div>
              <div className="relative">
                <div className="text-xs text-gray-500 mb-1">DESTINATION</div>
                <input
                  type="text"
                  placeholder="Where to?"
                  className="w-full border rounded p-2 text-gray-800"
                  value={destination}
                  onChange={handleDestinationChange}
                />
              </div>
              <div className="flex items-end space-x-2">
                <div className="flex-1">
                  <div className="text-xs text-gray-500 mb-1">ROOM/GUESTS</div>
                  <input
                    type="text"
                    placeholder="How many people?"
                    className="w-full border rounded p-2 text-gray-800"
                    value={guests}
                    onChange={handleGuestsChange}
                  />
                </div>
                <button className="bg-red-400 hover:bg-red-500 text-white p-2 rounded-full h-10 w-10 flex items-center justify-center">
                  <Search size={20} />
                </button>
              </div>
            </div>
          </div>
        </section>

        {/* Popular Destinations */}
        <section className="max-w-5xl mx-auto mb-12 px-4">
          <div className="bg-white rounded-lg p-6 shadow-sm border">
            <h2 className="text-xl font-medium text-gray-800 mb-6">
              Explore Popular Destinations
            </h2>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              {[1, 2, 3].map((item) => (
                <div
                  key={item}
                  className="bg-gray-200 rounded-lg h-32 md:h-40"
                ></div>
              ))}
            </div>

            <div className="flex justify-center mt-6 space-x-1">
              {[1, 2, 3].map((item) => (
                <div
                  key={item}
                  className={`h-2 w-2 rounded-full ${
                    item === 1 ? "bg-red-400" : "bg-gray-300"
                  }`}
                ></div>
              ))}
            </div>
          </div>
        </section>

        {/* Favorite Ways to Stay */}
        <section className="max-w-5xl mx-auto mb-24 px-4">
          <div className="bg-white rounded-lg p-6 shadow-sm border">
            <h2 className="text-xl font-medium text-gray-800 mb-6">
              Discover new favourite ways to stay
            </h2>
            <div className="relative">
              <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
                {[1, 2, 3, 4].map((item) => (
                  <div
                    key={item}
                    className="bg-gray-200 rounded-lg h-32 md:h-40"
                  ></div>
                ))}
              </div>

              <button className="absolute left-0 top-1/2 transform -translate-y-1/2 -ml-4 bg-white rounded-full p-2 shadow">
                <svg
                  width="24"
                  height="24"
                  viewBox="0 0 24 24"
                  fill="none"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    d="M15 19l-7-7 7-7"
                    stroke="#000"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                </svg>
              </button>
              <button className="absolute right-0 top-1/2 transform -translate-y-1/2 -mr-4 bg-white rounded-full p-2 shadow">
                <svg
                  width="24"
                  height="24"
                  viewBox="0 0 24 24"
                  fill="none"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    d="M9 5l7 7-7 7"
                    stroke="#000"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                </svg>
              </button>
            </div>
          </div>
        </section>
      </main>

      <Footer />
    </div>
  );
};

export default Home;
