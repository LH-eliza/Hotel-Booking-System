// src/components/Header.tsx
import Link from "next/link";

const Header: React.FC = () => {
  return (
    <header className="py-4 px-8 flex justify-between items-center border-b">
      <div className="flex items-center">
        <div className="text-red-400 mr-2">
          <svg
            width="36"
            height="36"
            viewBox="0 0 36 36"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <rect width="36" height="36" rx="8" fill="#F87171" />
            <path
              d="M12 18C14.5 14 17 12 22 18C26 23 10 26 12 18Z"
              fill="white"
              stroke="white"
            />
          </svg>
        </div>
        <Link href="/" className="font-medium text-gray-800">
          BookMyStay
        </Link>
      </div>
      <nav className="flex items-center space-x-6">
        <Link href="/top-rated" className="text-gray-600 hover:text-gray-900">
          Top Rated
        </Link>
        <Link href="/locations" className="text-gray-600 hover:text-gray-900">
          Locations
        </Link>
        <Link
          href="/login"
          className="bg-red-400 hover:bg-red-500 text-white px-5 py-2 rounded-md transition-colors"
        >
          Sign Up/Login
        </Link>
      </nav>
    </header>
  );
};

export default Header;
