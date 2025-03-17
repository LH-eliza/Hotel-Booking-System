"use client";

import React, { useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { FaEye, FaEyeSlash } from "react-icons/fa";
import { FcGoogle } from "react-icons/fc";
import Header from "../components/header";
import Footer from "../components/footer";

const SignUpPage: React.FC = () => {
  const [username, setUsername] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Handle sign up logic here
    console.log({ username, email, password });
  };

  return (
    <div>
      <Header />
      <div className="flex h-screen bg-gradient-to-r from-indigo-300 to-white">
        <div className="m-auto w-full max-w-4xl overflow-hidden rounded-3xl shadow-xl">
          <div className="flex flex-col md:flex-row">
            {/* Left Side - Form */}
            <div className="w-full bg-white p-8 md:w-1/2">
              <div className="mx-auto max-w-md">
                <h1 className="text-3xl font-bold">Create an Account</h1>
                <p className="mt-2 text-gray-600">
                  Escape & Explore – Start Your Journey!
                </p>

                <form onSubmit={handleSubmit} className="mt-8 space-y-4">
                  <div>
                    <input
                      type="text"
                      value={username}
                      onChange={(e) => setUsername(e.target.value)}
                      placeholder="Enter Your Username"
                      className="w-full rounded border border-gray-300 p-3 focus:border-indigo-500 focus:outline-none"
                      required
                    />
                  </div>

                  <div>
                    <input
                      type="email"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      placeholder="Enter Your Email"
                      className="w-full rounded border border-gray-300 p-3 focus:border-indigo-500 focus:outline-none"
                      required
                    />
                  </div>

                  <div className="relative">
                    <input
                      type={showPassword ? "text" : "password"}
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      placeholder="Enter Your Password"
                      className="w-full rounded border border-gray-300 p-3 pr-10 focus:border-indigo-500 focus:outline-none"
                      required
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword(!showPassword)}
                      className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500"
                    >
                      {showPassword ? <FaEyeSlash /> : <FaEye />}
                    </button>
                  </div>

                  <button
                    type="submit"
                    className="w-full rounded bg-indigo-500 p-3 text-white transition hover:bg-indigo-600"
                  >
                    Sign Up
                  </button>
                </form>

                <div className="mt-6 text-center">
                  <p className="text-sm text-gray-600">
                    Already have an account?
                    <Link href="/login">
                      <span className="ml-1 text-blue-500 hover:underline">
                        Login
                      </span>
                    </Link>
                  </p>
                </div>
              </div>
            </div>

            {/* Right Side - Image */}
            <div className="hidden md:block md:w-1/2">
              <div className="relative h-full w-full">
                <Image
                  src="/beach.jpg"
                  alt="Beach scene"
                  layout="fill"
                  objectFit="cover"
                  priority
                />
              </div>
            </div>
          </div>
        </div>
      </div>
      <Footer />
    </div>
  );
};

export default SignUpPage;
