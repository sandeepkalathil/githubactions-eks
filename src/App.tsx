import React from 'react';
// Disable ESLint warning for unused imports
import { ShoppingCart, Search, Menu } from 'lucide-react'; // eslint-disable-line @typescript-eslint/no-unused-vars
import Navbar from './components/Navbar';
import Hero from './components/Hero';
import FeaturedProducts from './components/FeaturedProducts';
import Categories from './components/Categories';
import Footer from './components/Footer';

function App() {
  return (
    <div className="min-h-screen bg-gray-50">
      <Navbar />
      <Hero />
      <FeaturedProducts />
      <Categories />
      <Footer />
    </div>
  );
}

export default App;
