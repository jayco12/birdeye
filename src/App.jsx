import React, { useState, useEffect } from "react";

const BirdeyeLanding = () => {
  const apkLink = "https://github.com/jayco12/birdeye/releases/download/v1.0/app-release.apk";
  const iosLink = "https://testflight.apple.com/join/1UVvq4Xv";

  const [text, setText] = useState("");
  const [wordIndex, setWordIndex] = useState(0);
  const [isDeleting, setIsDeleting] = useState(false);
  const [speed, setSpeed] = useState(120);
  const [visibleCards, setVisibleCards] = useState(0);

  // Accordion open states
  const [featuresOpen, setFeaturesOpen] = useState(false);
  const [announcementsOpen, setAnnouncementsOpen] = useState(false);

  useEffect(() => {
    const words = ["BirdEye Bible", "BirdEye Bible App", "Deep Scripture Study"];
    const handleTyping = () => {
      const currentWord = words[wordIndex];
      if (!isDeleting) {
        setText(currentWord.substring(0, text.length + 1));
        if (text.length + 1 === currentWord.length) {
          setIsDeleting(true);
          setSpeed(1200);
          if (visibleCards === 0) setVisibleCards(1);
        }
      } else {
        setText(currentWord.substring(0, text.length - 1));
        if (text.length === 0) {
          setIsDeleting(false);
          setWordIndex((prev) => (prev + 1) % words.length);
          setSpeed(150);
          setVisibleCards(0);
        }
      }
    };
    const timer = setTimeout(handleTyping, speed);
    return () => clearTimeout(timer);
  }, [text, isDeleting, speed, wordIndex, visibleCards]);

  // Staggered reveal for "Get the App" card only
  useEffect(() => {
    if (visibleCards === 1) {
      const timer = setTimeout(() => setVisibleCards(2), 700);
      return () => clearTimeout(timer);
    }
  }, [visibleCards]);

  const features = [
    {
      icon: "📚",
      title: "Study with Depth",
      desc:
        "Access original Greek & Hebrew texts with Strong’s numbers and lexicon meanings to enrich your understanding.",
    },
    {
      icon: "🔍",
      title: "Search & Discover",
      desc:
        "Find verses by keyword, topic, or theme with a powerful search that connects scripture insights.",
    },
    {
      icon: "🌐",
      title: "Offline & Anywhere",
      desc:
        "Download your favorite verses and study offline — stay connected to the Word wherever you go.",
    },
  ];

  const announcements = [
    "New feature: Various Translations launching soon!",
    "New feature: Article contribution launching soon!",
  ];

  // Accordion toggle handlers
  const toggleFeatures = () => setFeaturesOpen((open) => !open);
  const toggleAnnouncements = () => setAnnouncementsOpen((open) => !open);

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
          user-select: none;
        }

       .title-container {
  height: 30vh;
  display: flex;
  justify-content: center;
  align-items: center;
  width: 100%;
  margin-bottom: 1.5rem;
}

.title {
  font-size: clamp(4rem, 10vw, 7rem);
  font-weight: 900;
  white-space: nowrap;
  border-right: 3px solid rgba(255,255,255,0.75);
  overflow: hidden;
  animation: blinkCaret 0.7s step-end infinite;
  letter-spacing: 0.06em;
  text-shadow:
    0 0 10px rgba(255 255 255 / 0.95),
    0 0 25px rgba(255 255 255 / 0.75);
}


        @keyframes blinkCaret {
          from, to { border-color: transparent; }
          50% { border-color: rgba(255,255,255,0.75); }
        }
.feature-item {
  display: flex;
  align-items: flex-start;
  gap: 1rem;
  margin-bottom: 1.4rem;
  padding: 0.8rem 1rem;
  border-radius: 12px;
  background: rgba(255 255 255 / 0.1);
  box-shadow: 0 0 8px rgba(255 100 100 / 0.15);
  transition: background 0.3s ease, box-shadow 0.3s ease;
  cursor: default;
  user-select: none;
}

.feature-item:hover {
  background: rgba(255 255 255 / 0.15);
  box-shadow: 0 0 15px rgba(255 100 100 / 0.4);
}

.feature-icon {
  font-size: 2.4rem;
  flex-shrink: 0;
  filter: drop-shadow(0 0 6px rgba(255, 130, 50, 0.8));
  transition: transform 0.3s ease;
  margin-top: 0.2rem;
}

.feature-item:hover .feature-icon {
  transform: scale(1.2) rotate(5deg);
  filter: drop-shadow(0 0 10px rgba(255, 160, 60, 1));
}

.feature-desc {
  font-weight: 600;
  font-size: 1.1rem;
  line-height: 1.5;
  color: #ffddb3; /* soft orange-ish text */
  letter-spacing: 0.02em;
  position: relative;
}

.feature-desc::before {
  content: "";
  position: absolute;
  left: -10px;
  top: 50%;
  transform: translateY(-50%);
  width: 5px;
  height: 5px;
  background: #ff7a18;
  border-radius: 50%;
  box-shadow: 0 0 8px #ff7a18;
}


        /* Get the App Card */
        .card {
          background: rgba(255 255 255 / 0.15);
          backdrop-filter: blur(12px);
          border-radius: 18px;
          padding: 1.8rem 2rem;
          box-shadow: 0 12px 25px rgba(0,0,0,0.25);
          color: white;
          text-align: center;
          margin-top: 2rem;
          opacity: 0;
          transform: translateY(30px);
          animation-fill-mode: forwards;
        }

        .card.visible {
          animation: slideFadeIn 0.6s ease forwards;
        }

        @keyframes slideFadeIn {
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }

        /* Download buttons */
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
        }

        .btn-download:hover {
          filter: brightness(1.1);
          transform: translateY(-3px);
          box-shadow:
            0 12px 30px rgba(255 122 24 / 0.9),
            inset 0 -3px 5px rgba(255 122 24 / 0.7);
        }

        /* Accordion styles */
        .accordion {
          width: 100%;
          max-width: 960px;
          margin-top: 1.5rem;
          text-align: left;
          user-select: none;
          color: white;
        }

        .accordion-header {
          background: rgba(255 255 255 / 0.1);
          padding: 1rem 1.5rem;
          border-radius: 12px;
          cursor: pointer;
          font-weight: 700;
          font-size: 1.25rem;
          display: flex;
          justify-content: space-between;
          align-items: center;
          box-shadow: 0 3px 10px rgba(0,0,0,0.2);
          transition: background 0.3s ease;
          user-select: none;
        }

        .accordion-header:hover {
          background: rgba(255 255 255 / 0.25);
        }

        .accordion-content {
          max-height: 0;
          overflow: hidden;
          transition: max-height 0.5s ease, padding 0.5s ease;
          padding: 0 1.5rem;
          font-weight: 500;
          font-size: 1rem;
          opacity: 0;
        }

        .accordion-content.open {
          max-height: 1000px; /* large enough for content */
          padding: 1rem 1.5rem;
          opacity: 1;
        }

        .feature-item {
          display: flex;
          gap: 1rem;
          margin-bottom: 1rem;
          align-items: flex-start;
        }

        .feature-icon {
          font-size: 2rem;
          user-select: none;
          filter: drop-shadow(0 0 3px rgba(0,0,0,0.3));
          margin-top: 0.2rem;
          flex-shrink: 0;
        }

        .feature-desc {
          line-height: 1.4;
          opacity: 0.9;
          margin: 0;
        }

        ul.announcements-list {
          list-style: disc;
          margin-left: 1.3rem;
          padding-left: 0;
          opacity: 0.9;
          margin-bottom: 0;
        }

        /* Footer */
        .footer {
          font-size: 0.85rem;
          color: rgba(255, 255, 255, 0.85);
          font-style: italic;
          user-select: none;
          margin-top: 3rem;
          text-align: center;
          text-shadow: 0 0 3px rgba(0 0 0 / 0.25);
        }

        /* Responsive */
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
          .accordion-header {
            font-size: 1.1rem;
          }
        }
      `}</style>

      <div className="landing-wrapper" role="main" aria-label="Birdeye Bible App landing page">
        <div className="title-container" aria-live="polite" aria-atomic="true">
          <h1 className="title">{text}</h1>
        </div>

        {/* Get the App Card */}
        {visibleCards >= 2 && (
          <div className="card visible" role="region" aria-label="Get the App download options">
            <h2>Get the App</h2>
            <div className="download-buttons">
              <a href={apkLink} className="btn-download" aria-label="Download for Android">
                📱 Android
              </a>
              <a href={iosLink} className="btn-download" aria-label="Download for iOS">
                🍏 iOS
              </a>
            </div>
          </div>
        )}

        {/* Features Accordion */}
        <div className="accordion" role="region" aria-labelledby="features-header">
          <button
            id="features-header"
            className="accordion-header"
            aria-expanded={featuresOpen}
            aria-controls="features-content"
            onClick={toggleFeatures}
          >
            Features
            <span>{featuresOpen ? "▲" : "▼"}</span>
          </button>
          <div
            id="features-content"
            className={`accordion-content ${featuresOpen ? "open" : ""}`}
            aria-hidden={!featuresOpen}
          >
            {features.map((f, i) => (
              <div key={i} className="feature-item">
                <span className="feature-icon" aria-hidden="true">
                  {f.icon}
                </span>
                <p className="feature-desc">{f.desc}</p>
              </div>
            ))}
          </div>
        </div>

        {/* Announcements Accordion */}
        <div className="accordion" role="region" aria-labelledby="announcements-header">
          <button
            id="announcements-header"
            className="accordion-header"
            aria-expanded={announcementsOpen}
            aria-controls="announcements-content"
            onClick={toggleAnnouncements}
          >
            Announcements
            <span>{announcementsOpen ? "▲" : "▼"}</span>
          </button>
          <div
            id="announcements-content"
            className={`accordion-content ${announcementsOpen ? "open" : ""}`}
            aria-hidden={!announcementsOpen}
          >
            <ul className="announcements-list">
              {announcements.map((a, i) => (
                <li key={i}>{a}</li>
              ))}
            </ul>
          </div>
        </div>

        <p className="footer">📜 Made with faith and code by Joseph Oduyebo</p>
      </div>
    </>
  );
};

export default BirdeyeLanding;
