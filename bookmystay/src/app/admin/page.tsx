'use client';
import PaymentModal from './PaymentModal'
import React, { useEffect, useState } from 'react';
import Link from 'next/link';
import Head from 'next/head';
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
} from 'lucide-react';

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

const mockHotels: Hotel[] = [
  {
    id: 101,
    name: 'Luxury Stays Downtown',
    chain: 'Luxury Stays',
    category: '5-star',
    rooms: 120,
    address: '789 Main St, New York, NY',
    email: 'downtown@luxurystays.com',
    phone: '212-555-2345',
  },
  {
    id: 102,
    name: 'Luxury Stays Central Park',
    chain: 'Luxury Stays',
    category: '4-star',
    rooms: 95,
    address: '456 Park Ave, New York, NY',
    email: 'centralpark@luxurystays.com',
    phone: '212-555-3456',
  },
  {
    id: 201,
    name: 'ComfortInn Lakeview',
    chain: 'ComfortInn Group',
    category: '3-star',
    rooms: 85,
    address: '123 Lake Dr, Chicago, IL',
    email: 'lakeview@comfortinn.com',
    phone: '312-555-7890',
  },
];

const mockRooms: Room[] = [
  {
    id: 10101,
    hotelId: 101,
    number: '101',
    price: 350,
    capacity: 'double',
    amenities: 'TV, AC, fridge, wifi',
    view: 'sea',
    extendable: true,
    issues: 'None',
  },
  {
    id: 10102,
    hotelId: 101,
    number: '102',
    price: 275,
    capacity: 'single',
    amenities: 'TV, AC, wifi',
    view: 'city',
    extendable: false,
    issues: 'None',
  },
  {
    id: 10103,
    hotelId: 101,
    number: '103',
    price: 400,
    capacity: 'double',
    amenities: 'TV, AC, fridge, minibar, wifi',
    view: 'sea',
    extendable: true,
    issues: 'Minor plumbing issue',
  },
];

const mockCustomers: Customer[] = [
  {
    id: 1001,
    name: 'John Smith',
    address: '123 Maple St, Boston, MA',
    idType: 'SSN',
    idNumber: 'XXX-XX-1234',
    regDate: '2024-01-15',
  },
  {
    id: 1002,
    name: 'Emily Johnson',
    address: '456 Oak Ave, Miami, FL',
    idType: 'Driving License',
    idNumber: 'FL12345678',
    regDate: '2024-02-10',
  },
];

const mockEmployees: Employee[] = [
  {
    id: 2001,
    name: 'Michael Brown',
    address: '789 Pine Rd, New York, NY',
    ssn: 'XXX-XX-5678',
    hotel: 'Luxury Stays Downtown',
    position: 'Manager',
  },
  {
    id: 2002,
    name: 'Sarah Davis',
    address: '321 Cedar St, New York, NY',
    ssn: 'XXX-XX-8765',
    hotel: 'Luxury Stays Downtown',
    position: 'Receptionist',
  },
];

const mockBookings: Booking[] = [
  {
    id: 3001,
    customerId: 1001,
    roomId: 10101,
    startDate: '2025-04-01',
    endDate: '2025-04-05',
    status: 'Confirmed',
  },
  {
    id: 3002,
    customerId: 1002,
    roomId: 10103,
    startDate: '2025-03-25',
    endDate: '2025-03-30',
    status: 'Confirmed',
  },
];

const AdminDashboard: React.FC = () => {
  const [page, setPage] = useState(1);
  const [page2, setPage2] = useState(1);
  const recordsPerPage = 10;

  const [hotelChainData, setHotelChainData] = useState({
    hotelChains: [],
    nextChainID: '',
    nextHotelID: '',
  });

  const [formData, setFormData] = useState({
    hotelChain: 'CH001',
    category: 1,
    address: '',
    email: '',
    roomID: '',
    price: '',
    capacity: 'SINGLE',
    view: 'City View',
    extendable: false,
    roomHotel: 'HTL00100',
    customerID: '',
    customerFirstName: '',
    customerLastName: '',
    customerAddress: '',
    customerIDType: 'DRIVING_LICENSE',
    customerIDNumber: '',
    date: new Date().toISOString(),
    ssn: '',
    employeeFirstName: '',
    employeeLastName: '',
    employeeAddress: '',
    employeeRole: 'Receptionist',
    employeeHotelID: 'HTL00100',
    centralOfficeAddress: '',
  });

  const [bookingData, setBookingData] = useState({
    customer: 'CUST3088',
    room: 'RM0010102',
    startDate: '',
    endDate: '',
    hotel: 'HTL00100',
  });

  const [rentalData, setRentalData] = useState({
    customer: 'CUST3088',
    room: 'RM0010102',
    startDate: '',
    endDate: '',
    hotel: 'HTL00100',
  });

  const [isPaymentModalOpen, setIsPaymentModalOpen] = useState(false);
  const [rooms, setRooms] = useState([]);
  const [rentings, setRentings] = useState([]);
  const [managers, setManagers] = useState([]);
  const [availableRooms, setAvailableRooms] = useState([]);
  const [employees, setEmployees] = useState([]);
  const [bookingsList, setBookingsList] = useState([]);
  const [customers, setCustomers] = useState([]);
  const [hotelRecords, setHotelRecords] = useState([]);
  const [hotelChainCount, setHotelChainCount] = useState('...');
  const [hotelCount, setHotelCount] = useState('...');
  const [customerCount, setCustomerCount] = useState('...');
  const [bookings, setBookings] = useState('...');
  const [hotelCapacity, setHotelCapacity] = useState([]);
  const [availableRoomsPerArea, setAvailableRoomsPerArea] = useState([]);
  const [activeTab, setActiveTab] = useState<string>('hotelchains');
  const [showAddModal, setShowAddModal] = useState<boolean>(false);
  const [showBookingModal, setShowBookingModal] = useState<boolean>(false);
  const [hotelIDs, setHotelIDs] = useState([]);
  const [roomIDs, setRoomIDs] = useState([]);
  const [modalType, setModalType] = useState<string>('');
  const [hotelIDList, setHotelIDList] = useState('');
  const [customerIDList, setCustomerIDList] = useState([]);
  const [editModalOpen, setEditModalOpen] = useState(false);
  const [editHotelData, setEditHotelData] = useState({
    chain_id: '',
    hotel_id: '',
    address: '',
    num_rooms: '',
    contact_email: '',
    starcategory: '',
  });
  const [editRoomData, setEditRoomData] = useState({
    room_id: '',
    hotel_id: '',
    price: '',
    capacity: '',
    view: '',
    extendable: '',
    status: '',
  });
  const [editEmployeeData, setEditEmployeeData] = useState({
    ssn: '',
    hotel_id: '',
    first_name: '',
    last_name: '',
    address: '',
    role: '',
  });
  const [editCustomerData, setEditCustomerData] = useState({
    customer_id: '',
    first_name: '',
    last_name: '',
    address: '',
    id_type: '',
    id_number: '',
  });

  const handleEditHotel = (chain_id, hotel_id, address, num_rooms, contact_email, starcategory) => {
    setEditHotelData({
      chain_id: chain_id,
      hotel_id: hotel_id,
      address: address,
      num_rooms: num_rooms,
      contact_email: contact_email,
      starcategory: starcategory,
    });
    openEditModal('hotel');
  };

  const handleEditCustomer = (customer_id, first_name, last_name, address, id_type, id_number) => {
    setEditCustomerData({
      customer_id: customer_id,
      first_name: first_name,
      last_name: last_name,
      address: address,
      id_type: id_type,
      id_number: id_number,
    });
    openEditModal('customer');
  };

  const handleEditEmployee = (ssn, hotel_id, first_name, last_name, address, role) => {
    setEditEmployeeData({
      ssn: ssn,
      hotel_id: hotel_id,
      first_name: first_name,
      last_name: last_name,
      address: address,
      role: role,
    });
    openEditModal('employee');
  };

  const handleEditRoom = (room_id, hotel_id, price, capacity, view, extendable, status) => {
    setEditRoomData({
      room_id: room_id,
      hotel_id: hotel_id,
      price: price,
      capacity: capacity,
      view: view,
      extendable: extendable,
      status: status,
    });
    openEditModal('room');
  };

  const fetchHotelChainIDs = async () => {
    try {
      const response = await fetch('/api/hotel_chain');
      if (response.ok) {
        const data = await response.json();
        setHotelIDs(data); // Store the hotel ids from the response
      } else {
        throw new Error('Failed to fetch hotel ids');
      }
    } catch (error) {
      console.log(error.message);
    }
  };

  const fetchHotelRoomIDs = async () => {
    try {
      const response = await fetch('/api/room_id');
      if (response.ok) {
        const data = await response.json();
        setRoomIDs(data); // Store the hotel ids from the response
      } else {
        throw new Error('Failed to fetch hotel ids');
      }
    } catch (error) {
      console.log(error.message);
    }
  };

  const fetchHotelIds = async () => {
    try {
      const response = await fetch('/api/hotel_id');
      if (response.ok) {
        const data = await response.json();
        setHotelIDList(data); // Store the hotel ids from the response
      } else {
        throw new Error('Failed to fetch hotel ids');
      }
    } catch (error) {
      console.log(error.message);
    }
  };

  const fetchCustomerIDs = async () => {
    try {
      const response = await fetch('/api/customer_names');
      if (response.ok) {
        const data = await response.json();
        setCustomerIDList(data); // Store the hotel ids from the response
      } else {
        throw new Error('Failed to fetch hotel ids');
      }
    } catch (error) {
      console.log(error.message);
    }
  };

  const fetchHotelChainCount = async () => {
    try {
      const response = await fetch('/api/getHotelChainCount'); // Correct route
      if (response.ok) {
        const data = await response.json();
        setHotelChainCount(data.total); // Store the row count in state
      } else {
        throw new Error('Failed to fetch row count');
      }
    } catch (error) {
      console.log(error);
    }
  };

  const fetchAvailableRoomsPerArea = async () => {
    try {
      const response = await fetch('/api/getAvailableRoomsPerArea'); // Call the backend route
      if (response.ok) {
        const data = await response.json();
        setAvailableRoomsPerArea(data); // Store the table data in state
      } else {
        throw new Error('Failed to fetch rooms');
      }
    } catch (error) {
      console.log(error);
    }
  };

  const fetchAvailableRooms = async () => {
    const availRoomsQuery = `
    select * from room where status = 'Available'
  `;
    try {
      // Send the query to the backend via GET request
      const response = await fetch(`/api/data?query=${encodeURIComponent(availRoomsQuery)}`);

      if (response.ok) {
        const jsonData = await response.json();
        setAvailableRooms(jsonData); // Store the data in state
      } else {
        throw new Error('Failed to fetch data');
      }
    } catch (error) {
      console.log(error.message); // Set the error message
    }
  };

  const fetchFromDB = async query => {
    try {
      console.log(query);
      const response = await fetch(`/api/data?query=${encodeURIComponent(query)}`);

      if (!response.ok) {
        throw new Error(`Failed to fetch data: ${response.statusText}`);
      }

      const data = await response.json();
      return data; // Return the fetched data
    } catch (error) {
      console.error('Error:', error.message);
      throw error; // Rethrow the error for handling
    }
  };

  const nextHotelChainId = async () => {
    const query = `SELECT chain_id 
    FROM hotelchain
    ORDER BY CAST(SUBSTRING(chain_id FROM 3) AS INTEGER) DESC
    LIMIT 1;
    `;

    try {
      const result = await fetchFromDB(query); // Use the reusable fetch function
      if (result.length === 0) {
        return 'CH001'; // Default if no chains exist
      }

      const lastChainID = result[0].chain_id; // e.g., CH110
      const numPart = parseInt(lastChainID.slice(2), 10); // Extract numeric part -> 110
      const nextNum = numPart + 1; // Increment -> 111

      // Format the new ID with leading zeros
      const nextChain = `CH${String(nextNum).padStart(3, '0')}`;

      setHotelChainData({ ...hotelChainData, nextChainID: nextChain }); // Update the state
    } catch (error) {
      console.error('Error generating next chain ID:', error.message);
      throw error;
    }
  };

  const nextHotelId = async () => {
    const query = `SELECT hotel_id 
    FROM hotel
    ORDER BY CAST(SUBSTRING(hotel_id FROM 4) AS INTEGER) DESC
    LIMIT 1;
    `;

    try {
      const result = await fetchFromDB(query); // Use the reusable fetch function
      if (result.length === 0) {
        return 'HTL00001'; // Default if no hotels exist
      }

      const lastHotelID = result[0].hotel_id; // e.g., HTL00033
      const numPart = parseInt(lastHotelID.slice(3), 10); // Extract numeric part -> 110
      const nextNum = numPart + 1; // Increment -> 111

      // Format the new ID with leading zeros
      const nextHotel = `HTL${String(nextNum).padStart(5, '0')}`;
      setHotelChainData({ ...hotelChainData, nextHotelID: nextHotel }); // Update the state
    } catch (error) {
      console.error('Error generating next Hotel ID:', error.message);
      throw error;
    }
  };

  const fetchHotelCapacity = async () => {
    try {
      const response = await fetch('/api/getRoomCapacityPerHotel'); // Call the backend route
      if (response.ok) {
        const data = await response.json();
        setHotelCapacity(data); // Store the table data in state
      } else {
        throw new Error('Failed to fetch rooms');
      }
    } catch (error) {
      console.log(error);
    }
  };

  const fetchBookings = async () => {
    try {
      const response = await fetch('/api/getBookings'); // Correct route
      if (response.ok) {
        const data = await response.json();
        setBookings(data.total); // Store the row count in state
      } else {
        throw new Error('Failed to fetch row count');
      }
    } catch (error) {
      console.log(error);
    }
  };

  const fetchHotelCount = async () => {
    try {
      const response = await fetch('/api/getHotelCount'); // Correct route
      if (response.ok) {
        const data = await response.json();
        setHotelCount(data.total); // Store the row count in state
      } else {
        throw new Error('Failed to fetch row count');
      }
    } catch (error) {
      console.log(error);
    }
  };

  const fetchHotels = async () => {
    try {
      const response = await fetch('/api/getHotels'); // Correct route
      if (response.ok) {
        const data = await response.json();
        setHotelRecords(data);
      } else {
        throw new Error('Failed to fetch row count');
      }
    } catch (error) {
      console.log(error);
    }
  };

  const runQuery = async (query, values = []) => {
    try {
      const response = await fetch('/api/runQuery', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ query, values }),
      });

      if (!response.ok) {
        throw new Error('Failed to run query');
      }

      const result = await response.json();
      return result;
    } catch (error) {
      console.error('Error:', error);
      throw error;
    }
  };

  const handleNewCustomer = async () => {
    if (
      !formData.customerID ||
      !formData.customerFirstName ||
      !formData.customerLastName ||
      !formData.customerAddress ||
      !formData.customerIDType ||
      !formData.customerIDNumber
    ) {
      alert('Please fill in all fields');
      console.log(
        formData.customerID,
        formData.customerFirstName,
        formData.customerLastName,
        formData.customerAddress,
        formData.customerIDType,
        formData.customerIDNumber,
      );
      return;
    }

    const query = `
    INSERT INTO customer (customer_id, first_name, last_name, address, id_type, id_number, registration_date)
    VALUES ($1, $2, $3, $4, $5, $6, $7)
  `;

    const values = [
      formData.customerID,
      formData.customerFirstName,
      formData.customerLastName,
      formData.customerAddress,
      formData.customerIDType,
      formData.customerIDNumber,
      formData.date,
    ];

    try {
      const result = await runQuery(query, values);
      console.log('Added new customer:', result);
      setShowAddModal(false);
      fetchCustomers();
      fetchCustomerCount();
    } catch (error) {
      console.error('Error:', error);
    }
  };

  const handleNewBooking = async () => {
    if (
      !bookingData.customer ||
      !bookingData.room ||
      !bookingData.startDate ||
      !bookingData.endDate ||
      !bookingData.hotel
    ) {
      alert('Please fill in all fields');
      console.log(
        bookingData.customer,
        bookingData.room,
        bookingData.startDate,
        bookingData.endDate,
        bookingData.hotel,
      );
      return;
    }

    const query = `
    INSERT INTO booking (booking_id, customer_id, start_date, end_date, room_id)
    VALUES ($1, $2, $3, $4, $5)
  `;
    const booking_id = Math.floor(Math.random() * 9000) + 1000;
    const values = [
      booking_id,
      bookingData.customer,
      bookingData.startDate,
      bookingData.endDate,
      bookingData.room,
    ];

    try {
      const result = await runQuery(query, values);
      console.log('Added new booking:', result);
      setShowBookingModal(false);
      fetchBookingList();
      fetchBookings();
    } catch (error) {
      console.error('Error:', error);
    }
  };

  const handleNewRental = async () => {
    if (
      !rentalData.customer ||
      !rentalData.room ||
      !rentalData.startDate ||
      !rentalData.endDate ||
      !rentalData.hotel
    ) {
      alert('Please fill in all fields');
      console.log(
        rentalData.customer,
        rentalData.room,
        rentalData.startDate,
        rentalData.endDate,
        rentalData.hotel,
      );
      return;
    }

    const query = `
    INSERT INTO rental (rental_id, customer_id, check_in_date, check_out_date, room_id)
    VALUES ($1, $2, $3, $4, $5)
  `;
    const rental_id = Math.floor(Math.random() * 9000) + 1000;
    const values = [
      rental_id,
      rentalData.customer,
      rentalData.startDate,
      rentalData.endDate,
      rentalData.room,
    ];

    try {
      const result = await runQuery(query, values);
      console.log('Added new rental:', result);
      setShowBookingModal(false);
      fetchRentings();
    } catch (error) {
      console.error('Error:', error);
    }
  };

  const handleNewEmployee = async () => {
    if (
      !formData.ssn ||
      !formData.employeeHotelID ||
      !formData.employeeRole ||
      !formData.employeeFirstName ||
      !formData.employeeLastName ||
      !formData.employeeAddress
    ) {
      alert('Please fill in all fields');
      console.log(
        formData.ssn,
        formData.employeeHotelID,
        formData.employeeRole,
        formData.employeeFirstName,
        formData.employeeLastName,
        formData.employeeAddress,
      );
      return;
    }

    const query = `
    INSERT INTO employee (ssn, hotel_id, first_name, last_name, address, role)
    VALUES ($1, $2, $3, $4, $5, $6)
  `;

    const values = [
      formData.ssn,
      formData.employeeHotelID,
      formData.employeeFirstName,
      formData.employeeLastName,
      formData.employeeAddress,
      formData.employeeRole,
    ];

    try {
      const result = await runQuery(query, values);
      console.log('Added new employee:', result);
      setShowAddModal(false);
      fetchEmployees();
    } catch (error) {
      console.error('Error:', error);
    }
  };

  const handleNewRoom = async () => {
    if (!formData.roomID || !formData.price || !formData.capacity || !formData.view) {
      alert('Please fill in all fields');
      return;
    }

    const query = `
    INSERT INTO room (room_id, hotel_id, price, capacity, view, extendable, status)
    VALUES ($1, $2, $3, $4, $5, $6, $7)
  `;

    const values = [
      formData.roomID,
      formData.roomHotel,
      formData.price,
      formData.capacity,
      formData.view,
      formData.extendable,
      'Available',
    ];

    try {
      const result = await runQuery(query, values);
      console.log('Added new room:', result);
      setShowAddModal(false);
      fetchRooms();
    } catch (error) {
      console.error('Error:', error);
    }
  };

  const handleNewChain = async () => {
    if (!formData.centralOfficeAddress || !hotelChainData.nextChainID) {
      alert('Please fill in all fields');
      return;
    }

    const query = `
    INSERT INTO hotelchain (chain_id, num_hotels, central_office_address)
    VALUES ($1, $2, $3)
  `;

    const values = [hotelChainData.nextChainID, 1, formData.centralOfficeAddress];

    try {
      const result = await runQuery(query, values);
      console.log('Added hotel chain:', result);
      setShowAddModal(false);
      fetchHotelChains();
      fetchHotelChainIDs();
      fetchHotelIds();
    } catch (error) {
      console.error('Error:', error);
    }
  };

  const handleNewHotel = async () => {
    if (
      !formData.address ||
      !formData.category ||
      !formData.email ||
      !formData.hotelChain ||
      !hotelChainData.nextHotelID
    ) {
      alert('Please fill in all fields');
      console.log(
        formData.address,
        formData.category,
        formData.email,
        formData.hotelChain,
        hotelChainData.nextHotelID,
      );
      return;
    }

    const query = `
    INSERT INTO hotel (hotel_id, chain_id, address, num_rooms, contact_email, star_category)
    VALUES ($1, $2, $3, $4, $5, $6)
  `;

    const values = [
      hotelChainData.nextHotelID,
      formData.hotelChain,
      formData.address,
      1,
      formData.email,
      formData.category,
    ];

    try {
      const result = await runQuery(query, values);
      console.log('Added hotel:', result);
      setShowAddModal(false);
      fetchHotels();
    } catch (error) {
      console.error('Error:', error);
    }
  };

  const handleSaveEdit = async table => {
    let query = '';
    let values = [];

    if (table == 'hotel') {
      query = `
      UPDATE hotel
      SET 
        address = $1,
        num_rooms = $2,
        contact_email = $3,
        star_category = $4
      WHERE 
        chain_id = $5 AND hotel_id = $6
    `;

      values = [
        editHotelData.address,
        editHotelData.num_rooms,
        editHotelData.contact_email,
        editHotelData.starcategory,
        editHotelData.chain_id,
        editHotelData.hotel_id,
      ];
    } else if (table == 'room') {
      query = `
      UPDATE room
      SET 
        price = $1,
        capacity = $2,
        view = $3,
        extendable = $4,
        status = $5
      WHERE 
        room_id = $6 AND hotel_id = $7
    `;
      values = [
        editRoomData.price,
        editRoomData.capacity,
        editRoomData.view,
        editRoomData.extendable,
        editRoomData.status,
        editRoomData.room_id,
        editRoomData.hotel_id,
      ];
    } else if (table == 'employee') {
      query = `
    UPDATE employee
    SET 
      first_name = $1,
      last_name = $2,
      address = $3,
      role = $4
    WHERE 
      ssn = $5 AND hotel_id = $6
    `;
      values = [
        editEmployeeData.first_name,
        editEmployeeData.last_name,
        editEmployeeData.address,
        editEmployeeData.role,
        editEmployeeData.ssn,
        editEmployeeData.hotel_id,
      ];
    } else if (table == 'customer') {
      query = `
    UPDATE customer
    SET 
      first_name = $1,
      last_name = $2,
      address = $3,
      id_type = $4,
      id_number = $5
    WHERE 
      customer_id = $6
    `;
      values = [
        editCustomerData.first_name,
        editCustomerData.last_name,
        editCustomerData.address,
        editCustomerData.id_type,
        editCustomerData.id_number,
        editCustomerData.customer_id,
      ];
    }

    try {
      console.log('Query:', query);
      console.log('Values:', values);
      const response = await fetch('/api/runQuery', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ query, values }),
      });

      if (response.ok) {
        console.log('Updated successfully!');
        fetchHotels(); // Refresh the data
        fetchRooms();
        fetchCustomers();
        fetchEmployees();
        setEditModalOpen(false); // Close the modal
      } else {
        console.error('Failed to update');
      }
    } catch (error) {
      console.error('Error saving:', error);
    }
  };

  const handleDelete = async (table, idColumn, id) => {
    if (!window.confirm('Are you sure you want to delete this record?')) return;

    try {
      const query = `DELETE FROM ${table} WHERE ${idColumn} = $1`; // SQL query
      const values = [id]; // Values to replace placeholders in the query

      const response = await fetch('/api/runQuery', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          query,
          values,
        }),
      });

      if (response.ok) {
        alert('Record deleted successfully!');
        fetchHotelChains(); // Refresh the data
        fetchEmployees();
        fetchHotels();
        fetchCustomers();
        fetchRooms();
        fetchHotelChainIDs();
        fetchHotelIds();
        fetchBookingList();
        fetchRentings();
      } else {
        const errorData = await response.json();
        console.error('Failed to delete:', errorData.message);
        alert('Failed to delete record.');
      }
    } catch (error) {
      console.error('Error deleting record:', error);
      alert('Error deleting record.');
    }
  };

  const handleConvert = async (booking_id, customer_id, start_date, end_date, room_id) => {
    if (!window.confirm('Are you sure you want to convert this record to a rental?')) return;

    try {
      let query = `DELETE FROM booking WHERE booking_id = $1`; // SQL query
      let values = [booking_id]; // Values to replace placeholders in the query

      const response = await fetch('/api/runQuery', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          query,
          values,
        }),
      });

      query = `
      INSERT INTO rental (rental_id, customer_id, check_in_date, check_out_date, room_id)
      VALUES ($1, $2, $3, $4, $5)
    `;
      const rental_id = Math.floor(Math.random() * 9000) + 1000;
      values = [rental_id, customer_id, start_date, end_date, room_id];

      const response2 = await fetch('/api/runQuery', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          query,
          values,
        }),
      });


      if (response.ok && response2.ok) {
        alert('Record converted successfully!');
        fetchBookingList();
        fetchRentings();
      } else {
        const errorData = await response.json();
        console.error('Failed to delete:', errorData.message);
        alert('Failed to delete record.');
      }
    } catch (error) {
      console.error('Error deleting record:', error);
      alert('Error deleting record.');
    }
  };

  const fetchManagers = async () => {
    try {
      const response = await fetch('/api/getManagers'); // Correct route
      if (response.ok) {
        const data = await response.json();
        setManagers(data);
      } else {
        throw new Error('Failed to fetch row count');
      }
    } catch (error) {
      console.log(error);
    }
  };

  const fetchRentings = async () => {
    try {
      const response = await fetch('/api/getRentings'); // Correct route
      if (response.ok) {
        const data = await response.json();
        setRentings(data);
      } else {
        throw new Error('Failed to fetch row count');
      }
    } catch (error) {
      console.log(error);
    }
  };

  const fetchEmployees = async () => {
    try {
      const response = await fetch('/api/getEmployees'); // Correct route
      if (response.ok) {
        const data = await response.json();
        setEmployees(data);
      } else {
        throw new Error('Failed to fetch row count');
      }
    } catch (error) {
      console.log(error);
    }
  };

  const fetchBookingList = async () => {
    try {
      const response = await fetch('/api/getBookingList'); // Correct route
      if (response.ok) {
        const data = await response.json();
        setBookingsList(data);
      } else {
        throw new Error('Failed to fetch row count');
      }
    } catch (error) {
      console.log(error);
    }
  };

  const fetchRooms = async () => {
    try {
      const response = await fetch('/api/getRooms'); // Correct route
      if (response.ok) {
        const data = await response.json();
        setRooms(data);
      } else {
        throw new Error('Failed to fetch row count');
      }
    } catch (error) {
      console.log(error);
    }
  };

  const fetchCustomers = async () => {
    try {
      const response = await fetch('/api/getCustomers'); // Correct route
      if (response.ok) {
        const data = await response.json();
        setCustomers(data);
      } else {
        throw new Error('Failed to fetch row count');
      }
    } catch (error) {
      console.log(error);
    }
  };

  const fetchHotelChains = async () => {
    try {
      const response = await fetch('/api/getHotelChains'); // Correct route
      if (response.ok) {
        const data = await response.json();
        setHotelChainData({ ...hotelChainData, hotelChains: data });
      } else {
        throw new Error('Failed to fetch row count');
      }
    } catch (error) {
      console.log(error);
    }
  };

  const fetchCustomerCount = async () => {
    try {
      const response = await fetch('/api/getCustomerCount'); // Correct route
      if (response.ok) {
        const data = await response.json();
        setCustomerCount(data.total); // Store the row count in state
      } else {
        throw new Error('Failed to fetch row count');
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
          fetchRentings(),
          fetchAvailableRoomsPerArea(),
          fetchManagers(),
          fetchHotelChainIDs(),
          fetchHotelIds(),
          fetchCustomerIDs(),
          fetchHotelRoomIDs(),
        ]);
      } catch (error) {
        console.log(error);
      }
    };

    fetchData();
  }, []);

  const openAddModal = (type: string) => {
    setModalType(type);
    nextHotelChainId();
    nextHotelId();
    setShowAddModal(true);
  };

  const openEditModal = (type: string) => {
    setModalType(type);
    setEditModalOpen(true);
  };

  const openBookingModal = (type: string) => {
    setModalType(type);
    setShowBookingModal(true);
  };

  return (
    <>
      <Head>
        <title>e-Hotels Admin Dashboard</title>
        <meta name="description" content="Admin dashboard for e-Hotels system" />
      </Head>
      <div className="flex flex-col h-screen bg-gray-100">
        {/* Header */}
        <header className="bg-blue-700 text-white p-4 shadow-md">
          <div className="flex justify-between items-center">
            <h1 className="text-2xl font-bold">e-Hotels Admin Dashboard</h1>
            <div className="flex items-center space-x-4">
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
                    onClick={() => setActiveTab('hotelchains')}
                  >
                    <Hotel className="h-5 w-5 mr-3" />
                    <span>Hotel Chains</span>
                  </Link>
                </li>
                <li className="px-6 py-3 hover:bg-gray-100">
                  <Link
                    href="#"
                    className="flex items-center"
                    onClick={() => setActiveTab('hotels')}
                  >
                    <Hotel className="h-5 w-5 mr-3" />
                    <span>Hotels</span>
                  </Link>
                </li>
                <li className="px-6 py-3 hover:bg-gray-100">
                  <Link
                    href="#"
                    className="flex items-center"
                    onClick={() => setActiveTab('rooms')}
                  >
                    <DollarSign className="h-5 w-5 mr-3" />
                    <span>Rooms</span>
                  </Link>
                </li>
                <li className="px-6 py-3 hover:bg-gray-100">
                  <Link
                    href="#"
                    className="flex items-center"
                    onClick={() => setActiveTab('customers')}
                  >
                    <Users className="h-5 w-5 mr-3" />
                    <span>Customers</span>
                  </Link>
                </li>
                <li className="px-6 py-3 hover:bg-gray-100">
                  <Link
                    href="#"
                    className="flex items-center"
                    onClick={() => setActiveTab('employees')}
                  >
                    <User className="h-5 w-5 mr-3" />
                    <span>Employees</span>
                  </Link>
                </li>
                <li className="px-6 py-3 hover:bg-gray-100">
                  <Link
                    href="#"
                    className="flex items-center"
                    onClick={() => setActiveTab('bookings')}
                  >
                    <BookOpen className="h-5 w-5 mr-3" />
                    <span>Bookings</span>
                  </Link>
                </li>
                <li className="px-6 py-3 hover:bg-gray-100">
                  <Link
                    href="#"
                    className="flex items-center"
                    onClick={() => setActiveTab('rentings')}
                  >
                    <Calendar className="h-5 w-5 mr-3" />
                    <span>Rentings</span>
                  </Link>
                </li>
                <li className="px-6 py-3 hover:bg-gray-100">
                  <Link
                    href="#"
                    className="flex items-center"
                    onClick={() => setActiveTab('managers')}
                  >
                    <FileText className="h-5 w-5 mr-3" />
                    <span>Managers</span>
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
                      <div className="text-xl font-semibold">{hotelChainCount}</div>
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
                      <div className="text-xl font-semibold">{customerCount}</div>
                    </div>
                  </div>
                </div>
                <div className="bg-white rounded-lg shadow p-4">
                  <div className="flex items-center">
                    <div className="p-3 rounded-full bg-yellow-100 text-yellow-600 mr-4">
                      <BookOpen className="h-6 w-6" />
                    </div>
                    <div>
                      <div className="text-sm text-gray-500">Active Bookings</div>
                      <div className="text-xl font-semibold">{bookings}</div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div className="mb-6">
              <div className="flex justify-between items-center mb-4">
                <h2 className="text-xl font-semibold">System Views</h2>
                <button className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
                onClick={async () => {
                  await fetchBookings();
                  await fetchHotelChainCount();
                  await fetchHotelCount();
                  await fetchCustomerCount(); // Wait for the fetchData promise to resolve
                }}>
                  Refresh Widgets
                </button>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {/* View 1: Available Rooms per Area */}
                <div className="bg-white rounded-lg shadow p-4">
                  <h3 className="text-lg font-semibold mb-3">View 1: Available Rooms per Area</h3>
                  {/* Table */}
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
                        {availableRoomsPerArea
                          .slice((page - 1) * recordsPerPage, page * recordsPerPage)
                          .map((item, index) => (
                            <tr key={index}>
                              <td className="py-2 px-4 border-b border-gray-200">{item.area}</td>
                              <td className="py-2 px-4 border-b border-gray-200">
                                {item.available_rooms}
                              </td>
                            </tr>
                          ))}
                      </tbody>
                    </table>
                  </div>

                  {/* Pagination Controls */}
                  <div className="flex justify-between items-center mt-4">
                    <button
                      onClick={() => setPage(prev => Math.max(prev - 1, 1))}
                      disabled={page === 1}
                      className={`px-4 py-2 rounded-md ${
                        page === 1
                          ? 'bg-gray-300 cursor-not-allowed'
                          : 'bg-blue-600 text-white hover:bg-blue-700'
                      }`}
                    >
                      Previous
                    </button>

                    <span className="text-sm text-gray-700">
                      Page {page} of {Math.ceil(availableRoomsPerArea.length / recordsPerPage)}
                    </span>

                    <button
                      onClick={() =>
                        setPage(prev =>
                          Math.min(
                            prev + 1,
                            Math.ceil(availableRoomsPerArea.length / recordsPerPage),
                          ),
                        )
                      }
                      disabled={page === Math.ceil(availableRoomsPerArea.length / recordsPerPage)}
                      className={`px-4 py-2 rounded-md ${
                        page === Math.ceil(availableRoomsPerArea.length / recordsPerPage)
                          ? 'bg-gray-300 cursor-not-allowed'
                          : 'bg-blue-600 text-white hover:bg-blue-700'
                      }`}
                    >
                      Next
                    </button>
                  </div>
                </div>

                {/* View 2: Aggregated Room Capacity per Hotel */}
                <div className="bg-white rounded-lg shadow p-4">
                  <h3 className="text-lg font-semibold mb-3">
                    View 2: Aggregated Room Capacity per Hotel
                  </h3>
                  {/* Table */}
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
                        {hotelCapacity
                          .slice((page2 - 1) * recordsPerPage, page2 * recordsPerPage)
                          .map((item, index) => (
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
                  </div>

                  {/* Pagination Controls */}
                  <div className="flex justify-between items-center mt-4">
                    <button
                      onClick={() => setPage2(prev => Math.max(prev - 1, 1))}
                      disabled={page2 === 1}
                      className={`px-4 py-2 rounded-md ${
                        page2 === 1
                          ? 'bg-gray-300 cursor-not-allowed'
                          : 'bg-blue-600 text-white hover:bg-blue-700'
                      }`}
                    >
                      Previous
                    </button>

                    <span className="text-sm text-gray-700">
                      Page {page2} of {Math.ceil(hotelCapacity.length / recordsPerPage)}
                    </span>

                    <button
                      onClick={() =>
                        setPage2(prev =>
                          Math.min(prev + 1, Math.ceil(hotelCapacity.length / recordsPerPage)),
                        )
                      }
                      disabled={page2 === Math.ceil(hotelCapacity.length / recordsPerPage)}
                      className={`px-4 py-2 rounded-md ${
                        page2 === Math.ceil(hotelCapacity.length / recordsPerPage)
                          ? 'bg-gray-300 cursor-not-allowed'
                          : 'bg-blue-600 text-white hover:bg-blue-700'
                      }`}
                    >
                      Next
                    </button>
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
                    onChange={e => setActiveTab(e.target.value)}
                  >
                    <option value="hotelchains">Hotel Chains</option>
                    <option value="hotels">Hotels</option>
                    <option value="rooms">Rooms</option>
                    <option value="customers">Customers</option>
                    <option value="employees">Employees</option>
                    <option value="bookings">Bookings</option>
                    <option value="rentings">Rentings</option>
                    <option value="managers">Managers</option>
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
                      activeTab === 'hotelchains'
                        ? 'text-blue-600 font-medium border-b-2 border-blue-600'
                        : 'text-gray-500 hover:text-blue-600'
                    }`}
                    onClick={() => setActiveTab('hotelchains')}
                  >
                    Hotel Chains
                  </button>
                  <button
                    className={`px-4 py-2 ${
                      activeTab === 'hotels'
                        ? 'text-blue-600 font-medium border-b-2 border-blue-600'
                        : 'text-gray-500 hover:text-blue-600'
                    }`}
                    onClick={() => setActiveTab('hotels')}
                  >
                    Hotels
                  </button>
                  <button
                    className={`px-4 py-2 ${
                      activeTab === 'rooms'
                        ? 'text-blue-600 font-medium border-b-2 border-blue-600'
                        : 'text-gray-500 hover:text-blue-600'
                    }`}
                    onClick={() => setActiveTab('rooms')}
                  >
                    Rooms
                  </button>
                  <button
                    className={`px-4 py-2 ${
                      activeTab === 'customers'
                        ? 'text-blue-600 font-medium border-b-2 border-blue-600'
                        : 'text-gray-500 hover:text-blue-600'
                    }`}
                    onClick={() => setActiveTab('customers')}
                  >
                    Customers
                  </button>
                  <button
                    className={`px-4 py-2 ${
                      activeTab === 'employees'
                        ? 'text-blue-600 font-medium border-b-2 border-blue-600'
                        : 'text-gray-500 hover:text-blue-600'
                    }`}
                    onClick={() => setActiveTab('employees')}
                  >
                    Employees
                  </button>
                  <button
                    className={`px-4 py-2 ${
                      activeTab === 'bookings'
                        ? 'text-blue-600 font-medium border-b-2 border-blue-600'
                        : 'text-gray-500 hover:text-blue-600'
                    }`}
                    onClick={() => setActiveTab('bookings')}
                  >
                    Bookings
                  </button>
                  <button
                    className={`px-4 py-2 ${
                      activeTab === 'rentings'
                        ? 'text-blue-600 font-medium border-b-2 border-blue-600'
                        : 'text-gray-500 hover:text-blue-600'
                    }`}
                    onClick={() => setActiveTab('rentings')}
                  >
                    Rentings
                  </button>
                  <button
                    className={`px-4 py-2 ${
                      activeTab === 'managers'
                        ? 'text-blue-600 font-medium border-b-2 border-blue-600'
                        : 'text-gray-500 hover:text-blue-600'
                    }`}
                    onClick={() => setActiveTab('managers')}
                  >
                    Managers
                  </button>
                </div>

                <div className="overflow-x-auto">
                  {activeTab === 'hotelchains' && (
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
                        {hotelChainData.hotelChains.map(chain => (
                          <tr key={chain.chain_id} className="hover:bg-gray-50">
                            <td className="py-3 px-4 border-b border-gray-200">{chain.chain_id}</td>
                            <td className="py-3 px-4 border-b border-gray-200">
                              {chain.num_hotels}
                            </td>
                            <td className="py-3 px-4 border-b border-gray-200">
                              {chain.central_office_address}
                            </td>

                            <td className="py-3 px-4 border-b border-gray-200">
                              <div className="flex space-x-2">
                                <button
                                  className="p-1 bg-red-100 text-red-700 rounded hover:bg-red-200"
                                  onClick={() =>
                                    handleDelete('hotelchain', 'chain_id', chain.chain_id)
                                  }
                                >
                                  <Trash2 size={16} />
                                </button>
                              </div>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  )}

                  {activeTab === 'hotels' && (
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
                        {hotelRecords.map(hotel => (
                          <tr key={hotel.hotel_id} className="hover:bg-gray-50">
                            <td className="py-3 px-4 border-b border-gray-200">{hotel.chain_id}</td>
                            <td className="py-3 px-4 border-b border-gray-200">{hotel.hotel_id}</td>
                            <td className="py-3 px-4 border-b border-gray-200">{hotel.address}</td>
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
                                <button
                                  className="p-1 bg-blue-100 text-blue-700 rounded hover:bg-blue-200"
                                  onClick={() =>
                                    handleEditHotel(
                                      hotel.chain_id,
                                      hotel.hotel_id,
                                      hotel.address,
                                      hotel.num_rooms,
                                      hotel.contact_email,
                                      hotel.star_category,
                                    )
                                  }
                                >
                                  <Edit size={16} />
                                </button>
                                <button
                                  className="p-1 bg-red-100 text-red-700 rounded hover:bg-red-200"
                                  onClick={() => handleDelete('hotel', 'hotel_id', hotel.hotel_id)}
                                >
                                  <Trash2 size={16} />
                                </button>
                              </div>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  )}

                  {activeTab === 'rooms' && (
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
                        {rooms.map(room => (
                          <tr key={room.room_id} className="hover:bg-gray-50">
                            <td className="py-3 px-4 border-b border-gray-200">{room.room_id}</td>
                            <td className="py-3 px-4 border-b border-gray-200">{room.hotel_id}</td>
                            <td className="py-3 px-4 border-b border-gray-200">{room.price}</td>
                            <td className="py-3 px-4 border-b border-gray-200">{room.capacity}</td>
                            <td className="py-3 px-4 border-b border-gray-200">{room.view}</td>
                            <td className="py-3 px-4 border-b border-gray-200">
                              {room.extendable ? 'TRUE' : 'FALSE'}
                            </td>
                            <td className="py-3 px-4 border-b border-gray-200">{room.status}</td>

                            <td className="py-3 px-4 border-b border-gray-200">
                              <div className="flex space-x-2">
                                <button
                                  className="p-1 bg-blue-100 text-blue-700 rounded hover:bg-blue-200"
                                  onClick={() =>
                                    handleEditRoom(
                                      room.room_id,
                                      room.hotel_id,
                                      room.price,
                                      room.capacity,
                                      room.view,
                                      room.extendable,
                                      room.status,
                                    )
                                  }
                                >
                                  <Edit size={16} />
                                </button>
                                <button
                                  className="p-1 bg-red-100 text-red-700 rounded hover:bg-red-200"
                                  onClick={() => handleDelete('room', 'room_id', room.room_id)}
                                >
                                  <Trash2 size={16} />
                                </button>
                              </div>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  )}

                  {activeTab === 'customers' && (
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
                        {customers.map(customer => (
                          <tr key={customer.customer_id} className="hover:bg-gray-50">
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
                                <button
                                  className="p-1 bg-blue-100 text-blue-700 rounded hover:bg-blue-200"
                                  onClick={() =>
                                    handleEditCustomer(
                                      customer.customer_id,
                                      customer.first_name,
                                      customer.last_name,
                                      customer.address,
                                      customer.id_type,
                                      customer.id_number,
                                      customer.registration_date,
                                    )
                                  }
                                >
                                  <Edit size={16} />
                                </button>
                                <button
                                  className="p-1 bg-red-100 text-red-700 rounded hover:bg-red-200"
                                  onClick={() =>
                                    handleDelete('customer', 'customer_id', customer.customer_id)
                                  }
                                >
                                  <Trash2 size={16} />
                                </button>
                              </div>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  )}

                  {activeTab === 'employees' && (
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
                        {employees.map(employee => (
                          <tr key={employee.ssn} className="hover:bg-gray-50">
                            <td className="py-3 px-4 border-b border-gray-200">{employee.ssn}</td>
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
                            <td className="py-3 px-4 border-b border-gray-200">{employee.role}</td>
                            <td className="py-3 px-4 border-b border-gray-200">
                              <div className="flex space-x-2">
                                <button
                                  className="p-1 bg-blue-100 text-blue-700 rounded hover:bg-blue-200"
                                  onClick={() =>
                                    handleEditEmployee(
                                      employee.ssn,
                                      employee.hotel_id,
                                      employee.first_name,
                                      employee.last_name,
                                      employee.address,
                                      employee.role,
                                    )
                                  }
                                >
                                  <Edit size={16} />
                                </button>
                                <button
                                  className="p-1 bg-red-100 text-red-700 rounded hover:bg-red-200"
                                  onClick={() => handleDelete('employee', 'ssn', employee.ssn)}
                                >
                                  <Trash2 size={16} />
                                </button>
                              </div>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  )}

                  {activeTab === 'bookings' && (
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
                        {bookingsList.map(booking => (
                          <tr key={booking.booking_id} className="hover:bg-gray-50">
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
                              <button className="px-2 py-1 bg-blue-100 text-blue-700 rounded hover:bg-blue-200 text-xs"
                              onClick={() => handleConvert(booking.booking_id, booking.customer_id, booking.start_date, booking.end_date, booking.room_id)}>
                                Convert
                              </button>
                                <button
                                  className="p-1 bg-red-100 text-red-700 rounded hover:bg-red-200"
                                  onClick={() => handleDelete('booking', 'booking_id', booking.booking_id)}
                                >
                                  <Trash2 size={16} />
                                </button>
                          
                              </div>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  )}

                  {activeTab === 'rentings' && (
                    <table className="min-w-full bg-white">
                      <thead>
                        <tr>
                          <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                            Rental ID
                          </th>
                          <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                            Customer ID
                          </th>
                          <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                            Check In Date
                          </th>
                          <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                            Check Out Date
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
                        {rentings.map(rental => (
                          <tr key={rental.rental_id} className="hover:bg-gray-50">
                            <td className="py-3 px-4 border-b border-gray-200">
                              {rental.rental_id}
                            </td>
                            <td className="py-3 px-4 border-b border-gray-200">
                              {rental.customer_id}
                            </td>
                            <td className="py-3 px-4 border-b border-gray-200">
                              {rental.check_in_date}
                            </td>
                            <td className="py-3 px-4 border-b border-gray-200">
                              {rental.check_out_date}
                            </td>
                            <td className="py-3 px-4 border-b border-gray-200">{rental.room_id}</td>
                            <td className="py-3 px-4 border-b border-gray-200">
                              <div className="flex space-x-2">
                              <button className="px-2 py-1 bg-green-100 text-green-700 rounded hover:bg-blue-200 text-xs"
                              onClick={() => setIsPaymentModalOpen(true)}>
                                Payment
                              </button>
                                <button
                                  className="p-1 bg-red-100 text-red-700 rounded hover:bg-red-200"
                                  onClick={() => handleDelete('rental', 'rental_id', rental.rental_id)}
                                >
                                  <Trash2 size={16} />
                                </button>
                                <PaymentModal
                                  isOpen={isPaymentModalOpen}
                                  closeModal={() => setIsPaymentModalOpen(false)}></PaymentModal>
                              </div>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  )}

                  {activeTab === 'managers' && (
                    <table className="min-w-full bg-white">
                      <thead>
                        <tr>
                          <th className="py-3 px-4 border-b border-gray-200 bg-gray-50 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                            Employee SSN
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
                        </tr>
                      </thead>
                      <tbody>
                        {managers.map(manage => (
                          <tr key={manage.ssn} className="hover:bg-gray-50">
                            <td className="py-3 px-4 border-b border-gray-200">{manage.ssn}</td>
                            <td className="py-3 px-4 border-b border-gray-200">
                              {manage.hotel_id}
                            </td>
                            <td className="py-3 px-4 border-b border-gray-200">
                              {manage.first_name}
                            </td>
                            <td className="py-3 px-4 border-b border-gray-200">
                              {manage.last_name}
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  )}
                </div>
              </div>
            </div>

            {/* Room Booking/Rental Form */}
            <div className="mt-8 bg-white rounded-lg shadow p-6">
              <h2 className="text-xl font-semibold mb-4">Room Booking / Rental Management</h2>

              <div className="mb-4">
                <div className="flex space-x-4 mb-4">
                  <button
                    className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
                    onClick={() => openBookingModal('booking')}
                  >
                    New Booking
                  </button>
                  <button
                    className="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700"
                    onClick={() => openBookingModal('rental')}
                  >
                    New Rental
                  </button>
                </div>

                {/* <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Customer</label>
                    <select className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400">
                      <option value="">Select Customer</option>
                      {customerIDList.map(customer => (
                        <option key={customer} value={customer}>
                          {customer}
                        </option>
                      ))}
                    </select>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Hotel Chain</label>
                    <select className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400">
                      <option value="">Select Hotel Chain</option>
                      {hotelIDs.map(hotel => (
                        <option key={hotel} value={hotel}>
                          {hotel}
                        </option>
                      ))}
                    </select>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Room</label>
                    <select className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400">
                      {mockRooms.map(room => (
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
                    <label className="block text-sm font-medium text-gray-700 mb-1">End Date</label>
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
                      {mockEmployees.map(employee => (
                        <option key={employee.id} value={employee.id}>
                          {employee.name} - {employee.position}
                        </option>
                      ))}
                    </select>
                  </div>
                </div> */}

                {/* <div className="mt-4 flex justify-end">
                  <button className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700">
                    Search Available Rooms
                  </button>
                </div> */}
              </div>

              {/* <div className="mt-6">
                <h3 className="text-lg font-semibold mb-3">Available Rooms</h3>
                <div className="overflow-x-auto">
                  <table className="min-w-full bg-white">
                    <thead>
                      <tr>
                        <th className="py-2 px-4 border-b border-gray-200 bg-gray-50 text-left text-sm font-semibold text-gray-700">
                          Room ID
                        </th>
                        <th className="py-2 px-4 border-b border-gray-200 bg-gray-50 text-left text-sm font-semibold text-gray-700">
                          Hotel ID
                        </th>
                        <th className="py-2 px-4 border-b border-gray-200 bg-gray-50 text-left text-sm font-semibold text-gray-700">
                          Price
                        </th>
                        <th className="py-2 px-4 border-b border-gray-200 bg-gray-50 text-left text-sm font-semibold text-gray-700">
                          Capacity
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
                      {availableRooms.map(room => (
                        <tr key={room.room_id} className="hover:bg-gray-50">
                          <td className="py-2 px-4 border-b border-gray-200">{room.room_id}</td>
                          <td className="py-2 px-4 border-b border-gray-200">{room.hotel_id}</td>
                          <td className="py-2 px-4 border-b border-gray-200">
                            ${room.price}/night
                          </td>
                          <td className="py-2 px-4 border-b border-gray-200">{room.capacity}</td>
                          <td className="py-2 px-4 border-b border-gray-200">{room.view}</td>
                          <td className="py-2 px-4 border-b border-gray-200">
                            {room.extendable ? 'Yes' : 'No'}
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
              </div> */}
            </div>

            {editModalOpen && (
              <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
                <div className="bg-white rounded-lg p-6 w-full max-w-2xl">
                  {/* Header */}
                  <div className="flex justify-between items-center mb-4">
                    <h3 className="text-xl font-semibold">
                      Edit{' '}
                      {modalType === 'hotel'
                        ? 'Hotel'
                        : modalType === 'room'
                        ? 'Room'
                        : modalType === 'customer'
                        ? 'Customer'
                        : modalType === 'employee'
                        ? 'Employee'
                        : 'Item'}
                    </h3>

                    <button
                      className="text-gray-400 hover:text-gray-600"
                      onClick={() => setEditModalOpen(false)}
                    >
                      &times;
                    </button>
                  </div>

                  {/* Form Fields */}
                  <div className="space-y-4">
                    {/* Hotel Form */}
                    {modalType === 'hotel' && (
                      <>
                        <div>
                          <label className="block text-sm font-medium text-gray-700">
                            Chain ID
                          </label>
                          <input
                            type="text"
                            value={editHotelData.chain_id}
                            onChange={e =>
                              setEditHotelData({ ...editHotelData, chain_id: e.target.value })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2"
                            disabled
                          />
                        </div>

                        <div>
                          <label className="block text-sm font-medium text-gray-700">
                            Hotel ID
                          </label>
                          <input
                            type="text"
                            value={editHotelData.hotel_id}
                            onChange={e =>
                              setEditHotelData({ ...editHotelData, hotel_id: e.target.value })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2"
                            disabled
                          />
                        </div>

                        <div>
                          <label className="block text-sm font-medium text-gray-700">Address</label>
                          <input
                            type="text"
                            value={editHotelData.address}
                            onChange={e =>
                              setEditHotelData({ ...editHotelData, address: e.target.value })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2"
                          />
                        </div>

                        <div>
                          <label className="block text-sm font-medium text-gray-700">
                            Number of Rooms
                          </label>
                          <input
                            type="number"
                            disabled
                            value={editHotelData.num_rooms}
                            onChange={e =>
                              setEditHotelData({ ...editHotelData, num_rooms: e.target.value })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2"
                          />
                        </div>

                        <div>
                          <label className="block text-sm font-medium text-gray-700">
                            Contact Email
                          </label>
                          <input
                            type="email"
                            value={editHotelData.contact_email}
                            onChange={e =>
                              setEditHotelData({ ...editHotelData, contact_email: e.target.value })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2"
                          />
                        </div>

                        <div>
                          <label className="block text-sm font-medium text-gray-700">
                            Star Category
                          </label>
                          <input
                            type="text"
                            value={editHotelData.starcategory}
                            onChange={e =>
                              setEditHotelData({ ...editHotelData, starcategory: e.target.value })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2"
                          />
                        </div>
                      </>
                    )}
                    {modalType === 'room' && (
                      <>
                        <div>
                          <label className="block text-sm font-medium text-gray-700">Room ID</label>
                          <input
                            type="text"
                            value={editRoomData.room_id}
                            onChange={e =>
                              setEditRoomData({ ...editRoomData, room_id: e.target.value })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2"
                            disabled
                          />
                        </div>

                        <div>
                          <label className="block text-sm font-medium text-gray-700">
                            Hotel ID
                          </label>
                          <input
                            type="text"
                            value={editRoomData.hotel_id}
                            onChange={e =>
                              setEditRoomData({ ...editRoomData, hotel_id: e.target.value })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2"
                            disabled
                          />
                        </div>

                        <div>
                          <label className="block text-sm font-medium text-gray-700">Price</label>
                          <input
                            type="number"
                            value={editRoomData.price}
                            onChange={e =>
                              setEditRoomData({ ...editRoomData, price: e.target.value })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2"
                          />
                        </div>

                        <div className="flex items-center">
                          <input
                            type="checkbox"
                            id="extendable"
                            onChange={e =>
                              setEditRoomData({ ...editRoomData, extendable: e.target.checked })
                            }
                            value={editRoomData.extendable}
                            className="mr-2"
                          />
                          <label htmlFor="extendable" className="text-sm font-medium text-gray-700">
                            Extendable (can add extra bed)
                          </label>
                        </div>

                        <div>
                          <label className="block text-sm font-medium text-gray-700">Status</label>
                          <select
                            value={editRoomData.status}
                            onChange={e =>
                              setEditRoomData({ ...editRoomData, status: e.target.value })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2"
                          >
                            <option value="Available">Available</option>
                            <option value="Unavailable">Unavailable</option>
                          </select>
                        </div>

                        <div>
                          <label className="block text-sm font-medium text-gray-700">View</label>
                          <input
                            type="text"
                            value={editRoomData.view}
                            onChange={e =>
                              setEditRoomData({ ...editRoomData, view: e.target.value })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2"
                          />
                        </div>

                        <div>
                          <label className="block text-sm font-medium text-gray-700">
                            Capacity
                          </label>
                          <input
                            type="text"
                            value={editRoomData.capacity}
                            onChange={e =>
                              setEditRoomData({ ...editRoomData, capacity: e.target.value })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2"
                          />
                        </div>
                      </>
                    )}
                    {/* Customer Modal */}
                    {modalType === 'customer' && (
                      <>
                        <div>
                          <label className="block text-sm font-medium text-gray-700">
                            Customer ID
                          </label>
                          <input
                            type="text"
                            value={editCustomerData.customer_id}
                            onChange={e =>
                              setEditCustomerData({
                                ...editCustomerData,
                                customer_id: e.target.value,
                              })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2"
                            disabled
                          />
                        </div>

                        <div>
                          <label className="block text-sm font-medium text-gray-700">
                            First Name
                          </label>
                          <input
                            type="text"
                            value={editCustomerData.first_name}
                            onChange={e =>
                              setEditCustomerData({
                                ...editCustomerData,
                                first_name: e.target.value,
                              })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2"
                          />
                        </div>

                        <div>
                          <label className="block text-sm font-medium text-gray-700">
                            Last Name
                          </label>
                          <input
                            type="text"
                            value={editCustomerData.last_name}
                            onChange={e =>
                              setEditCustomerData({
                                ...editCustomerData,
                                last_name: e.target.value,
                              })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2"
                          />
                        </div>

                        <div>
                          <label className="block text-sm font-medium text-gray-700">Address</label>
                          <input
                            type="text"
                            value={editCustomerData.address}
                            onChange={e =>
                              setEditCustomerData({ ...editCustomerData, address: e.target.value })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2"
                          />
                        </div>

                        <div>
                          <label className="block text-sm font-medium text-gray-700">ID Type</label>
                          <select
                            value={editCustomerData.id_type}
                            onChange={e =>
                              setEditCustomerData({ ...editCustomerData, id_type: e.target.value })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2"
                          >
                            <option value="DRIVING_LICENSE">Drivers License</option>
                            <option value="SIN">SIN</option>
                            <option value="SSN">SSN</option>
                          </select>
                        </div>

                        <div>
                          <label className="block text-sm font-medium text-gray-700">
                            ID Number
                          </label>
                          <input
                            type="text"
                            value={editCustomerData.id_number}
                            onChange={e =>
                              setEditCustomerData({
                                ...editCustomerData,
                                id_number: e.target.value,
                              })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2"
                          />
                        </div>
                      </>
                    )}

                    {/* Employee Modal */}
                    {modalType === 'employee' && (
                      <>
                        <div>
                          <label className="block text-sm font-medium text-gray-700">
                            Employee SSN
                          </label>
                          <input
                            type="text"
                            value={editEmployeeData.ssn}
                            onChange={e =>
                              setEditEmployeeData({ ...editEmployeeData, ssn: e.target.value })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2"
                            disabled
                          />
                        </div>

                        <div>
                          <label className="block text-sm font-medium text-gray-700">
                            Employee SSN
                          </label>
                          <input
                            type="text"
                            value={editEmployeeData.hotel_id}
                            onChange={e =>
                              setEditEmployeeData({ ...editEmployeeData, hotel_id: e.target.value })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2"
                            disabled
                          />
                        </div>

                        <div>
                          <label className="block text-sm font-medium text-gray-700">
                            First Name
                          </label>
                          <input
                            type="text"
                            value={editEmployeeData.first_name}
                            onChange={e =>
                              setEditEmployeeData({
                                ...editEmployeeData,
                                first_name: e.target.value,
                              })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2"
                          />
                        </div>

                        <div>
                          <label className="block text-sm font-medium text-gray-700">
                            Last Name
                          </label>
                          <input
                            type="text"
                            value={editEmployeeData.last_name}
                            onChange={e =>
                              setEditEmployeeData({
                                ...editEmployeeData,
                                last_name: e.target.value,
                              })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2"
                          />
                        </div>

                        <div>
                          <label className="block text-sm font-medium text-gray-700">Address</label>
                          <input
                            type="text"
                            value={editEmployeeData.address}
                            onChange={e =>
                              setEditEmployeeData({ ...editEmployeeData, address: e.target.value })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2"
                          />
                        </div>

                        <div>
                          <label className="block text-sm font-medium text-gray-700">Role</label>
                          <input
                            type="text"
                            value={editEmployeeData.role}
                            onChange={e =>
                              setEditEmployeeData({ ...editEmployeeData, role: e.target.value })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2"
                          />
                        </div>
                      </>
                    )}
                  </div>

                  {/* Save and Cancel Buttons */}
                  <div className="flex justify-end mt-4">
                    <button
                      className="bg-gray-300 text-gray-700 px-4 py-2 rounded mr-2"
                      onClick={() => setEditModalOpen(false)}
                    >
                      Cancel
                    </button>
                    <button
                      className="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600"
                      onClick={async () => await handleSaveEdit(modalType)}
                    >
                      Save
                    </button>
                  </div>
                </div>
              </div>
            )}

            {/* Add Modal */}
            {showAddModal && (
              <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
                <div className="bg-white rounded-lg p-6 w-full max-w-2xl">
                  <div className="flex justify-between items-center mb-4">
                    <h3 className="text-xl font-semibold">
                      Add New{' '}
                      {modalType === 'hotelchains'
                        ? 'Hotel Chain'
                        : modalType === 'hotels'
                        ? 'Hotel'
                        : modalType === 'rooms'
                        ? 'Room'
                        : modalType === 'customers'
                        ? 'Customer'
                        : modalType === 'employees'
                        ? 'Employee'
                        : 'Item'}
                    </h3>
                    <button
                      className="text-gray-400 hover:text-gray-600"
                      onClick={() => setShowAddModal(false)}
                    >
                      &times;
                    </button>
                  </div>

                  <div className="mb-4">
                    {modalType === 'hotelchains' && (
                      <div className="space-y-4">
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Chain ID
                          </label>
                          <input
                            type="text"
                            value={hotelChainData.nextChainID}
                            disabled
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                          />
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Central Office Address
                          </label>
                          <input
                            type="text"
                            onChange={e =>
                              setFormData({ ...formData, centralOfficeAddress: e.target.value })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                          />
                        </div>
                        <div className="flex justify-end space-x-2">
                          <button
                            className="px-4 py-2 bg-gray-200 text-gray-700 rounded-md hover:bg-gray-300"
                            onClick={() => setShowAddModal(false)}
                          >
                            Cancel
                          </button>
                          <button
                            className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
                            onClick={handleNewChain}
                          >
                            Save
                          </button>
                        </div>
                      </div>
                    )}

                    {modalType === 'hotels' && (
                      <div className="space-y-4">
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Hotel ID
                          </label>
                          <input
                            type="text"
                            value={hotelChainData.nextHotelID}
                            disabled
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                          />
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Hotel Chain
                          </label>
                          <select
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                            onChange={e => setFormData({ ...formData, hotelChain: e.target.value })}
                          >
                            {hotelIDs.map(chain => (
                              <option key={chain} value={chain}>
                                {chain}
                              </option>
                            ))}
                          </select>
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Category
                          </label>
                          <select
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                            onChange={e => setFormData({ ...formData, category: e.target.value })}
                          >
                            <option value="1">1-star</option>
                            <option value="2">2-star</option>
                            <option value="3">3-star</option>
                            <option value="4">4-star</option>
                            <option value="5">5-star</option>
                          </select>
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Address
                          </label>
                          <input
                            type="text"
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                            onChange={e => setFormData({ ...formData, address: e.target.value })}
                          />
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Email
                          </label>
                          <input
                            onChange={e => setFormData({ ...formData, email: e.target.value })}
                            type="email"
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                          />
                        </div>
                        <div className="flex justify-end space-x-2">
                          <button
                            className="px-4 py-2 bg-gray-200 text-gray-700 rounded-md hover:bg-gray-300"
                            onClick={() => setShowAddModal(false)}
                          >
                            Cancel
                          </button>
                          <button
                            className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
                            onClick={handleNewHotel}
                          >
                            Save
                          </button>
                        </div>
                      </div>
                    )}

                    {modalType === 'rooms' && (
                      <div className="space-y-4">
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Room ID (Must start with RM, ex: RM0010000)
                          </label>
                          <input
                            type="text"
                            onChange={e => setFormData({ ...formData, roomID: e.target.value })}
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                          />
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Hotel
                          </label>
                          <select
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                            onChange={e => setFormData({ ...formData, roomHotel: e.target.value })}
                          >
                            {hotelIDList.map(hotel => (
                              <option key={hotel} value={hotel}>
                                {hotel}
                              </option>
                            ))}
                          </select>
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Price per Night
                          </label>
                          <input
                            onChange={e => setFormData({ ...formData, price: e.target.value })}
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
                          <select
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                            onChange={e => setFormData({ ...formData, capacity: e.target.value })}
                          >
                            <option value="SINGLE">Single</option>
                            <option value="DOUBLE">Double</option>
                            <option value="TRIPLE">Triple</option>
                            <option value="QUAD">Quad</option>
                            <option value="SUITE">Suite</option>
                          </select>
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            View
                          </label>
                          <select
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                            onChange={e => setFormData({ ...formData, view: e.target.value })}
                          >
                            <option value="City View">City View</option>
                            <option value="Garden View">Garden View</option>
                            <option value="Sea View">Sea View</option>
                            <option value="Mountain View">Mountain View</option>
                            <option value="Lake View">Lake View</option>
                            <option value="Pool View">Pool View</option>
                            <option value="Forest View">Forest View</option>
                            <option value="River View">River View</option>
                          </select>
                        </div>
                        <div className="flex items-center">
                          <input
                            type="checkbox"
                            id="extendable"
                            onChange={e =>
                              setFormData({ ...formData, extendable: e.target.checked })
                            }
                            className="mr-2"
                          />
                          <label htmlFor="extendable" className="text-sm font-medium text-gray-700">
                            Extendable (can add extra bed)
                          </label>
                        </div>
                        <div className="flex justify-end space-x-2">
                          <button
                            className="px-4 py-2 bg-gray-200 text-gray-700 rounded-md hover:bg-gray-300"
                            onClick={() => setShowAddModal(false)}
                          >
                            Cancel
                          </button>
                          <button
                            className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
                            onClick={handleNewRoom}
                          >
                            Save
                          </button>
                        </div>
                      </div>
                    )}

                    {modalType === 'customers' && (
                      <div className="space-y-4">
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Customer ID (Must start with CUST, ex: CUST4000)
                          </label>
                          <input
                            type="text"
                            onChange={e => setFormData({ ...formData, customerID: e.target.value })}
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                          />
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            First name
                          </label>
                          <input
                            type="text"
                            onChange={e =>
                              setFormData({ ...formData, customerFirstName: e.target.value })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                          />
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Last name
                          </label>
                          <input
                            type="text"
                            onChange={e =>
                              setFormData({ ...formData, customerLastName: e.target.value })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                          />
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Address
                          </label>
                          <input
                            type="text"
                            onChange={e =>
                              setFormData({ ...formData, customerAddress: e.target.value })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                          />
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            ID Type
                          </label>
                          <select
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                            onChange={e =>
                              setFormData({ ...formData, customerIDType: e.target.value })
                            }
                          >
                            <option value="DRIVING_LICENSE">Driver License</option>
                            <option value="SIN">SIN</option>
                            <option value="SSN">SSN</option>
                          </select>
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            ID Number
                          </label>
                          <input
                            type="text"
                            onChange={e =>
                              setFormData({ ...formData, customerIDNumber: e.target.value })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                          />
                        </div>
                        <div className="flex justify-end space-x-2">
                          <button
                            className="px-4 py-2 bg-gray-200 text-gray-700 rounded-md hover:bg-gray-300"
                            onClick={() => setShowAddModal(false)}
                          >
                            Cancel
                          </button>
                          <button
                            className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
                            onClick={handleNewCustomer}
                          >
                            Save
                          </button>
                        </div>
                      </div>
                    )}

                    {modalType === 'employees' && (
                      <div className="space-y-4">
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            SSN
                          </label>
                          <input
                            type="text"
                            onChange={e =>
                              setFormData({ ...formData, employeeSSN: e.target.value })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                          />
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Hotel
                          </label>
                          <select
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                            onChange={e =>
                              setFormData({ ...formData, employeeHotelID: e.target.value })
                            }
                          >
                            {hotelIDList.map(hotel => (
                              <option key={hotel} value={hotel}>
                                {hotel}
                              </option>
                            ))}
                          </select>
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            First name
                          </label>
                          <input
                            type="text"
                            onChange={e =>
                              setFormData({ ...formData, employeeFirstName: e.target.value })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                          />
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Last name
                          </label>
                          <input
                            type="text"
                            onChange={e =>
                              setFormData({ ...formData, employeeLastName: e.target.value })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                          />
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Address
                          </label>
                          <input
                            type="text"
                            onChange={e =>
                              setFormData({ ...formData, employeeAddress: e.target.value })
                            }
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                          />
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Role
                          </label>
                          <select
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                            onChange={e =>
                              setFormData({ ...formData, employeeRole: e.target.value })
                            }
                          >
                            <option value="Receptionist">Receptionist</option>
                            <option value="Housekeeper">Housekeeper</option>
                            <option value="Chef">Chef</option>
                            <option value="Security">Security</option>
                            <option value="Manager">Manager</option>
                          </select>
                        </div>
                        <div className="flex justify-end space-x-2">
                          <button
                            className="px-4 py-2 bg-gray-200 text-gray-700 rounded-md hover:bg-gray-300"
                            onClick={() => setShowAddModal(false)}
                          >
                            Cancel
                          </button>
                          <button
                            className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
                            onClick={handleNewEmployee}
                          >
                            Save
                          </button>
                        </div>
                      </div>
                    )}

                    {/* Similar form fields for customers, employees, etc. would go here */}
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
                      {modalType === 'booking'
                        ? 'Create New Booking'
                        : modalType === 'rental'
                        ? 'Create New Rental'
                        : 'Convert Booking to Rental'}
                    </h3>
                    <button
                      className="text-gray-400 hover:text-gray-600"
                      onClick={() => setShowBookingModal(false)}
                    >
                      &times;
                    </button>
                  </div>

                  <div className="mb-4">
                    {modalType === 'booking' && (
                      <div className="space-y-4">
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Customer
                          </label>
                          <select
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                            onChange={e =>
                              setBookingData({ ...bookingData, customer: e.target.value })
                            }
                          >
                            {customerIDList.map(customer => (
                              <option key={customer} value={customer}>
                                {customer}
                              </option>
                            ))}
                          </select>
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Hotel
                          </label>
                          <select
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                            onChange={e =>
                              setBookingData({ ...bookingData, hotel: e.target.value })
                            }
                          >
                            {hotelIDList.map(hotel => (
                              <option key={hotel} value={hotel}>
                                {hotel}
                              </option>
                            ))}
                          </select>
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Room
                          </label>
                          <select
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                            onChange={e => setBookingData({ ...bookingData, room: e.target.value })}
                          >
                            {roomIDs.map(room => (
                              <option key={room} value={room}>
                                {room}
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
                              onChange={e =>
                                setBookingData({ ...bookingData, startDate: e.target.value })
                              }
                              className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                            />
                          </div>
                          <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">
                              End Date
                            </label>
                            <input
                              type="date"
                              onChange={e =>
                                setBookingData({ ...bookingData, endDate: e.target.value })
                              }
                              className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                            />
                          </div>
                        </div>
                        <div className="flex justify-end space-x-2">
                          <button
                            className="px-4 py-2 bg-gray-200 text-gray-700 rounded-md hover:bg-gray-300"
                            onClick={() => setShowBookingModal(false)}
                          >
                            Cancel
                          </button>
                          <button
                            className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
                            onClick={handleNewBooking}
                          >
                            Save
                          </button>
                        </div>
                      </div>
                    )}

                      {modalType === 'rental' && (
                      <div className="space-y-4">
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Customer
                          </label>
                          <select
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                            onChange={e =>
                              setRentalData({ ...rentalData, customer: e.target.value })
                            }
                          >
                            {customerIDList.map(customer => (
                              <option key={customer} value={customer}>
                                {customer}
                              </option>
                            ))}
                          </select>
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Hotel
                          </label>
                          <select
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                            onChange={e =>
                              setRentalData({ ...rentalData, hotel: e.target.value })
                            }
                          >
                            {hotelIDList.map(hotel => (
                              <option key={hotel} value={hotel}>
                                {hotel}
                              </option>
                            ))}
                          </select>
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Room
                          </label>
                          <select
                            className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                            onChange={e => setRentalData({ ...rentalData, room: e.target.value })}
                          >
                            {roomIDs.map(room => (
                              <option key={room} value={room}>
                                {room}
                              </option>
                            ))}
                          </select>
                        </div>
                        <div className="grid grid-cols-2 gap-4">
                          <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">
                              Check In Date
                            </label>
                            <input
                              type="date"
                              onChange={e =>
                                setRentalData({ ...rentalData, startDate: e.target.value })
                              }
                              className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                            />
                          </div>
                          <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">
                              Check Out Date
                            </label>
                            <input
                              type="date"
                              onChange={e =>
                                setRentalData({ ...rentalData, endDate: e.target.value })
                              }
                              className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400"
                            />
                          </div>
                        </div>
                        <div className="flex justify-end space-x-2">
                          <button
                            className="px-4 py-2 bg-gray-200 text-gray-700 rounded-md hover:bg-gray-300"
                            onClick={() => setShowBookingModal(false)}
                          >
                            Cancel
                          </button>
                          <button
                            className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
                            onClick={handleNewRental}
                          >
                            Save
                          </button>
                        </div>
                      </div>
                    )}

                    {modalType === 'convert' && (
                      <div className="space-y-4">
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-1">
                            Select Booking to Convert
                          </label>
                          <select className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400">
                            <option value="">Select Booking</option>
                            {mockBookings.map(booking => {
                              const customer = mockCustomers.find(c => c.id === booking.customerId);
                              const room = mockRooms.find(r => r.id === booking.roomId);
                              return (
                                <option key={booking.id} value={booking.id}>
                                  {customer?.name || 'Unknown'} - Room {room?.number || 'Unknown'} (
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
                            {mockEmployees.map(employee => (
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

                  {/* <div className="flex justify-end space-x-2">
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
                  </div> */}
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
