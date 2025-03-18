"use client";

import React, { useState } from "react";
import Link from "next/link";
import Head from "next/head";
import {
  Search,
  Hotel,
  Users,
  User,
  DollarSign,
  Calendar,
  FileText,
  BookOpen,
  Settings,
  Database,
  Edit,
  Trash2,
} from "lucide-react";

interface HotelChain {
  id: number;
  name: string;
  hotels: number;
  address: string;
  email: string;
  phone: string;
}

interface Hotel {
  id: number;
  name: string;
  chain: string;
  category: string;
  rooms: number;
  address: string;
  email: string;
  phone: string;
}

interface Room {
  id: number;
  hotelId: number;
  number: string;
  price: number;
  capacity: string;
  amenities: string;
  view: string;
  extendable: boolean;
  issues: string;
}

interface Customer {
  id: number;
  name: string;
  address: string;
  idType: string;
  idNumber: string;
  regDate: string;
}

interface Employee {
  id: number;
  name: string;
  address: string;
  ssn: string;
  hotel: string;
  position: string;
}

interface Booking {
  id: number;
  customerId: number;
  roomId: number;
  startDate: string;
  endDate: string;
  status: string;
}

interface Renting {
  id: number;
  bookingId: number;
  employeeId: number;
  checkInDate: string;
  status: string;
  paymentStatus: string;
}

interface AreaRooms {
  area: string;
  available: number;
}

interface HotelCapacity {
  hotel: string;
  totalCapacity: number;
}

const mockHotelChains: HotelChain[] = [
  {
    id: 1,
    name: "Luxury Stays",
    hotels: 12,
    address: "123 Corporate Ave, New York, NY",
    email: "info@luxurystays.com",
    phone: "212-555-1234",
  },
  {
    id: 2,
    name: "ComfortInn Group",
    hotels: 15,
    address: "456 Business Blvd, Chicago, IL",
    email: "contact@comfortinn.com",
    phone: "312-555-6789",
  },
  {
    id: 3,
    name: "Royal Lodging",
    hotels: 10,
    address: "789 Executive Dr, Los Angeles, CA",
    email: "support@royallodging.com",
    phone: "213-555-4321",
  },
  {
    id: 4,
    name: "Grand Hotels",
    hotels: 8,
    address: "101 Plaza Ave, Miami, FL",
    email: "info@grandhotels.com",
    phone: "305-555-8765",
  },
  {
    id: 5,
    name: "Urban Retreats",
    hotels: 9,
    address: "567 City Rd, Seattle, WA",
    email: "contact@urbanretreats.com",
    phone: "206-555-9876",
  },
];

const mockHotels: Hotel[] = [
  {
    id: 101,
    name: "Luxury Stays Downtown",
    chain: "Luxury Stays",
    category: "5-star",
    rooms: 120,
    address: "789 Main St, New York, NY",
    email: "downtown@luxurystays.com",
    phone: "212-555-2345",
  },
  {
    id: 102,
    name: "Luxury Stays Central Park",
    chain: "Luxury Stays",
    category: "4-star",
    rooms: 95,
    address: "456 Park Ave, New York, NY",
    email: "centralpark@luxurystays.com",
    phone: "212-555-3456",
  },
  {
    id: 201,
    name: "ComfortInn Lakeview",
    chain: "ComfortInn Group",
    category: "3-star",
    rooms: 85,
    address: "123 Lake Dr, Chicago, IL",
    email: "lakeview@comfortinn.com",
    phone: "312-555-7890",
  },
];

const mockRooms: Room[] = [
  {
    id: 10101,
    hotelId: 101,
    number: "101",
    price: 350,
    capacity: "double",
    amenities: "TV, AC, fridge, wifi",
    view: "sea",
    extendable: true,
    issues: "None",
  },
  {
    id: 10102,
    hotelId: 101,
    number: "102",
    price: 275,
    capacity: "single",
    amenities: "TV, AC, wifi",
    view: "city",
    extendable: false,
    issues: "None",
  },
  {
    id: 10103,
    hotelId: 101,
    number: "103",
    price: 400,
    capacity: "double",
    amenities: "TV, AC, fridge, minibar, wifi",
    view: "sea",
    extendable: true,
    issues: "Minor plumbing issue",
  },
];

const mockCustomers: Customer[] = [
  {
    id: 1001,
    name: "John Smith",
    address: "123 Maple St, Boston, MA",
    idType: "SSN",
    idNumber: "XXX-XX-1234",
    regDate: "2024-01-15",
  },
  {
    id: 1002,
    name: "Emily Johnson",
    address: "456 Oak Ave, Miami, FL",
    idType: "Driving License",
    idNumber: "FL12345678",
    regDate: "2024-02-10",
  },
];

const mockEmployees: Employee[] = [
  {
    id: 2001,
    name: "Michael Brown",
    address: "789 Pine Rd, New York, NY",
    ssn: "XXX-XX-5678",
    hotel: "Luxury Stays Downtown",
    position: "Manager",
  },
  {
    id: 2002,
    name: "Sarah Davis",
    address: "321 Cedar St, New York, NY",
    ssn: "XXX-XX-8765",
    hotel: "Luxury Stays Downtown",
    position: "Receptionist",
  },
];

const mockBookings: Booking[] = [
  {
    id: 3001,
    customerId: 1001,
    roomId: 10101,
    startDate: "2025-04-01",
    endDate: "2025-04-05",
    status: "Confirmed",
  },
  {
    id: 3002,
    customerId: 1002,
    roomId: 10103,
    startDate: "2025-03-25",
    endDate: "2025-03-30",
    status: "Confirmed",
  },
];

const mockRentings: Renting[] = [
  {
    id: 4001,
    bookingId: 3001,
    employeeId: 2002,
    checkInDate: "2025-04-01",
    status: "Checked In",
    paymentStatus: "Paid",
  },
];

// Available rooms data for View 1
const mockAvailableRooms: AreaRooms[] = [
  { area: "New York, NY", available: 45 },
  { area: "Chicago, IL", available: 32 },
  { area: "Los Angeles, CA", available: 27 },
  { area: "Miami, FL", available: 38 },
  { area: "Seattle, WA", available: 22 },
];

// Room capacity data for View 2
const mockRoomCapacity: HotelCapacity[] = [
  { hotel: "Luxury Stays Downtown", totalCapacity: 240 },
  { hotel: "Luxury Stays Central Park", totalCapacity: 185 },
  { hotel: "ComfortInn Lakeview", totalCapacity: 150 },
];

const AdminDashboard: React.FC = () => {
  const [activeTab, setActiveTab] = useState<string>("hotelchains");
  const [showAddModal, setShowAddModal] = useState<boolean>(false);
  const [showBookingModal, setShowBookingModal] = useState<boolean>(false);
  const [modalType, setModalType] = useState<string>("");

  const openAddModal = (type: string) => {
    setModalType(type);
    setShowAddModal(true);
  };

  const openBookingModal = (type: string) => {
    setModalType(type);
    setShowBookingModal(true);
  };

  return (
    <>
      <Head>
        <title>e-Hotels Admin Dashboard</title>
        <meta
          name="description"
          content="Admin dashboard for e-Hotels system"
        />
      </Head>

      <div className="flex flex-col h-screen bg-gray-100">
        {/* Header */}
        <header className="bg-blue-700 text-white p-4 shadow-md">
          <div className="flex justify-between items-center">
            <h1 className="text-2xl font-bold">e-Hotels Admin Dashboard</h1>
            <div className="flex items-center space-x-4">
              <div className="relative">
                <input
                  type="text"
                  placeholder="Search..."
                  className="bg-blue-600 text-white placeholder-blue-300 border border-blue-500 rounded-md px-4 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                />
                <Search className="absolute right-3 top-2.5 h-5 w-5 text-blue-300" />
              </div>
              <div className="flex items-center">
                <div className="w-8 h-8 rounded-full bg-blue-500 flex items-center justify-center text-white font-bold">
                  A
                </div>
                <span className="ml-2">Admin</span>
              </div>
            </div>
          </div>
        </header>

        {/* Main Content */}
        <div className="flex flex-1 overflow-hidden">
          {/* Sidebar */}
          <div className="w-64 bg-white shadow-md">
            <nav className="mt-5">
              <ul>
                <li className="px-6 py-3 bg-blue-50 text-blue-600 border-l-4 border-blue-600 font-medium">
                  <Link href="#" className="flex items-center">
                    <Database className="h-5 w-5 mr-3" />
                    <span>Dashboard</span>
                  </Link>
                </li>
                <li className="px-6 py-3 hover:bg-gray-100">
                  <Link
                    href="#"
                    className="flex items-center"
                    onClick={() => setActiveTab("hotelchains")}
                  >
                    <Hotel className="h-5 w-5 mr-3" />
                    <span>Hotel Chains</span>
                  </Link>
                </li>
                <li className="px-6 py-3 hover:bg-gray-100">
                  <Link
                    href="#"
                    className="flex items-center"
                    onClick={() => setActiveTab("hotels")}
                  >
                    <Hotel className="h-5 w-5 mr-3" />
                    <span>Hotels</span>
                  </Link>
                </li>
                <li className="px-6 py-3 hover:bg-gray-100">
                  <Link
                    href="#"
                    className="flex items-center"
                    onClick={() => setActiveTab("rooms")}
                  >
                    <DollarSign className="h-5 w-5 mr-3" />
                    <span>Rooms</span>
                  </Link>
                </li>
                <li className="px-6 py-3 hover:bg-gray-100">
                  <Link
                    href="#"
                    className="flex items-center"
                    onClick={() => setActiveTab("customers")}
                  >
                    <Users className="h-5 w-5 mr-3" />
                    <span>Customers</span>
                  </Link>
                </li>
                <li className="px-6 py-3 hover:bg-gray-100">
                  <Link
                    href="#"
                    className="flex items-center"
                    onClick={() => setActiveTab("employees")}
                  >
                    <User className="h-5 w-5 mr-3" />
                    <span>Employees</span>
                  </Link>
                </li>
                <li className="px-6 py-3 hover:bg-gray-100">
                  <Link
                    href="#"
                    className="flex items-center"
                    onClick={() => setActiveTab("bookings")}
                  >
                    <BookOpen className="h-5 w-5 mr-3" />
                    <span>Bookings</span>
                  </Link>
                </li>
                <li className="px-6 py-3 hover:bg-gray-100">
                  <Link
                    href="#"
                    className="flex items-center"
                    onClick={() => setActiveTab("rentings")}
                  >
                    <Calendar className="h-5 w-5 mr-3" />
                    <span>Rentings</span>
                  </Link>
                </li>
                <li className="px-6 py-3 hover:bg-gray-100">
                  <Link href="#" className="flex items-center">
                    <FileText className="h-5 w-5 mr-3" />
                    <span>Reports</span>
                  </Link>
                </li>
                <li className="px-6 py-3 hover:bg-gray-100">
                  <Link href="#" className="flex items-center">
                    <Settings className="h-5 w-5 mr-3" />
                    <span>Settings</span>
                  </Link>
                </li>
              </ul>
            </nav>
          </div>

          {/* Content Area */}
          <div className="flex-1 overflow-y-auto p-6">
            <div className="mb-6">
              <h2 className="text-2xl font-semibold mb-2">Overview</h2>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                <div className="bg-white rounded-lg shadow p-4">
                  <div className="flex items-center">
                    <div className="p-3 rounded-full bg-blue-100 text-blue-600 mr-4">
                      <Hotel className="h-6 w-6" />
                    </div>
                    <div>
                      <div className="text-sm text-gray-500">Hotel Chains</div>
                      <div className="text-xl font-semibold">5</div>
                    </div>
                  </div>
                </div>
                <div className="bg-white rounded-lg shadow p-4">
                  <div className="flex items-center">
                    <div className="p-3 rounded-full bg-green-100 text-green-600 mr-4">
                      <Hotel className="h-6 w-6" />
                    </div>
                    <div>
                      <div className="text-sm text-gray-500">Hotels</div>
                      <div className="text-xl font-semibold">42</div>
                    </div>
                  </div>
                </div>
                <div className="bg-white rounded-lg shadow p-4">
                  <div className="flex items-center">
                    <div className="p-3 rounded-full bg-purple-100 text-purple-600 mr-4">
                      <Users className="h-6 w-6" />
                    </div>
                    <div>
                      <div className="text-sm text-gray-500">Customers</div>
                      <div className="text-xl font-semibold">1,247</div>
                    </div>
                  </div>
                </div>
                <div className="bg-white rounded-lg shadow p-4">
                  <div className="flex items-center">
                    <div className="p-3 rounded-full bg-yellow-100 text-yellow-600 mr-4">
                      <BookOpen className="h-6 w-6" />
                    </div>
                    <div>
                      <div className="text-sm text-gray-500">
                        Active Bookings
                      </div>
                      <div className="text-xl font-semibold">128</div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div className="mb-6">
              <div className="flex justify-between items-center mb-4">
                <h2 className="text-xl font-semibold">System Views</h2>
                <button className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700">
                  Refresh Views
                </button>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {/* View 1: Available Rooms per Area */}
                <div className="bg-white rounded-lg shadow p-4">
                  <h3 className="text-lg font-semibold mb-3">
                    View 1: Available Rooms per Area
                  </h3>
                  <div className="overflow-x-auto">
                    <table className="min-w-full bg-white">
                      <thead>
                        <tr>
                          <th className="py-2 px-4 border-b border-gray-200 bg-gray-50 text-left text-sm font-semibold text-gray-700">
                            Area
                          </th>
                          <th className="py-2 px-4 border-b border-gray-200 bg-gray-50 text-left text-sm font-semibold text-gray-700">
                            Available Rooms
                          </th>
                        </tr>
                      </thead>
                      <tbody>
                        {mockAvailableRooms.map((item, index) => (
                          <tr key={index}>
                            <td className="py-2 px-4 border-b border-gray-200">
                              {item.area}
                            </td>
                            <td className="py-2 px-4 border-b border-gray-200">
                              {item.available}
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>

                {/* View 2: Aggregated Room Capacity per Hotel */}
                <div className="bg-white rounded-lg shadow p-4">
                  <h3 className="text-lg font-semibold mb-3">
                    View 2: Aggregated Room Capacity per Hotel
                  </h3>
                  <div className="overflow-x-auto">
                    <table className="min-w-full bg-white">
                      <thead>
                        <tr>
                          <th className="py-2 px-4 border-b border-gray-200 bg-gray-50 text-left text-sm font-semibold text-gray-700">
                            Hotel
                          </th>
                          <th className="py-2 px-4 border-b border-gray-200 bg-gray-50 text-left text-sm font-semibold text-gray-700">
                            Total Capacity
                          </th>
                        </tr>
                      </thead>
                      <tbody>
                        {mockRoomCapacity.map((item, index) => (
                          <tr key={index}>
                            <td className="py-2 px-4 border-b border-gray-200">
                              {item.hotel}
                            </td>
                            <td className="py-2 px-4 border-b border-gray-200">
                              {item.totalCapacity}
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>
            </div>

            <div>
              <div className="flex justify-between items-center mb-4">
                <h2 className="text-xl font-semibold">Data Management</h2>
                <div className="flex space-x-2">
                  <select
                    className="border border-gray-300 rounded px-3 py-1 focus:outline-none focus:ring-2 focus:ring-blue-400"
                    value={activeTab}
                    onChange={(e) => setActiveTab(e.target.value)}
                  >
                    <option value="hotelchains">Hotel Chains</option>
                    <option value="hotels">Hotels</option>
                    <option value="rooms">Rooms</option>
                    <option value="customers">Customers</option>
                    <option value="employees">Employees</option>
                    <option value="bookings">Bookings</option>
                    <option value="rentings">Rentings</option>
                  </select>
                  <button
                    className="px-3 py-1 bg-green-600 text-white rounded hover:bg-green-700"
                    onClick={() => openAddModal(activeTab)}
                  >
                    Add New
                  </button>
                </div>
              </div>

              <div className="bg-white rounded-lg shadow overflow-hidden">
                <div className="border-b border-gray-200">
                  <button
                    className={`px-4 py-2 ${
                      activeTab === "hotelchains"
                        ? "text-blue-600 font-medium border-b-2 border-blue-600"
                        : "text-gray-500 hover:text-blue-600"
                    }`}
                    onClick={() => setActiveTab("hotelchains")}
                  >
                    Hotel Chains
                  </button>
                  <button
                    className={`px-4 py-2 ${
                      activeTab === "hotels"
                        ? "text-blue-600 font-medium border-b-2 border-blue-600"
                        : "text-gray-500 hover:text-blue-600"
                    }`}
                    onClick={() => setActiveTab("hotels")}
                  >
                    Hotels
                  </button>
                  <button
                    className={`px-4 py-2 ${
                      activeTab === "rooms"
                        ? "text-blue-600 font-medium border-b-2 border-blue-600"
                        : "text-gray-500 hover:text-blue-600"
                    }`}
                    onClick={() => setActiveTab("rooms")}
                  >
                    Rooms
                  </button>
                  <button
                    className={`px-4 py-2 ${
                      activeTab === "customers"
                        ? "text-blue-600 font-medium border-b-2 border-blue-600"
                        : "text-gray-500 hover:text-blue-600"
                    }`}
                    onClick={() => setActiveTab("customers")}
                  >
                    Customers
                  </button>
                  <button
                    className={`px-4 py-2 ${
                      activeTab === "employees"
                        ? "text-blue-600 font-medium border-b-2 border-blue-600"
                        : "text-gray-500 hover:text-blue-600"
                    }`}
                    onClick={() => setActiveTab("employees")}
                  >
                    Employees
                  </button>
                  <button
                    className={`px-4 py-2 ${
                      activeTab === "bookings"
                        ? "text-blue-600 font-medium border-b-2 border-blue-600"
                        : "text-gray-500 hover:text-blue-600"
                    }`}
                    onClick={() => setActiveTab("bookings")}
                  >
                    Bookings
                  </button>
                  <button
                    className={`px-4 py-2 ${
                      activeTab === "rentings"
                        ? "text-blue-600 font-medium border-b-2 border-blue-600"
                        : "text-gray-500 hover:text-blue-600"
                    }`}
                    onClick={() => setActiveTab("rentings")}
                  >
                    Rentings
                  </button>
                </div>

                <div className="overflow-x-auto">
                  {activeTab === "hotelchains" && (
                    <table className="min-w-full bg-white">
                      <thead>
                        <tr>
                          <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                            ID
                          </th>
                          <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                            Name
                          </th>
                          <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                            Hotels
                          </th>
                          <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                            Address
                          </th>
                          <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                            Email
                          </th>
                          <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                            Phone
                          </th>
                          <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                            Actions
                          </th>
                        </tr>
                      </thead>
                      <tbody>
                        {mockHotelChains.map((chain) => (
                          <tr key={chain.id} className="hover:bg-gray-50">
                            <td className="py-3 px-4 border-b border-gray-200">
                              {chain.id}
                            </td>
                            <td className="py-3 px-4 border-b border-gray-200">
                              {chain.name}
                            </td>
                            <td className="py-3 px-4 border-b border-gray-200">
                              {chain.hotels}
                            </td>
                            <td className="py-3 px-4 border-b border-gray-200">
                              {chain.address}
                            </td>
                            <td className="py-3 px-4 border-b border-gray-200">
                              {chain.email}
                            </td>
                            <td className="py-3 px-4 border-b border-gray-200">
                              {chain.phone}
                            </td>
                            <td className="py-3 px-4 border-b border-gray-200">
                              <div className="flex space-x-2">
                                <button className="p-1 bg-blue-100 text-blue-700 rounded hover:bg-blue-200">
                                  <Edit size={16} />
                                </button>
                                <button className="p-1 bg-red-100 text-red-700 rounded hover:bg-red-200">
                                  <Trash2 size={16} />
                                </button>
                              </div>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  )}

                  {activeTab === "hotels" && (
                    <table className="min-w-full bg-white">
                      <thead>
                        <tr>
                          <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                            ID
                          </th>
                          <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                            Name
                          </th>
                          <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                            Chain
                          </th>
                          <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                            Category
                          </th>
                          <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                            Rooms
                          </th>
                          <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                            Address
                          </th>
                          <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                            Email
                          </th>
                          <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                            Phone
                          </th>
                          <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                            Actions
                          </th>
                        </tr>
                      </thead>
                      <tbody>
                        {mockHotels.map((hotel) => (
                          <tr key={hotel.id} className="hover:bg-gray-50">
                            <td className="py-3 px-4 border-b border-gray-200">
                              {hotel.id}
                            </td>
                            <td className="py-3 px-4 border-b border-gray-200">
                              {hotel.name}
                            </td>
                            <td className="py-3 px-4 border-b border-gray-200">
                              {hotel.chain}
                            </td>
                            <td className="py-3 px-4 border-b border-gray-200">
                              {hotel.category}
                            </td>
                            <td className="py-3 px-4 border-b border-gray-200">
                              {hotel.rooms}
                            </td>
                            <td className="py-3 px-4 border-b border-gray-200">
                              {hotel.address}
                            </td>
                            <td className="py-3 px-4 border-b border-gray-200">
                              {hotel.email}
                            </td>
                            <td className="py-3 px-4 border-b border-gray-200">
                              {hotel.phone}
                            </td>
                            <td className="py-3 px-4 border-b border-gray-200">
                              <div className="flex space-x-2">
                                <button className="p-1 bg-blue-100 text-blue-700 rounded hover:bg-blue-200">
                                  <Edit size={16} />
                                </button>
                                <button className="p-1 bg-red-100 text-red-700 rounded hover:bg-red-200">
                                  <Trash2 size={16} />
                                </button>
                              </div>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  )}

                  {/* Additional tables for other tabs would go here */}
                </div>
              </div>
            </div>

            {/* Room Booking/Rental Form */}
            <div className="mt-8 bg-white rounded-lg shadow p-6">
              <h2 className="text-xl font-semibold mb-4">
                Room Booking / Rental Management
              </h2>

              <div className="mb-4">
                <div className="flex space-x-4 mb-4">
                  <button
                    className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
                    onClick={() => openBookingModal("booking")}
                  >
                    New Booking
                  </button>
                  <button
                    className="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700"
                    onClick={() => openBookingModal("rental")}
                  >
                    New Rental
                  </button>
                  <button
                    className="px-4 py-2 bg-purple-600 text-white rounded-md hover:bg-purple-700"
                    onClick={() => openBookingModal("convert")}
                  >
                    Convert Booking to Rental
                  </button>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Customer
                    </label>
                    <select className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400">
                      <option value="">Select Customer</option>
                      {mockCustomers.map((customer) => (
                        <option key={customer.id} value={customer.id}>
                          {customer.name}
                        </option>
                      ))}
                    </select>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Hotel
                    </label>
                    <select className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400">
                      <option value="">Select Hotel</option>
                      {mockHotels.map((hotel) => (
                        <option key={hotel.id} value={hotel.id}>
                          {hotel.name}
                        </option>
                      ))}
                    </select>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Room
                    </label>
                    <select className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400">
                      <option value="">Select Room</option>
                      {mockRooms.map((room) => (
                        <option key={room.id} value={room.id}>
                          Room {room.number} - {room.capacity}
                        </option>
                      ))}
                    </select>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Start Date
                    </label>
                    <input
                      type="date"
                      className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      End Date
                    </label>
                    <input
                      type="date"
                      className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Employee (for Rental)
                    </label>
                    <select className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400">
                      <option value="">Select Employee</option>
                      {mockEmployees.map((employee) => (
                        <option key={employee.id} value={employee.id}>
                          {employee.name} - {employee.position}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>

                <div className="mt-4 flex justify-end">
                  <button className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700">
                    Search Available Rooms
                  </button>
                </div>
              </div>

              <div className="mt-6">
                <h3 className="text-lg font-semibold mb-3">Available Rooms</h3>
                <div className="overflow-x-auto">
                  <table className="min-w-full bg-white">
                    <thead>
                      <tr>
                        <th className="py-2 px-4 border-b border-gray-200 bg-gray-50 text-left text-sm font-semibold text-gray-700">
                          Room #
                        </th>
                        <th className="py-2 px-4 border-b border-gray-200 bg-gray-50 text-left text-sm font-semibold text-gray-700">
                          Hotel
                        </th>
                        <th className="py-2 px-4 border-b border-gray-200 bg-gray-50 text-left text-sm font-semibold text-gray-700">
                          Capacity
                        </th>
                        <th className="py-2 px-4 border-b border-gray-200 bg-gray-50 text-left text-sm font-semibold text-gray-700">
                          Price
                        </th>
                        <th className="py-2 px-4 border-b border-gray-200 bg-gray-50 text-left text-sm font-semibold text-gray-700">
                          Amenities
                        </th>
                        <th className="py-2 px-4 border-b border-gray-200 bg-gray-50 text-left text-sm font-semibold text-gray-700">
                          View
                        </th>
                        <th className="py-2 px-4 border-b border-gray-200 bg-gray-50 text-left text-sm font-semibold text-gray-700">
                          Extendable
                        </th>
                        <th className="py-2 px-4 border-b border-gray-200 bg-gray-50 text-left text-sm font-semibold text-gray-700">
                          Actions
                        </th>
                      </tr>
                    </thead>
                    <tbody>
                      {mockRooms.map((room) => (
                        <tr key={room.id} className="hover:bg-gray-50">
                          <td className="py-2 px-4 border-b border-gray-200">
                            {room.number}
                          </td>
                          <td className="py-2 px-4 border-b border-gray-200">
                            {mockHotels.find((h) => h.id === room.hotelId)
                              ?.name || ""}
                          </td>
                          <td className="py-2 px-4 border-b border-gray-200">
                            {room.capacity}
                          </td>
                          <td className="py-2 px-4 border-b border-gray-200">
                            ${room.price}/night
                          </td>
                          <td className="py-2 px-4 border-b border-gray-200">
                            {room.amenities}
                          </td>
                          <td className="py-2 px-4 border-b border-gray-200">
                            {room.view}
                          </td>
                          <td className="py-2 px-4 border-b border-gray-200">
                            {room.extendable ? "Yes" : "No"}
                          </td>
                          <td className="py-2 px-4 border-b border-gray-200">
                            <div className="flex space-x-2">
                              <button className="px-2 py-1 bg-blue-100 text-blue-700 rounded hover:bg-blue-200 text-xs">
                                Book
                              </button>
                              <button className="px-2 py-1 bg-green-100 text-green-700 rounded hover:bg-green-200 text-xs">
                                Rent
                              </button>
                            </div>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            </div>

            {/* Add Modal */}
            {showAddModal && (
              <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
                <div className="bg-white rounded-lg p-6 w-full max-w-2xl">
                  <div className="flex justify-between items-center mb-4">
                    <h3 className="text-xl font-semibold">
                      Add New{" "}
                      {modalType === "hotelchains"
                        ? "Hotel Chain"
                        : modalType === "hotels"
                        ? "Hotel"
                        : modalType === "rooms"
                        ? "Room"
                        : modalType === "customers"
                        ? "Customer"
                        : modalType === "employees"
                        ? "Employee"
                        : "Item"}
                    </h3>
                    <button
                      className="text-gray-400 hover:text-gray-600"
                      onClick={() => setShowAddModal(false)}
                    >
                      &times;
                    </button>
                  </div>

                  <div className="mb-4">
                    {modalType === "hotelchains" && (
                      <div className="space-y-4">
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Name
                          </label>
                          <input
                            type="text"
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                          />
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Address
                          </label>
                          <input
                            type="text"
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                          />
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Email
                          </label>
                          <input
                            type="email"
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                          />
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Phone
                          </label>
                          <input
                            type="tel"
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                          />
                        </div>
                      </div>
                    )}

                    {modalType === "hotels" && (
                      <div className="space-y-4">
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Name
                          </label>
                          <input
                            type="text"
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                          />
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Hotel Chain
                          </label>
                          <select className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400">
                            <option value="">Select Hotel Chain</option>
                            {mockHotelChains.map((chain) => (
                              <option key={chain.id} value={chain.id}>
                                {chain.name}
                              </option>
                            ))}
                          </select>
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Category
                          </label>
                          <select className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400">
                            <option value="">Select Category</option>
                            <option value="1-star">1-star</option>
                            <option value="2-star">2-star</option>
                            <option value="3-star">3-star</option>
                            <option value="4-star">4-star</option>
                            <option value="5-star">5-star</option>
                          </select>
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Address
                          </label>
                          <input
                            type="text"
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                          />
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Email
                          </label>
                          <input
                            type="email"
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                          />
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Phone
                          </label>
                          <input
                            type="tel"
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                          />
                        </div>
                      </div>
                    )}

                    {modalType === "rooms" && (
                      <div className="space-y-4">
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Room Number
                          </label>
                          <input
                            type="text"
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                          />
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Hotel
                          </label>
                          <select className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400">
                            <option value="">Select Hotel</option>
                            {mockHotels.map((hotel) => (
                              <option key={hotel.id} value={hotel.id}>
                                {hotel.name}
                              </option>
                            ))}
                          </select>
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Price per Night
                          </label>
                          <input
                            type="number"
                            min="0"
                            step="0.01"
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                          />
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Capacity
                          </label>
                          <select className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400">
                            <option value="">Select Capacity</option>
                            <option value="single">Single</option>
                            <option value="double">Double</option>
                            <option value="triple">Triple</option>
                            <option value="quad">Quad</option>
                            <option value="suite">Suite</option>
                          </select>
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Amenities
                          </label>
                          <input
                            type="text"
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                            placeholder="e.g. TV, AC, fridge, wifi"
                          />
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            View
                          </label>
                          <select className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400">
                            <option value="">Select View</option>
                            <option value="sea">Sea View</option>
                            <option value="mountain">Mountain View</option>
                            <option value="city">City View</option>
                            <option value="garden">Garden View</option>
                            <option value="none">No View</option>
                          </select>
                        </div>
                        <div className="flex items-center">
                          <input
                            type="checkbox"
                            id="extendable"
                            className="mr-2"
                          />
                          <label
                            htmlFor="extendable"
                            className="text-sm font-medium text-gray-700"
                          >
                            Extendable (can add extra bed)
                          </label>
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Issues/Damages
                          </label>
                          <textarea
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                            rows={3}
                            placeholder="Describe any issues or damages"
                          ></textarea>
                        </div>
                      </div>
                    )}

                    {/* Similar form fields for customers, employees, etc. would go here */}
                  </div>

                  <div className="flex justify-end space-x-2">
                    <button
                      className="px-4 py-2 bg-gray-200 text-gray-700 rounded-md hover:bg-gray-300"
                      onClick={() => setShowAddModal(false)}
                    >
                      Cancel
                    </button>
                    <button className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700">
                      Save
                    </button>
                  </div>
                </div>
              </div>
            )}

            {/* Booking/Rental Modal */}
            {showBookingModal && (
              <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
                <div className="bg-white rounded-lg p-6 w-full max-w-2xl">
                  <div className="flex justify-between items-center mb-4">
                    <h3 className="text-xl font-semibold">
                      {modalType === "booking"
                        ? "Create New Booking"
                        : modalType === "rental"
                        ? "Create New Rental"
                        : "Convert Booking to Rental"}
                    </h3>
                    <button
                      className="text-gray-400 hover:text-gray-600"
                      onClick={() => setShowBookingModal(false)}
                    >
                      &times;
                    </button>
                  </div>

                  <div className="mb-4">
                    {modalType === "booking" && (
                      <div className="space-y-4">
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Customer
                          </label>
                          <select className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400">
                            <option value="">Select Customer</option>
                            {mockCustomers.map((customer) => (
                              <option key={customer.id} value={customer.id}>
                                {customer.name}
                              </option>
                            ))}
                          </select>
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Hotel
                          </label>
                          <select className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400">
                            <option value="">Select Hotel</option>
                            {mockHotels.map((hotel) => (
                              <option key={hotel.id} value={hotel.id}>
                                {hotel.name}
                              </option>
                            ))}
                          </select>
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Room
                          </label>
                          <select className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400">
                            <option value="">Select Room</option>
                            {mockRooms.map((room) => (
                              <option key={room.id} value={room.id}>
                                Room {room.number} - {room.capacity}
                              </option>
                            ))}
                          </select>
                        </div>
                        <div className="grid grid-cols-2 gap-4">
                          <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">
                              Start Date
                            </label>
                            <input
                              type="date"
                              className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                            />
                          </div>
                          <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">
                              End Date
                            </label>
                            <input
                              type="date"
                              className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                            />
                          </div>
                        </div>
                      </div>
                    )}

                    {modalType === "rental" && (
                      <div className="space-y-4">
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Customer
                          </label>
                          <select className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400">
                            <option value="">Select Customer</option>
                            {mockCustomers.map((customer) => (
                              <option key={customer.id} value={customer.id}>
                                {customer.name}
                              </option>
                            ))}
                          </select>
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Hotel
                          </label>
                          <select className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400">
                            <option value="">Select Hotel</option>
                            {mockHotels.map((hotel) => (
                              <option key={hotel.id} value={hotel.id}>
                                {hotel.name}
                              </option>
                            ))}
                          </select>
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Room
                          </label>
                          <select className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400">
                            <option value="">Select Room</option>
                            {mockRooms.map((room) => (
                              <option key={room.id} value={room.id}>
                                Room {room.number} - {room.capacity}
                              </option>
                            ))}
                          </select>
                        </div>
                        <div className="grid grid-cols-2 gap-4">
                          <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">
                              Start Date
                            </label>
                            <input
                              type="date"
                              className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                            />
                          </div>
                          <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">
                              End Date
                            </label>
                            <input
                              type="date"
                              className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                            />
                          </div>
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Employee
                          </label>
                          <select className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400">
                            <option value="">Select Employee</option>
                            {mockEmployees.map((employee) => (
                              <option key={employee.id} value={employee.id}>
                                {employee.name} - {employee.position}
                              </option>
                            ))}
                          </select>
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Payment Status
                          </label>
                          <select className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400">
                            <option value="unpaid">Unpaid</option>
                            <option value="partial">Partially Paid</option>
                            <option value="paid">Paid</option>
                          </select>
                        </div>
                      </div>
                    )}

                    {modalType === "convert" && (
                      <div className="space-y-4">
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Select Booking to Convert
                          </label>
                          <select className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400">
                            <option value="">Select Booking</option>
                            {mockBookings.map((booking) => {
                              const customer = mockCustomers.find(
                                (c) => c.id === booking.customerId
                              );
                              const room = mockRooms.find(
                                (r) => r.id === booking.roomId
                              );
                              return (
                                <option key={booking.id} value={booking.id}>
                                  {customer?.name || "Unknown"} - Room{" "}
                                  {room?.number || "Unknown"} (
                                  {booking.startDate} to {booking.endDate})
                                </option>
                              );
                            })}
                          </select>
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Employee for Check-in
                          </label>
                          <select className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400">
                            <option value="">Select Employee</option>
                            {mockEmployees.map((employee) => (
                              <option key={employee.id} value={employee.id}>
                                {employee.name} - {employee.position}
                              </option>
                            ))}
                          </select>
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Check-in Date
                          </label>
                          <input
                            type="date"
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                          />
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Payment Status
                          </label>
                          <select className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400">
                            <option value="unpaid">Unpaid</option>
                            <option value="partial">Partially Paid</option>
                            <option value="paid">Paid</option>
                          </select>
                        </div>
                      </div>
                    )}
                  </div>

                  <div className="flex justify-end space-x-2">
                    <button
                      className="px-4 py-2 bg-gray-200 text-gray-700 rounded-md hover:bg-gray-300"
                      onClick={() => setShowBookingModal(false)}
                    >
                      Cancel
                    </button>
                    <button className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700">
                      {modalType === "booking"
                        ? "Create Booking"
                        : modalType === "rental"
                        ? "Create Rental"
                        : "Convert to Rental"}
                    </button>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </>
  );
};

export default AdminDashboard;
