import React, { useState, useEffect } from "react";

const BirdeyeLanding = () => {
  const apkLink = "https://github.com/jayco12/birdeye/releases/download/v1.0/app-release.apk";
  const iosLink = "https://testflight.apple.com/join/1UVvq4Xv";

  const words = ["Birdeye Bible App", "Deep Scripture Study", "Faith Meets Technology"];
  const [text, setText] = useState("");
  const [wordIndex, setWordIndex] = useState(0);
  const [isDeleting, setIsDeleting] = useState(false);
  const [speed, setSpeed] = useState(120);

  // Controls which cards are visible for staggered animation
  const [visibleCards, setVisibleCards] = useState(0);

  useEffect(() => {
    const handleTyping = () => {
      const currentWord = words[wordIndex];
      if (!isDeleting) {
        setText(currentWord.substring(0, text.length + 1));
        if (text.length + 1 === currentWord.length) {
          setIsDeleting(true);
          setSpeed(1200);
          // Start revealing cards after first word typed
          if (visibleCards === 0) setVisibleCards(1);
        }
      } else {
        setText(currentWord.substring(0, text.length - 1));
        if (text.length === 0) {
          setIsDeleting(false);
          setWordIndex((prev) => (prev + 1) % words.length);
          setSpeed(150);
          setVisibleCards(0); // reset cards visibility on word change
        }
      }
    };
    const timer = setTimeout(handleTyping, speed);
    return () => clearTimeout(timer);
  }, [text, isDeleting, speed, wordIndex, visibleCards]);

  // Reveal cards staggered, one every 700ms once typing done
  useEffect(() => {
    if (visibleCards === 0) return;
    if (visibleCards < 4) {
      const timer = setTimeout(() => setVisibleCards(visibleCards + 1), 700);
      return () => clearTimeout(timer);
    }
  }, [visibleCards]);

  const features = [
    { icon: "📚", title: "Study with Depth", desc: "Access original Greek & Hebrew texts with Strong’s numbers and lexicon meanings to enrich your understanding." },
    { icon: "🔍", title: "Search & Discover", desc: "Find verses by keyword, topic, or theme with a powerful search that connects scripture insights." },
    { icon: "🌐", title: "Offline & Anywhere", desc: "Download your favorite verses and study offline — stay connected to the Word wherever you go." },
  ];

  const announcements = [
    "New feature: Interactive Strong’s number lookup launching soon!",
    "Join our upcoming live webinar on deep Scripture study techniques.",
  ];

  return (
    <>
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Montserrat:wght@400;700&display=swap');

        html, body {
          margin: 0; padding: 0; height: 100%;
          font-family: 'Montserrat', sans-serif;
          background: linear-gradient(135deg, #7b2ff7, #f107a3, #f7b733);
          background-size: 400% 400%;
          animation: gradientShift 15s ease infinite;
          color: white;
          overflow-x: hidden;
        }

        @keyframes gradientShift {
          0% {background-position: 0% 50%;}
          50% {background-position: 100% 50%;}
          100% {background-position: 0% 50%;}
        }

        .landing-wrapper {
          min-height: 100vh;
          display: flex;
          flex-direction: column;
          align-items: center;
          padding: 2rem 1rem 4rem;
          text-align: center;
        }

        .title-container {
          flex: 0 0 auto;
          display: flex;
          justify-content: center;
          align-items: center;
          width: 100%;
          height: 25vh;
          user-select: none;
        }

        .title {
          font-size: clamp(3rem, 8vw, 5rem);
          font-weight: 900;
          white-space: nowrap;
          border-right: 3px solid rgba(255,255,255,0.75);
          overflow: hidden;
          animation: blinkCaret 0.7s step-end infinite;
          letter-spacing: 0.06em;
          text-shadow:
            0 0 8px rgba(255 255 255 / 0.9),
            0 0 15px rgba(255 255 255 / 0.6);
        }

        @keyframes blinkCaret {
          from, to { border-color: transparent; }
          50% { border-color: rgba(255,255,255,0.75); }
        }

        .cards-container {
          width: 100%;
          max-width: 960px;
          margin-top: 2rem;
          display: flex;
          flex-direction: column;
          gap: 1.6rem;
          user-select: none;
        }

        .card {
          background: rgba(255 255 255 / 0.15);
          backdrop-filter: blur(12px);
          border-radius: 18px;
          padding: 1.8rem 2rem;
          box-shadow: 0 12px 25px rgba(0,0,0,0.25);
          opacity: 0;
          transform: translateY(30px);
          animation-fill-mode: forwards;
          color: white;
          text-align: left;
          transition: transform 0.3s ease;
        }

        .card.visible {
          animation: slideFadeIn 0.6s ease forwards;
        }

        .card:hover {
          transform: translateY(0) scale(1.03);
          box-shadow: 0 18px 35px rgba(0,0,0,0.45);
          cursor: default;
        }

        @keyframes slideFadeIn {
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }

        .feature-icon {
          font-size: 2.2rem;
          margin-right: 1rem;
          vertical-align: middle;
          user-select: none;
          filter: drop-shadow(0 0 3px rgba(0,0,0,0.3));
        }

        .feature-title {
          font-weight: 700;
          font-size: 1.3rem;
          margin-bottom: 0.3rem;
        }

        .feature-desc {
          font-weight: 500;
          font-size: 1rem;
          line-height: 1.4;
          opacity: 0.9;
        }

        .download-buttons {
          display: flex;
          justify-content: center;
          gap: 1.8rem;
          flex-wrap: wrap;
          margin-top: 1.5rem;
        }

        .btn-download {
          background: linear-gradient(135deg, #ff7a18, #af002d);
          color: white;
          font-weight: 700;
          padding: 1rem 2.5rem;
          border-radius: 30px;
          font-size: 1.15rem;
          box-shadow:
            0 6px 15px rgba(255 122 24 / 0.7),
            inset 0 -3px 5px rgba(255 122 24 / 0.5);
          text-decoration: none;
          display: flex;
          align-items: center;
          gap: 0.7rem;
          transition: all 0.3s ease;
          user-select: none;
          opacity: 0;
          transform: translateY(30px);
          animation-fill-mode: forwards;
        }

        .btn-download.visible {
          animation: slideFadeIn 0.6s ease forwards;
        }

        .btn-download:hover {
          filter: brightness(1.1);
          transform: translateY(-3px);
          box-shadow:
            0 12px 30px rgba(255 122 24 / 0.9),
            inset 0 -3px 5px rgba(255 122 24 / 0.7);
        }

        .footer {
          font-size: 0.85rem;
          color: rgba(255, 255, 255, 0.85);
          font-style: italic;
          user-select: none;
          margin-top: 3rem;
          text-align: center;
          text-shadow: 0 0 3px rgba(0 0 0 / 0.25);
        }

        @media (max-width: 700px) {
          .title {
            font-size: 3rem;
          }
          .card {
            padding: 1.2rem 1.5rem;
          }
          .btn-download {
            font-size: 1rem;
            padding: 0.9rem 1.8rem;
          }
        }
      `}</style>

      <div className="landing-wrapper" role="main" aria-label="Birdeye Bible App landing page">
        <div className="title-container" aria-live="polite" aria-atomic="true">
          <h1 className="title">{text}</h1>
        </div>

        <div className="cards-container" aria-label="App features, announcements, and downloads">
          {/* Features */}
          {features.map((f, i) => (
            <div key={i} className={`card ${visibleCards > i ? "visible" : ""}`} role="region" aria-labelledby={`feature-title-${i}`}>
              <span className="feature-icon" aria-hidden="true">{f.icon}</span>
              <div>
                <h2 id={`feature-title-${i}`} className="feature-title">{f.title}</h2>
                <p className="feature-desc">{f.desc}</p>
              </div>
            </div>
          ))}

          {/* Announcements */}
          {visibleCards > features.length && (
            <div className="card visible" role="region" aria-label="Announcements">
              <h2 className="feature-title">Announcements</h2>
              <ul>
                {announcements.map((a, i) => (
                  <li key={i} style={{ marginBottom: "0.7rem", opacity: 0.9 }}>{a}</li>
                ))}
              </ul>
            </div>
          )}

          {/* Download buttons */}
          {visibleCards > features.length + 1 && (
            <div className="card visible" role="region" aria-label="Download options" style={{ textAlign: "center" }}>
              <h2 className="feature-title" style={{ marginBottom: "1rem" }}>Get the App</h2>
              <div className="download-buttons">
                <a href={apkLink} className="btn-download" aria-label="Download for Android">📱 Android</a>
                <a href={iosLink} className="btn-download" aria-label="Download for iOS">🍏 iOS</a>
              </div>
            </div>
          )}
        </div>

        <p className="footer">📜 Made with faith and code by Joseph Oduyebo</p>
      </div>
    </>
  );
};

export default BirdeyeLanding;
