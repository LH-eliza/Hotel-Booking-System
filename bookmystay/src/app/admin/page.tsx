"use client";

import React, { useEffect, useState } from "react";
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

interface AreaRooms {
  area: string;
  available_rooms: number;
}

interface HotelCapacity {
  hotel_id: string;
  total_capacity: number;
}

interface HotelChain {
  chain_id: string;
  num_hotels: number;
  central_office_address: string;
}

interface Hotel {
  hotel_id: string;
  chain_id: string;
  address: string;
  num_rooms: number;
  contact_email: string;
  star_category: string;
}

interface Room {
  room_id: string;
  hotel_id: string;
  price: number;
  capacity: string;
  view: string;
  extendable: boolean;
  status: string;
}

interface Customer {
  customer_id: string;
  first_name: string;
  last_name: string;
  address: string;
  id_type: string;
  id_number: string;
  registration_date: string;
}

interface Employee {
  ssn: string;
  hotel_id: string;
  first_name: string;
  last_name: string;
  address: string;
  role: string;
}

interface Booking {
  booking_id: string;
  customer_id: string;
  start_date: string;
  end_date: string;
  room_id: string;
}

interface Renting {
  id: number;
  bookingId: number;
  employeeId: number;
  checkInDate: string;
  status: string;
  paymentStatus: string;
}

const AdminDashboard: React.FC = () => {
  const [hotelChains, setHotelChains] = useState<HotelChain[]>([]);
  const [rooms, setRooms] = useState<Room[]>([]);
  const [employees, setEmployees] = useState<Employee[]>([]);
  const [bookingsList, setBookingsList] = useState<Booking[]>([]);
  const [customers, setCustomers] = useState<Customer[]>([]);
  const [hotelRecords, setHotelRecords] = useState<Hotel[]>([]);
  const [hotelChainCount, setHotelChainCount] = useState("...");
  const [hotelCount, setHotelCount] = useState("...");
  const [customerCount, setCustomerCount] = useState("...");
  const [bookings, setBookings] = useState("...");
  const [hotelCapacity, setHotelCapacity] = useState<HotelCapacity[]>([]);
  const [availableRoomsPerArea, setAvailableRoomsPerArea] = useState<AreaRooms[]>([]);
  const [activeTab, setActiveTab] = useState<string>("hotelchains");
  const [showAddModal, setShowAddModal] = useState<boolean>(false);
  const [showBookingModal, setShowBookingModal] = useState<boolean>(false);
  const [modalType, setModalType] = useState<string>("");

  // Add pagination state for each tab
  const [hotelChainsPage, setHotelChainsPage] = useState(1);
  const [hotelsPage, setHotelsPage] = useState(1);
  const [roomsPage, setRoomsPage] = useState(1);
  const [customersPage, setCustomersPage] = useState(1);
  const [employeesPage, setEmployeesPage] = useState(1);
  const [bookingsListPage, setBookingsListPage] = useState(1);
  const [systemView1Page, setSystemView1Page] = useState(1);
  const [systemView2Page, setSystemView2Page] = useState(1);
  const itemsPerPage = 10;

  // Add room search and filter state
  const [roomSearchQuery, setRoomSearchQuery] = useState("");
  const [roomFilters, setRoomFilters] = useState({
    capacity: "",
    minPrice: "",
    maxPrice: "",
    view: "",
  });

  // Room search and filter handlers
  const handleRoomSearchChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setRoomSearchQuery(e.target.value);
    setAvailableRoomsPage(1); // Reset to first page when search changes
  };

  const handleRoomFilterChange = (key: string, value: string) => {
    setRoomFilters(prev => ({
      ...prev,
      [key]: value
    }));
    setAvailableRoomsPage(1); // Reset to first page when filters change
  };

  // Available rooms pagination
  const [availableRoomsPage, setAvailableRoomsPage] = useState(1);

  // Filter and paginate available rooms
  const filteredRooms = rooms.filter((room) => {
    const matchesSearch = 
      room.room_id.toLowerCase().includes(roomSearchQuery.toLowerCase()) ||
      room.capacity.toLowerCase().includes(roomSearchQuery.toLowerCase()) ||
      room.view.toLowerCase().includes(roomSearchQuery.toLowerCase());

    const matchesCapacity = !roomFilters.capacity || room.capacity === roomFilters.capacity;
    const matchesMinPrice = !roomFilters.minPrice || room.price >= Number(roomFilters.minPrice);
    const matchesMaxPrice = !roomFilters.maxPrice || room.price <= Number(roomFilters.maxPrice);
    const matchesView = !roomFilters.view || room.view === roomFilters.view;

    return matchesSearch && matchesCapacity && matchesMinPrice && matchesMaxPrice && matchesView;
  });

  const availableRoomsTotalPages = Math.ceil(filteredRooms.length / itemsPerPage);
  const availableRoomsStartIndex = (availableRoomsPage - 1) * itemsPerPage;
  const availableRoomsEndIndex = availableRoomsStartIndex + itemsPerPage;
  const currentAvailableRooms = filteredRooms.slice(availableRoomsStartIndex, availableRoomsEndIndex);

  const handleAvailableRoomsPrevPage = () => {
    setAvailableRoomsPage(prev => Math.max(1, prev - 1));
  };

  const handleAvailableRoomsNextPage = () => {
    setAvailableRoomsPage(prev => Math.min(availableRoomsTotalPages, prev + 1));
  };

  // Calculate pagination values for system views
  const view1TotalPages = Math.ceil(availableRoomsPerArea.length / itemsPerPage);
  const view1StartIndex = (systemView1Page - 1) * itemsPerPage;
  const view1EndIndex = view1StartIndex + itemsPerPage;
  const view1CurrentItems = availableRoomsPerArea.slice(view1StartIndex, view1EndIndex);

  // Calculate pagination values for View 2
  const view2TotalPages = Math.ceil(hotelCapacity.length / itemsPerPage);
  const view2StartIndex = (systemView2Page - 1) * itemsPerPage;
  const view2EndIndex = view2StartIndex + itemsPerPage;
  const view2CurrentItems = hotelCapacity.slice(view2StartIndex, view2EndIndex);

  // Calculate pagination for each tab
  const getPageItems = <T,>(items: T[], currentPage: number) => {
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = startIndex + itemsPerPage;
    return {
      currentItems: items.slice(startIndex, endIndex),
      totalPages: Math.ceil(items.length / itemsPerPage),
      startIndex,
      endIndex,
      totalItems: items.length
    };
  };

  // Pagination handlers for system views
  const handleView1PrevPage = () => {
    setSystemView1Page(prev => Math.max(1, prev - 1));
  };

  const handleView1NextPage = () => {
    setSystemView1Page(prev => Math.min(view1TotalPages, prev + 1));
  };

  const handleView2PrevPage = () => {
    setSystemView2Page(prev => Math.max(1, prev - 1));
  };

  const handleView2NextPage = () => {
    setSystemView2Page(prev => Math.min(view2TotalPages, prev + 1));
  };

  // Pagination handlers for data management
  const handlePageChange = (tab: string, increment: boolean) => {
    switch (tab) {
      case "hotelchains":
        setHotelChainsPage(prev => increment ? prev + 1 : prev - 1);
        break;
      case "hotels":
        setHotelsPage(prev => increment ? prev + 1 : prev - 1);
        break;
      case "rooms":
        setRoomsPage(prev => increment ? prev + 1 : prev - 1);
        break;
      case "customers":
        setCustomersPage(prev => increment ? prev + 1 : prev - 1);
        break;
      case "employees":
        setEmployeesPage(prev => increment ? prev + 1 : prev - 1);
        break;
      case "bookings":
        setBookingsListPage(prev => increment ? prev + 1 : prev - 1);
        break;
    }
  };

  // Reset pagination when changing tabs
  useEffect(() => {
    setHotelChainsPage(1);
    setHotelsPage(1);
    setRoomsPage(1);
    setCustomersPage(1);
    setEmployeesPage(1);
    setBookingsListPage(1);
    setSystemView1Page(1);
    setSystemView2Page(1);
  }, [activeTab]);

  const fetchHotelChainCount = async () => {
    try {
      const response = await fetch("/api/getHotelChainCount"); // Correct route
      if (response.ok) {
        const data = await response.json();
        setHotelChainCount(data.total); // Store the row count in state
      } else {
        throw new Error("Failed to fetch row count");
      }
    } catch (error) {
      console.log(error);
    }
  };

  const fetchAvailableRooms = async () => {
    try {
      const response = await fetch("/api/getAvailableRoomsPerArea"); // Call the backend route
      if (response.ok) {
        const data = await response.json();
        setAvailableRoomsPerArea(data); // Store the table data in state
      } else {
        throw new Error("Failed to fetch rooms");
      }
    } catch (error) {
      console.log(error);
    }
  };

  const fetchHotelCapacity = async () => {
    try {
      const response = await fetch("/api/getRoomCapacityPerHotel"); // Call the backend route
      if (response.ok) {
        const data = await response.json();
        setHotelCapacity(data); // Store the table data in state
      } else {
        throw new Error("Failed to fetch rooms");
      }
    } catch (error) {
      console.log(error);
    }
  };

  const fetchBookings = async () => {
    try {
      const response = await fetch("/api/getBookings"); // Correct route
      if (response.ok) {
        const data = await response.json();
        setBookings(data.total); // Store the row count in state
      } else {
        throw new Error("Failed to fetch row count");
      }
    } catch (error) {
      console.log(error);
    }
  };

  const fetchHotelCount = async () => {
    try {
      const response = await fetch("/api/getHotelCount"); // Correct route
      if (response.ok) {
        const data = await response.json();
        setHotelCount(data.total); // Store the row count in state
      } else {
        throw new Error("Failed to fetch row count");
      }
    } catch (error) {
      console.log(error);
    }
  };

  const fetchHotels = async () => {
    try {
      const response = await fetch("/api/getHotels"); // Correct route
      if (response.ok) {
        const data = await response.json();
        setHotelRecords(data);
      } else {
        throw new Error("Failed to fetch row count");
      }
    } catch (error) {
      console.log(error);
    }
  };

  const fetchEmployees = async () => {
    try {
      const response = await fetch("/api/getEmployees"); // Correct route
      if (response.ok) {
        const data = await response.json();
        setEmployees(data);
      } else {
        throw new Error("Failed to fetch row count");
      }
    } catch (error) {
      console.log(error);
    }
  };

  const fetchBookingList = async () => {
    try {
      const response = await fetch("/api/getBookingList"); // Correct route
      if (response.ok) {
        const data = await response.json();
        setBookingsList(data);
      } else {
        throw new Error("Failed to fetch row count");
      }
    } catch (error) {
      console.log(error);
    }
  };

  const fetchRooms = async () => {
    try {
      const response = await fetch("/api/getRooms"); // Correct route
      if (response.ok) {
        const data = await response.json();
        setRooms(data);
      } else {
        throw new Error("Failed to fetch row count");
      }
    } catch (error) {
      console.log(error);
    }
  };

  const fetchCustomers = async () => {
    try {
      const response = await fetch("/api/getCustomers"); // Correct route
      if (response.ok) {
        const data = await response.json();
        setCustomers(data);
      } else {
        throw new Error("Failed to fetch row count");
      }
    } catch (error) {
      console.log(error);
    }
  };

  const fetchHotelChains = async () => {
    try {
      const response = await fetch("/api/getHotelChains"); // Correct route
      if (response.ok) {
        const data = await response.json();
        setHotelChains(data);
      } else {
        throw new Error("Failed to fetch row count");
      }
    } catch (error) {
      console.log(error);
    }
  };

  const fetchCustomerCount = async () => {
    try {
      const response = await fetch("/api/getCustomerCount"); // Correct route
      if (response.ok) {
        const data = await response.json();
        setCustomerCount(data.total); // Store the row count in state
      } else {
        throw new Error("Failed to fetch row count");
      }
    } catch (error) {
      console.log(error);
    }
  };

  useEffect(() => {
    const fetchData = async () => {
      try {
        await Promise.all([
          fetchHotels(),
          fetchHotelChainCount(),
          fetchHotelCount(),
          fetchCustomerCount(),
          fetchBookings(),
          fetchAvailableRooms(),
          fetchHotelCapacity(),
          fetchHotelChains(),
          fetchRooms(),
          fetchCustomers(),
          fetchEmployees(),
          fetchBookingList(),
        ]);
      } catch (error) {
        console.log(error);
      }
    };

    fetchData();
  }, []);

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
                      <div className="text-xl font-semibold">
                        {hotelChainCount}
                      </div>
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
                      <div className="text-xl font-semibold">{hotelCount}</div>
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
                      <div className="text-xl font-semibold">
                        {customerCount}
                      </div>
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
                      <div className="text-xl font-semibold">{bookings}</div>
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
                        {view1CurrentItems.map((item, index) => (
                          <tr key={index}>
                            <td className="py-2 px-4 border-b border-gray-200">
                              {item.area}
                            </td>
                            <td className="py-2 px-4 border-b border-gray-200">
                              {item.available_rooms}
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                    <div className="mt-4 flex items-center justify-between">
                      <div className="text-sm text-gray-500">
                        Showing {view1StartIndex + 1}-{Math.min(view1EndIndex, availableRoomsPerArea.length)} of {availableRoomsPerArea.length} entries
                      </div>
                      <div className="flex space-x-2">
                        <button
                          onClick={handleView1PrevPage}
                          disabled={systemView1Page === 1}
                          className={`px-3 py-1 rounded ${
                            systemView1Page === 1
                              ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                              : 'bg-blue-600 text-white hover:bg-blue-700'
                          }`}
                        >
                          Previous
                        </button>
                        <button
                          onClick={handleView1NextPage}
                          disabled={systemView1Page === view1TotalPages}
                          className={`px-3 py-1 rounded ${
                            systemView1Page === view1TotalPages
                              ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                              : 'bg-blue-600 text-white hover:bg-blue-700'
                          }`}
                        >
                          Next
                        </button>
                      </div>
                    </div>
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
                        {view2CurrentItems.map((item, index) => (
                          <tr key={index}>
                            <td className="py-2 px-4 border-b border-gray-200">
                              {item.hotel_id}
                            </td>
                            <td className="py-2 px-4 border-b border-gray-200">
                              {item.total_capacity}
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                    <div className="mt-4 flex items-center justify-between">
                      <div className="text-sm text-gray-500">
                        Showing {view2StartIndex + 1}-{Math.min(view2EndIndex, hotelCapacity.length)} of {hotelCapacity.length} entries
                      </div>
                      <div className="flex space-x-2">
                        <button
                          onClick={handleView2PrevPage}
                          disabled={systemView2Page === 1}
                          className={`px-3 py-1 rounded ${
                            systemView2Page === 1
                              ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                              : 'bg-blue-600 text-white hover:bg-blue-700'
                          }`}
                        >
                          Previous
                        </button>
                        <button
                          onClick={handleView2NextPage}
                          disabled={systemView2Page === view2TotalPages}
                          className={`px-3 py-1 rounded ${
                            systemView2Page === view2TotalPages
                              ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                              : 'bg-blue-600 text-white hover:bg-blue-700'
                          }`}
                        >
                          Next
                        </button>
                      </div>
                    </div>
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
                    <>
                      <table className="min-w-full bg-white">
                        <thead>
                          <tr>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Chain ID
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Number of Hotels
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Central Office Address
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Actions
                            </th>
                          </tr>
                        </thead>
                        <tbody>
                          {getPageItems(hotelChains, hotelChainsPage).currentItems.map((chain) => (
                            <tr key={chain.chain_id} className="hover:bg-gray-50">
                              <td className="py-3 px-4 border-b border-gray-200">
                                {chain.chain_id}
                              </td>
                              <td className="py-3 px-4 border-b border-gray-200">
                                {chain.num_hotels}
                              </td>
                              <td className="py-3 px-4 border-b border-gray-200">
                                {chain.central_office_address}
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
                      <div className="mt-4 flex items-center justify-between px-4">
                        <div className="text-sm text-gray-500">
                          Showing {getPageItems(hotelChains, hotelChainsPage).startIndex + 1}-
                          {Math.min(getPageItems(hotelChains, hotelChainsPage).endIndex, hotelChains.length)} of {hotelChains.length} entries
                        </div>
                        <div className="flex space-x-2">
                          <button
                            onClick={() => handlePageChange("hotelchains", false)}
                            disabled={hotelChainsPage === 1}
                            className={`px-3 py-1 rounded ${
                              hotelChainsPage === 1
                                ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                                : 'bg-blue-600 text-white hover:bg-blue-700'
                            }`}
                          >
                            Previous
                          </button>
                          <button
                            onClick={() => handlePageChange("hotelchains", true)}
                            disabled={hotelChainsPage === getPageItems(hotelChains, hotelChainsPage).totalPages}
                            className={`px-3 py-1 rounded ${
                              hotelChainsPage === getPageItems(hotelChains, hotelChainsPage).totalPages
                                ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                                : 'bg-blue-600 text-white hover:bg-blue-700'
                            }`}
                          >
                            Next
                          </button>
                        </div>
                      </div>
                    </>
                  )}

                  {activeTab === "hotels" && (
                    <>
                      <table className="min-w-full bg-white">
                        <thead>
                          <tr>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Chain ID
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Hotel ID
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Address
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Number of Rooms
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Email
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Star Category
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Actions
                            </th>
                          </tr>
                        </thead>
                        <tbody>
                          {getPageItems(hotelRecords, hotelsPage).currentItems.map((hotel) => (
                            <tr key={hotel.hotel_id} className="hover:bg-gray-50">
                              <td className="py-3 px-4 border-b border-gray-200">
                                {hotel.chain_id}
                              </td>
                              <td className="py-3 px-4 border-b border-gray-200">
                                {hotel.hotel_id}
                              </td>
                              <td className="py-3 px-4 border-b border-gray-200">
                                {hotel.address}
                              </td>
                              <td className="py-3 px-4 border-b border-gray-200">
                                {hotel.num_rooms}
                              </td>
                              <td className="py-3 px-4 border-b border-gray-200">
                                {hotel.contact_email}
                              </td>
                              <td className="py-3 px-4 border-b border-gray-200">
                                {hotel.star_category}
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
                      <div className="mt-4 flex items-center justify-between px-4">
                        <div className="text-sm text-gray-500">
                          Showing {getPageItems(hotelRecords, hotelsPage).startIndex + 1}-
                          {Math.min(getPageItems(hotelRecords, hotelsPage).endIndex, hotelRecords.length)} of {hotelRecords.length} entries
                        </div>
                        <div className="flex space-x-2">
                          <button
                            onClick={() => handlePageChange("hotels", false)}
                            disabled={hotelsPage === 1}
                            className={`px-3 py-1 rounded ${
                              hotelsPage === 1
                                ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                                : 'bg-blue-600 text-white hover:bg-blue-700'
                            }`}
                          >
                            Previous
                          </button>
                          <button
                            onClick={() => handlePageChange("hotels", true)}
                            disabled={hotelsPage === getPageItems(hotelRecords, hotelsPage).totalPages}
                            className={`px-3 py-1 rounded ${
                              hotelsPage === getPageItems(hotelRecords, hotelsPage).totalPages
                                ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                                : 'bg-blue-600 text-white hover:bg-blue-700'
                            }`}
                          >
                            Next
                          </button>
                        </div>
                      </div>
                    </>
                  )}

                  {activeTab === "rooms" && (
                    <>
                      <table className="min-w-full bg-white">
                        <thead>
                          <tr>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Room ID
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Hotel ID
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Price
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Capacity
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              View
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Extendable
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Status
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Actions
                            </th>
                          </tr>
                        </thead>
                        <tbody>
                          {getPageItems(rooms, roomsPage).currentItems.map((room) => (
                            <tr key={room.room_id} className="hover:bg-gray-50">
                              <td className="py-3 px-4 border-b border-gray-200">
                                {room.room_id}
                              </td>
                              <td className="py-3 px-4 border-b border-gray-200">
                                {hotelRecords.find((h) => h.hotel_id === room.hotel_id)
                                  ?.hotel_id || ""}
                              </td>
                              <td className="py-3 px-4 border-b border-gray-200">
                                {room.price}
                              </td>
                              <td className="py-3 px-4 border-b border-gray-200">
                                {room.capacity}
                              </td>
                              <td className="py-3 px-4 border-b border-gray-200">
                                {room.view}
                              </td>
                              <td className="py-3 px-4 border-b border-gray-200">
                                {room.extendable ? "Yes" : "No"}
                              </td>
                              <td className="py-3 px-4 border-b border-gray-200">
                                {room.status}
                              </td>
                              <td className="py-3 px-4 border-b border-gray-200">
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
                      <div className="mt-4 flex items-center justify-between px-4">
                        <div className="text-sm text-gray-500">
                          Showing {getPageItems(rooms, roomsPage).startIndex + 1}-
                          {Math.min(getPageItems(rooms, roomsPage).endIndex, rooms.length)} of {rooms.length} entries
                        </div>
                        <div className="flex space-x-2">
                          <button
                            onClick={() => handlePageChange("rooms", false)}
                            disabled={roomsPage === 1}
                            className={`px-3 py-1 rounded ${
                              roomsPage === 1
                                ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                                : 'bg-blue-600 text-white hover:bg-blue-700'
                            }`}
                          >
                            Previous
                          </button>
                          <button
                            onClick={() => handlePageChange("rooms", true)}
                            disabled={roomsPage === getPageItems(rooms, roomsPage).totalPages}
                            className={`px-3 py-1 rounded ${
                              roomsPage === getPageItems(rooms, roomsPage).totalPages
                                ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                                : 'bg-blue-600 text-white hover:bg-blue-700'
                            }`}
                          >
                            Next
                          </button>
                        </div>
                      </div>
                    </>
                  )}

                  {activeTab === "customers" && (
                    <>
                      <table className="min-w-full bg-white">
                        <thead>
                          <tr>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Customer ID
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              First name
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Last name
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Address
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              ID Type
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              ID Number
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Registration Date
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Actions
                            </th>
                          </tr>
                        </thead>
                        <tbody>
                          {getPageItems(customers, customersPage).currentItems.map((customer) => (
                            <tr
                              key={customer.customer_id}
                              className="hover:bg-gray-50"
                            >
                              <td className="py-3 px-4 border-b border-gray-200">
                                {customer.customer_id}
                              </td>
                              <td className="py-3 px-4 border-b border-gray-200">
                                {customer.first_name}
                              </td>
                              <td className="py-3 px-4 border-b border-gray-200">
                                {customer.last_name}
                              </td>
                              <td className="py-3 px-4 border-b border-gray-200">
                                {customer.address}
                              </td>
                              <td className="py-3 px-4 border-b border-gray-200">
                                {customer.id_type}
                              </td>
                              <td className="py-3 px-4 border-b border-gray-200">
                                {customer.id_number}
                              </td>
                              <td className="py-3 px-4 border-b border-gray-200">
                                {customer.registration_date}
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
                      <div className="mt-4 flex items-center justify-between px-4">
                        <div className="text-sm text-gray-500">
                          Showing {getPageItems(customers, customersPage).startIndex + 1}-
                          {Math.min(getPageItems(customers, customersPage).endIndex, customers.length)} of {customers.length} entries
                        </div>
                        <div className="flex space-x-2">
                          <button
                            onClick={() => handlePageChange("customers", false)}
                            disabled={customersPage === 1}
                            className={`px-3 py-1 rounded ${
                              customersPage === 1
                                ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                                : 'bg-blue-600 text-white hover:bg-blue-700'
                            }`}
                          >
                            Previous
                          </button>
                          <button
                            onClick={() => handlePageChange("customers", true)}
                            disabled={customersPage === getPageItems(customers, customersPage).totalPages}
                            className={`px-3 py-1 rounded ${
                              customersPage === getPageItems(customers, customersPage).totalPages
                                ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                                : 'bg-blue-600 text-white hover:bg-blue-700'
                            }`}
                          >
                            Next
                          </button>
                        </div>
                      </div>
                    </>
                  )}

                  {activeTab === "employees" && (
                    <>
                      <table className="min-w-full bg-white">
                        <thead>
                          <tr>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              SSN
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Hotel ID
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              First Name
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Last Name
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Address
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Role
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Actions
                            </th>
                          </tr>
                        </thead>
                        <tbody>
                          {getPageItems(employees, employeesPage).currentItems.map((employee) => (
                            <tr key={employee.ssn} className="hover:bg-gray-50">
                              <td className="py-3 px-4 border-b border-gray-200">
                                {employee.ssn}
                              </td>
                              <td className="py-3 px-4 border-b border-gray-200">
                                {employee.hotel_id}
                              </td>
                              <td className="py-3 px-4 border-b border-gray-200">
                                {employee.first_name}
                              </td>
                              <td className="py-3 px-4 border-b border-gray-200">
                                {employee.last_name}
                              </td>
                              <td className="py-3 px-4 border-b border-gray-200">
                                {employee.address}
                              </td>
                              <td className="py-3 px-4 border-b border-gray-200">
                                {employee.role}
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
                      <div className="mt-4 flex items-center justify-between px-4">
                        <div className="text-sm text-gray-500">
                          Showing {getPageItems(employees, employeesPage).startIndex + 1}-
                          {Math.min(getPageItems(employees, employeesPage).endIndex, employees.length)} of {employees.length} entries
                        </div>
                        <div className="flex space-x-2">
                          <button
                            onClick={() => handlePageChange("employees", false)}
                            disabled={employeesPage === 1}
                            className={`px-3 py-1 rounded ${
                              employeesPage === 1
                                ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                                : 'bg-blue-600 text-white hover:bg-blue-700'
                            }`}
                          >
                            Previous
                          </button>
                          <button
                            onClick={() => handlePageChange("employees", true)}
                            disabled={employeesPage === getPageItems(employees, employeesPage).totalPages}
                            className={`px-3 py-1 rounded ${
                              employeesPage === getPageItems(employees, employeesPage).totalPages
                                ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                                : 'bg-blue-600 text-white hover:bg-blue-700'
                            }`}
                          >
                            Next
                          </button>
                        </div>
                      </div>
                    </>
                  )}

                  {activeTab === "bookings" && (
                    <>
                      <table className="min-w-full bg-white">
                        <thead>
                          <tr>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Booking ID
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Customer ID
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Start Date
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              End Date
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Room ID
                            </th>
                            <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                              Actions
                            </th>
                          </tr>
                        </thead>
                        <tbody>
                          {getPageItems(bookingsList, bookingsListPage).currentItems.map((booking) => (
                            <tr
                              key={booking.booking_id}
                              className="hover:bg-gray-50"
                            >
                              <td className="py-3 px-4 border-b border-gray-200">
                                {booking.booking_id}
                              </td>
                              <td className="py-3 px-4 border-b border-gray-200">
                                {booking.customer_id}
                              </td>
                              <td className="py-3 px-4 border-b border-gray-200">
                                {booking.start_date}
                              </td>
                              <td className="py-3 px-4 border-b border-gray-200">
                                {booking.end_date}
                              </td>
                              <td className="py-3 px-4 border-b border-gray-200">
                                {booking.room_id}
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
                      <div className="mt-4 flex items-center justify-between px-4">
                        <div className="text-sm text-gray-500">
                          Showing {getPageItems(bookingsList, bookingsListPage).startIndex + 1}-
                          {Math.min(getPageItems(bookingsList, bookingsListPage).endIndex, bookingsList.length)} of {bookingsList.length} entries
                        </div>
                        <div className="flex space-x-2">
                          <button
                            onClick={() => handlePageChange("bookings", false)}
                            disabled={bookingsListPage === 1}
                            className={`px-3 py-1 rounded ${
                              bookingsListPage === 1
                                ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                                : 'bg-blue-600 text-white hover:bg-blue-700'
                            }`}
                          >
                            Previous
                          </button>
                          <button
                            onClick={() => handlePageChange("bookings", true)}
                            disabled={bookingsListPage === getPageItems(bookingsList, bookingsListPage).totalPages}
                            className={`px-3 py-1 rounded ${
                              bookingsListPage === getPageItems(bookingsList, bookingsListPage).totalPages
                                ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                                : 'bg-blue-600 text-white hover:bg-blue-700'
                            }`}
                          >
                            Next
                          </button>
                        </div>
                      </div>
                    </>
                  )}
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
                      {customers.map((customer) => (
                        <option key={customer.customer_id} value={customer.customer_id}>
                          {customer.first_name} {customer.last_name}
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
                      {hotelRecords.map((hotel) => (
                        <option key={hotel.hotel_id} value={hotel.hotel_id}>
                          {hotel.hotel_id}
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
                      {rooms.map((room) => (
                        <option key={room.room_id} value={room.room_id}>
                          Room {room.room_id} - {room.capacity}
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
                      {employees.map((employee) => (
                        <option key={employee.ssn} value={employee.ssn}>
                          {employee.first_name} {employee.last_name} - {employee.role}
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
                <div className="mb-4 space-y-4">
                  <div className="flex space-x-4">
                    <div className="flex-1">
                      <input
                        type="text"
                        placeholder="Search rooms..."
                        value={roomSearchQuery}
                        onChange={handleRoomSearchChange}
                        className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                      />
                    </div>
                    <div>
                      <select
                        value={roomFilters.capacity}
                        onChange={(e) => handleRoomFilterChange("capacity", e.target.value)}
                        className="border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                      >
                        <option value="">All Capacities</option>
                        <option value="single">Single</option>
                        <option value="double">Double</option>
                        <option value="triple">Triple</option>
                        <option value="quad">Quad</option>
                        <option value="suite">Suite</option>
                      </select>
                    </div>
                    <div>
                      <select
                        value={roomFilters.view}
                        onChange={(e) => handleRoomFilterChange("view", e.target.value)}
                        className="border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                      >
                        <option value="">All Views</option>
                        <option value="sea">Sea View</option>
                        <option value="mountain">Mountain View</option>
                        <option value="city">City View</option>
                        <option value="garden">Garden View</option>
                        <option value="none">No View</option>
                      </select>
                    </div>
                  </div>
                  <div className="flex space-x-4">
                    <div>
                      <input
                        type="number"
                        placeholder="Min Price"
                        value={roomFilters.minPrice}
                        onChange={(e) => handleRoomFilterChange("minPrice", e.target.value)}
                        className="border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                      />
                    </div>
                    <div>
                      <input
                        type="number"
                        placeholder="Max Price"
                        value={roomFilters.maxPrice}
                        onChange={(e) => handleRoomFilterChange("maxPrice", e.target.value)}
                        className="border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                      />
                    </div>
                  </div>
                </div>
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
                          View
                        </th>
                        <th className="py-2 px-4 border-b border-gray-200 bg-gray-50 text-left text-sm font-semibold text-gray-700">
                          Extendable
                        </th>
                        <th className="py-2 px-4 border-b border-gray-200 bg-gray-50 text-left text-sm font-semibold text-gray-700">
                          Status
                        </th>
                        <th className="py-2 px-4 border-b border-gray-200 bg-gray-50 text-left text-sm font-semibold text-gray-700">
                          Actions
                        </th>
                      </tr>
                    </thead>
                    <tbody>
                      {currentAvailableRooms.map((room) => (
                        <tr key={room.room_id} className="hover:bg-gray-50">
                          <td className="py-2 px-4 border-b border-gray-200">
                            {room.room_id}
                          </td>
                          <td className="py-2 px-4 border-b border-gray-200">
                            {hotelRecords.find((h) => h.hotel_id === room.hotel_id)
                              ?.hotel_id || ""}
                          </td>
                          <td className="py-2 px-4 border-b border-gray-200">
                            {room.capacity}
                          </td>
                          <td className="py-2 px-4 border-b border-gray-200">
                            ${room.price}/night
                          </td>
                          <td className="py-2 px-4 border-b border-gray-200">
                            {room.view}
                          </td>
                          <td className="py-2 px-4 border-b border-gray-200">
                            {room.extendable ? "Yes" : "No"}
                          </td>
                          <td className="py-2 px-4 border-b border-gray-200">
                            {room.status}
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
                  <div className="mt-4 flex items-center justify-between">
                    <div className="text-sm text-gray-500">
                      Showing {availableRoomsStartIndex + 1}-{Math.min(availableRoomsEndIndex, filteredRooms.length)} of {filteredRooms.length} entries
                    </div>
                    <div className="flex space-x-2">
                      <button
                        onClick={handleAvailableRoomsPrevPage}
                        disabled={availableRoomsPage === 1}
                        className={`px-3 py-1 rounded ${
                          availableRoomsPage === 1
                            ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                            : 'bg-blue-600 text-white hover:bg-blue-700'
                        }`}
                      >
                        Previous
                      </button>
                      <button
                        onClick={handleAvailableRoomsNextPage}
                        disabled={availableRoomsPage === availableRoomsTotalPages}
                        className={`px-3 py-1 rounded ${
                          availableRoomsPage === availableRoomsTotalPages
                            ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                            : 'bg-blue-600 text-white hover:bg-blue-700'
                        }`}
                      >
                        Next
                      </button>
                    </div>
                  </div>
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
                            {hotelChains.map((chain) => (
                              <option key={chain.chain_id} value={chain.chain_id}>
                                {chain.chain_id}
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
                            {hotelRecords.map((hotel) => (
                              <option key={hotel.hotel_id} value={hotel.hotel_id}>
                                {hotel.hotel_id}
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
                            {customers.map((customer) => (
                              <option key={customer.customer_id} value={customer.customer_id}>
                                {customer.first_name} {customer.last_name}
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
                            {hotelRecords.map((hotel) => (
                              <option key={hotel.hotel_id} value={hotel.hotel_id}>
                                {hotel.hotel_id}
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
                            {rooms.map((room) => (
                              <option key={room.room_id} value={room.room_id}>
                                Room {room.room_id} - {room.capacity}
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
                            {customers.map((customer) => (
                              <option key={customer.customer_id} value={customer.customer_id}>
                                {customer.first_name} {customer.last_name}
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
                            {hotelRecords.map((hotel) => (
                              <option key={hotel.hotel_id} value={hotel.hotel_id}>
                                {hotel.hotel_id}
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
                            {rooms.map((room) => (
                              <option key={room.room_id} value={room.room_id}>
                                Room {room.room_id} - {room.capacity}
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
                            {employees.map((employee) => (
                              <option key={employee.ssn} value={employee.ssn}>
                                {employee.first_name} {employee.last_name} - {employee.role}
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
                            {bookingsList.map((booking) => {
                              const customer = customers.find(
                                (c) => c.customer_id === booking.customer_id
                              );
                              const room = rooms.find(
                                (r) => r.room_id === booking.room_id
                              );
                              return (
                                <option key={booking.booking_id} value={booking.booking_id}>
                                  {customer ? `${customer.first_name} ${customer.last_name}` : "Unknown"} - Room{" "}
                                  {room ? room.room_id : "Unknown"} ({booking.start_date} to {booking.end_date})
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
                            {employees.map((employee) => (
                              <option key={employee.ssn} value={employee.ssn}>
                                {employee.first_name} {employee.last_name} - {employee.role}
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
