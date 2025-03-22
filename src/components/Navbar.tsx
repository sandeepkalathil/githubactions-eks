import { useState } from "react";

const Navbar = () => {
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  return (
    <nav className="bg-white shadow-md">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between h-16">
          <div className="flex">
            <a href="#" className="text-gray-700 hover:text-emerald-600">
              Home
            </a>
            <a href="#" className="ml-4 text-gray-700 hover:text-emerald-600">
              Products
            </a>
            <a href="#" className="ml-4 text-gray-700 hover:text-emerald-600">
              Categories
            </a>
            <a href="#" className="ml-4 text-gray-700 hover:text-emerald-600">
              Deals
            </a>
          </div>

          <div className="flex items-center">
            <button className="p-2 hover:bg-gray-100 rounded-full relative">
              <svg className="lucide lucide-cart h-6 w-6" fill="none" height="24" stroke="currentColor"
                strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" viewBox="0 0 24 24" width="24"
                xmlns="http://www.w3.org/2000/svg">
                <circle cx="8" cy="21" r="1" />
                <circle cx="19" cy="21" r="1" />
                <path d="M2.05 2.05h2l2.66 12.42a2 2 0 0 0 2 1.58h9.78a2 2 0 0 0 1.95-1.57l1.65-7.43H5.12" />
              </svg>
              <span className="absolute top-0 right-0 bg-emerald-500 text-white text-xs rounded-full h-5 w-5 flex items-center justify-center">
                3
              </span>
            </button>

            <button
              className="md:hidden p-2 hover:bg-gray-100 rounded-full"
              onClick={() => setIsMenuOpen(!isMenuOpen)}
              aria-label="Toggle menu"
            >
              <svg className="lucide lucide-menu h-6 w-6" fill="none" height="24" stroke="currentColor"
                strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" viewBox="0 0 24 24" width="24"
                xmlns="http://www.w3.org/2000/svg">
                <line x1="4" x2="20" y1="12" y2="12" />
                <line x1="4" x2="20" y1="6" y2="6" />
                <line x1="4" x2="20" y1="18" y2="18" />
              </svg>
            </button>
          </div>
        </div>

        {isMenuOpen && (
          <div className="md:hidden">
            <a href="#" className="block py-2 text-gray-700 hover:text-emerald-600">
              Home
            </a>
            <a href="#" className="block py-2 text-gray-700 hover:text-emerald-600">
              Products
            </a>
            <a href="#" className="block py-2 text-gray-700 hover:text-emerald-600">
              Categories
            </a>
            <a href="#" className="block py-2 text-gray-700 hover:text-emerald-600">
              Deals
            </a>
          </div>
        )}
      </div>
    </nav>
  );
};

export default Navbar;
