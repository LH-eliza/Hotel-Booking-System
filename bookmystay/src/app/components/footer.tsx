// src/components/Footer.tsx
import Link from "next/link";

const Footer: React.FC = () => {
  return (
    <footer className="bg-red-400 text-white py-6">
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
          <svg
            width="24"
            height="24"
            viewBox="0 0 36 36"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              d="M12 18C14.5 14 17 12 22 18C26 23 10 26 12 18Z"
              fill="white"
              stroke="white"
            />
          </svg>
          <span className="ml-2 font-medium">BookMyStay</span>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
