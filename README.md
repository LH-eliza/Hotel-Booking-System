### 📝 **README.md – Hotel Management System, CSI2132**

---

## 🏨 **Hotel Management System**

This is a **hotel management system** that allows users to book, rent, and manage hotel rooms. The application features a PostgreSQL database, a Next.js front-end, and uses **Neon DB** for cloud-based database connectivity.

---

## 🚀 **Technologies Used**

### 🔥 **Back-End**
- **PostgreSQL**: Database management system.
- **pgAdmin**: Used for local database setup and management.
### 🌐 **Front-End**
- **Next.js** (React framework)
- **TypeScript** and **JavaScript**
- **Libraries**: 
  - `tailwindcss` for front-end css
  - 'Firebase' for User Authentication
  - `dotenv` for environment variables
  - `pg` for PostgreSQL database integration

### 🌎 **Hosting**
- **Neon DB**: Cloud-based PostgreSQL service used to host the database and allow API access.
- **Website**: You can access the live web app at:
  - 🌐 [https://hotel-booking-system-csi.vercel.app/](https://hotel-booking-system-csi.vercel.app/)

---

## ⚙️ **Installation Instructions**

### 💻 **Local Installation**
To run the project locally, follow these steps:

1. **Clone the repository**
```bash
git clone https://github.com/LH-eliza/Hotel-Booking-System.git
cd bookmystay
```

2. **Install dependencies**
```bash
npm install
```

3. **Set environment variables**
Create a `.env` file in the `/bookmystay` directory and add the following environment variables:
```
You will find the env variables in the report submitted.
```

4. **Run the development server**
```bash
npm run dev
```
- The web app will be available at: `http://localhost:3000`

---

## 👥 **Contributors**
- **Matteo Dagostino**  
- **Lauren Hong**  
---

## ✅ **Features**
- 📊 **Room Management:** Add, delete, and modify hotel rooms.
- 🛏️ **Booking and Rental System:** Customers can book or rent rooms.
- 📱 **Responsive UI:** Optimized for both desktop and mobile devices.
- 🔥 **Cascading Deletes:** SQL triggers for automatic cleanup.
- 📊 **Views & Indexes:** Improved performance and easier querying.

---

## 📌 **Future Enhancements**
- 📅 **Calendar Integration:** Room availability visualization.
- 📈 **Analytics Dashboard:** Display room occupancy, revenue, and customer stats.

---
