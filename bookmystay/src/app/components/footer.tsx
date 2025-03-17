// src/components/Footer.tsx
import Link from "next/link";
import Image from "next/image";

const Footer: React.FC = () => {
  return (
    <footer className="bg-[#A7AACC] text-white py-6">
      <div className="max-w-5xl mx-auto px-4 grid grid-cols-2 md:grid-cols-2 gap-8">
        <div>
          <h3 className="font-medium mb-4">Discover</h3>
          <ul className="space-y-2">
            <li>
              <Link href="/bookings" className="text-white/80 hover:text-white">
                Bookings
              </Link>
            </li>
            <li>
              <Link href="/rentals" className="text-white/80 hover:text-white">
                Rentals
              </Link>
            </li>
            <li>
              <Link
                href="/locations"
                className="text-white/80 hover:text-white"
              >
                Locations
              </Link>
            </li>
          </ul>
        </div>
        <div>
          <h3 className="font-medium mb-4">Profile</h3>
          <ul className="space-y-2">
            <li>
              <Link
                href="/profile/bookings"
                className="text-white/80 hover:text-white"
              >
                View Bookings
              </Link>
            </li>
            <li>
              <Link
                href="/profile/modify"
                className="text-white/80 hover:text-white"
              >
                Modify a Booking
              </Link>
            </li>
            <li>
              <Link
                href="/profile/settings"
                className="text-white/80 hover:text-white"
              >
                Profile Settings
              </Link>
            </li>
          </ul>
        </div>
      </div>

      <div className="max-w-5xl mx-auto mt-8 pt-4 border-t border-white/20 flex justify-end px-4">
        <div className="flex items-center">
          <div>
            <Image
              src="/LogoWhite.svg"
              alt="BookMyStay Logo"
              width={143}
              height={34}
              priority
            />
          </div>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
