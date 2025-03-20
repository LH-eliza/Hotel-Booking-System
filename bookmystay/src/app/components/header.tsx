import React, { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { Menu, X } from "lucide-react";

const Header: React.FC = () => {
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  const toggleMenu = () => {
    setIsMenuOpen(!isMenuOpen);
  };

  return (
    <header className="py-4 px-4 md:px-8 flex justify-between items-center border-b relative">
      <div className="flex items-center">
        <Link href="/">
          <Image
            src="/Logo.svg"
            alt="BookMyStay Logo"
            width={143}
            height={34}
            priority
          />
        </Link>
      </div>

      {/* Desktop Navigation */}
      <nav className="hidden md:flex items-center space-x-6">
        <Link
          href="/login"
          className="text-gray-600 hover:text-gray-900"
        >
          Login
        </Link>
        <Link
          href="/signup"
          className="bg-[#A7AACC] hover:bg-[#464D9F] text-white px-5 py-2 rounded-md transition-colors"
        >
          Sign Up
        </Link>
      </nav>

      {/* Mobile Menu Button */}
      <button
        className="md:hidden text-gray-700 focus:outline-none"
        onClick={toggleMenu}
        aria-label={isMenuOpen ? "Close menu" : "Open menu"}
      >
        {isMenuOpen ? <X size={24} /> : <Menu size={24} />}
      </button>

      {/* Mobile Navigation */}
      {isMenuOpen && (
        <div className="absolute top-full left-0 right-0 bg-white border-b shadow-lg z-50 md:hidden">
          <div className="flex flex-col p-4 space-y-4">
            <Link
              href="/login"
              className="text-gray-600 hover:text-gray-900 py-2"
              onClick={toggleMenu}
            >
              Login
            </Link>
            <Link
              href="/signup"
              className="bg-[#A7AACC] hover:bg-[#464D9F] text-white px-5 py-2 rounded-md transition-colors text-center"
              onClick={toggleMenu}
            >
              Sign Up
            </Link>
          </div>
        </div>
      )}
    </header>
  );
};

export default Header;
