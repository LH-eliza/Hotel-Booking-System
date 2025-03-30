'use client';

import React, { useState } from 'react';
import Image from 'next/image';
import Link from 'next/link';
import { FaEye, FaEyeSlash } from 'react-icons/fa';
import { FcGoogle } from 'react-icons/fc';
import Header from '../components/header';
import Footer from '../components/footer';
import { useRouter } from 'next/navigation';
import { auth } from '@/app/firebase/config';
import {
  createUserWithEmailAndPassword,
  updateProfile,
  GoogleAuthProvider,
  signInWithPopup,
} from 'firebase/auth';
import { isAdminDomain } from '../utils/adminCheck';

const SignUpPage: React.FC = () => {
  const [username, setUsername] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const router = useRouter();
  const googleProvider = new GoogleAuthProvider();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      const userCredential = await createUserWithEmailAndPassword(auth, email, password);

      await updateProfile(userCredential.user, {
        displayName: username,
      });

      console.log('User registered successfully:', userCredential.user);

      if (isAdminDomain(email)) {
        router.push('/admin');
      } else {
        router.push('/dashboard');
      }
    } catch (error: any) {
      console.error('Registration error:', error);
      setError(error.message || 'Failed to create account. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleGoogleSignUp = async () => {
    setError('');
    setLoading(true);

    try {
      const result = await signInWithPopup(auth, googleProvider);
      console.log('Google sign-up successful:', result.user);

      if (isAdminDomain(result.user.email || '')) {
        router.push('/admin');
      } else {
        router.push('/');
      }
    } catch (error: any) {
      console.error('Google sign-up error:', error);
      setError(error.message || 'Failed to sign up with Google. Please try again.');
    } finally {
      setLoading(false);
    }
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
                <p className="mt-2 text-gray-600">Escape & Explore – Start Your Journey!</p>

                {error && <div className="mt-4 rounded bg-red-100 p-3 text-red-600">{error}</div>}

                <form onSubmit={handleSubmit} className="mt-8 space-y-4">
                  <div>
                    <input
                      type="text"
                      value={username}
                      onChange={e => setUsername(e.target.value)}
                      placeholder="Enter Your Username"
                      className="w-full rounded border border-gray-300 p-3 focus:border-indigo-500 focus:outline-none"
                      required
                    />
                  </div>

                  <div>
                    <input
                      type="email"
                      value={email}
                      onChange={e => setEmail(e.target.value)}
                      placeholder="Enter Your Email"
                      className="w-full rounded border border-gray-300 p-3 focus:border-indigo-500 focus:outline-none"
                      required
                    />
                  </div>

                  <div className="relative">
                    <input
                      type={showPassword ? 'text' : 'password'}
                      value={password}
                      onChange={e => setPassword(e.target.value)}
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
                    disabled={loading}
                    className={`w-full rounded bg-indigo-500 p-3 text-white transition hover:bg-indigo-600 ${
                      loading ? 'cursor-not-allowed opacity-70' : ''
                    }`}
                  >
                    {loading ? 'Signing Up...' : 'Sign Up'}
                  </button>
                </form>

                <div className="mt-6">
                  <div className="relative">
                    <div className="absolute inset-0 flex items-center">
                      <div className="w-full border-t border-gray-300"></div>
                    </div>
                    <div className="relative flex justify-center text-sm">
                      <span className="bg-white px-2 text-gray-500">Or continue with</span>
                    </div>
                  </div>

                  <div className="mt-6">
                    <button
                      onClick={handleGoogleSignUp}
                      disabled={loading}
                      className={`flex w-full items-center justify-center rounded border border-gray-300 bg-white p-3 text-gray-700 shadow-sm transition hover:bg-gray-50 ${
                        loading ? 'cursor-not-allowed opacity-70' : ''
                      }`}
                    >
                      <FcGoogle className="mr-2 h-5 w-5" />
                      <span>Sign up with Google</span>
                    </button>
                  </div>
                </div>

                <div className="mt-6 text-center">
                  <p className="text-sm text-gray-600">
                    Already have an account?
                    <Link href="/login">
                      <span className="ml-1 text-blue-500 hover:underline">Login</span>
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
