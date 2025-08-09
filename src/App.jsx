import React, { useEffect, useState } from "react";
import { motion, AnimatePresence } from "framer-motion";

const apkUrl = "https://github.com/jayco12/birdeye/releases/download/v1.0/app-release.apk";

// Dove fly animation container
const DoveFly = () => {
  const [doves, setDoves] = useState([]);

  useEffect(() => {
    // Add a new dove every 1.5s
    const interval = setInterval(() => {
      const id = Math.random().toString(36).substr(2, 9);
      const top = Math.random() * 80 + 10; // % viewport height
      const duration = 6 + Math.random() * 6; // seconds
      setDoves((d) => [...d, { id, top, duration }]);
      // Remove dove after duration + 1s
      setTimeout(() => {
        setDoves((d) => d.filter((x) => x.id !== id));
      }, (duration + 1) * 1000);
    }, 1500);
    return () => clearInterval(interval);
  }, []);

  return (
    <>
      {doves.map(({ id, top, duration }) => (
        <motion.div
          key={id}
          className="fixed text-white text-3xl select-none pointer-events-none"
          style={{ top: `${top}vh`, left: "-10vw" }}
          initial={{ x: "-10vw", opacity: 0 }}
          animate={{ x: "110vw", opacity: [0, 1, 1, 0] }}
          transition={{ duration, ease: "linear" }}
        >
          🕊️
        </motion.div>
      ))}
    </>
  );
};

export default function WildBibleAPKHost() {
  return (
    <div className="relative min-h-screen bg-gradient-to-br from-indigo-900 via-purple-800 to-indigo-700 overflow-hidden flex flex-col justify-center items-center p-8 text-white font-serif">
      {/* Light rays behind title */}
      <div className="absolute inset-0 flex justify-center items-center pointer-events-none">
        <motion.div
          className="absolute w-96 h-96 bg-gradient-radial from-yellow-400/40 via-transparent to-transparent rounded-full filter blur-3xl"
          animate={{ scale: [1, 1.1, 1] }}
          transition={{ duration: 6, repeat: Infinity, ease: "easeInOut" }}
          style={{ mixBlendMode: "screen" }}
        />
        <motion.div
          className="absolute w-80 h-80 bg-gradient-radial from-white/30 via-transparent to-transparent rounded-full filter blur-2xl"
          animate={{ rotate: [0, 15, 0] }}
          transition={{ duration: 10, repeat: Infinity, ease: "easeInOut" }}
          style={{ mixBlendMode: "screen" }}
        />
      </div>

      {/* Glowing crosses floating */}
      {[...Array(6)].map((_, i) => (
        <motion.div
          key={i}
          className="absolute text-yellow-400 text-4xl select-none"
          style={{
            top: `${20 + i * 12}%`,
            left: `${10 + (i % 2) * 70}%`,
            filter: "drop-shadow(0 0 4px #facc15)",
            userSelect: "none",
            pointerEvents: "none",
          }}
          animate={{
            y: [0, 15, 0],
            opacity: [0.7, 1, 0.7],
            rotate: [0, 15, -15, 0],
          }}
          transition={{
            duration: 8 + i,
            repeat: Infinity,
            ease: "easeInOut",
            delay: i * 1.3,
          }}
        >
          ✝️
        </motion.div>
      ))}

      {/* Title */}
      <motion.h1
        className="text-6xl md:text-8xl font-extrabold mb-8 select-none text-center tracking-wide drop-shadow-lg"
        animate={{ scale: [1, 1.15, 1], rotate: [0, 8, -8, 0] }}
        transition={{ duration: 5, repeat: Infinity, ease: "easeInOut" }}
        style={{
          textShadow:
            "0 0 12px #fff, 0 0 24px #fbbf24, 0 0 48px #f59e0b, 0 0 72px #b45309",
        }}
      >
        📖 Download the Word
      </motion.h1>

      {/* Pulsing download button with sparkles */}
      <motion.a
        href={apkUrl}
        download
        target="_blank"
        rel="noopener noreferrer"
        className="relative bg-gradient-to-r from-yellow-400 to-red-500 text-black font-extrabold py-5 px-14 rounded-full shadow-lg uppercase tracking-widest hover:scale-110 hover:shadow-2xl transition-transform duration-300 select-none overflow-hidden"
        whileHover={{ scale: 1.15 }}
        whileTap={{ scale: 0.9 }}
        aria-label="Download APK"
      >
        Download APK 📱

        {/* Sparkle particles */}
        <AnimatePresence>
          <motion.span
            className="absolute top-1/2 left-1/3 w-2 h-2 bg-white rounded-full opacity-80"
            initial={{ opacity: 0, scale: 0 }}
            animate={{ opacity: [0, 1, 0], scale: [0, 1, 0] }}
            transition={{ duration: 1.5, repeat: Infinity, repeatDelay: 3 }}
            style={{ filter: "drop-shadow(0 0 4px #fff)" }}
          />
          <motion.span
            className="absolute top-1/3 right-1/4 w-1.5 h-1.5 bg-white rounded-full opacity-90"
            initial={{ opacity: 0, scale: 0 }}
            animate={{ opacity: [0, 1, 0], scale: [0, 1.3, 0] }}
            transition={{ duration: 2, repeat: Infinity, repeatDelay: 4 }}
            style={{ filter: "drop-shadow(0 0 6px #ffeb3b)" }}
          />
          <motion.span
            className="absolute bottom-1/4 left-2/3 w-2 h-2 bg-yellow-300 rounded-full opacity-70"
            initial={{ opacity: 0, scale: 0 }}
            animate={{ opacity: [0, 1, 0], scale: [0, 1, 0] }}
            transition={{ duration: 1.8, repeat: Infinity, repeatDelay: 2.5 }}
            style={{ filter: "drop-shadow(0 0 5px #f59e0b)" }}
          />
        </AnimatePresence>
      </motion.a>

      {/* Footer with spinning Bible */}
      <motion.footer
        className="mt-24 text-center opacity-80 select-none text-yellow-300 text-xl tracking-wide"
        animate={{ rotate: 360 }}
        transition={{ duration: 30, repeat: Infinity, ease: "linear" }}
      >
        📜 Made with faith and code
      </motion.footer>

      {/* Dove flying effect */}
      <DoveFly />
    </div>
  );
}
