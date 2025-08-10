import React, { useEffect, useState } from "react";

const BirdeyeLanding = () => {
  const apkLink = "https://github.com/jayco12/birdeye/releases/download/v1.0/app-release.apk";
  const ioslink="https://testflight.apple.com/join/1UVvq4Xv"
  // State to trigger fade-in animation after mount
  const [mounted, setMounted] = useState(false);
  useEffect(() => {
    setMounted(true);
  }, []);

  return (
    <>
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Montserrat:wght@400;700&display=swap');

        @keyframes fadeUp {
          0% {opacity: 0; transform: translateY(20px);}
          100% {opacity: 1; transform: translateY(0);}
        }

        .fadeUp {
          animation: fadeUp 0.8s ease forwards;
        }

        .btn-download:hover {
          background-color: #2563eb !important;
          box-shadow: 0 8px 20px rgba(37, 99, 235, 0.6);
          transform: translateY(-3px);
          transition: all 0.3s ease;
        }

        .btn-download:active {
          transform: translateY(0);
          box-shadow: 0 4px 10px rgba(37, 99, 235, 0.4);
        }

        .feature-icon {
          font-size: 1.8rem;
          margin-right: 0.8rem;
          color: #2563eb;
          user-select: none;
          flex-shrink: 0;
          transition: transform 0.3s ease;
        }

        .feature-item:hover .feature-icon {
          transform: scale(1.3) rotate(10deg);
          color: #1e40af;
        }
      `}</style>

      <div style={styles.page}>
        <div
          style={{
            ...styles.container,
            opacity: mounted ? 1 : 0,
            transform: mounted ? "translateY(0)" : "translateY(30px)",
            transition: "opacity 0.8s ease, transform 0.8s ease",
          }}
          className="fadeUp"
        >
          <h1 style={{ ...styles.title, color: "#1e40af" }}>Birdeye Bible App</h1>
          <p style={styles.tagline}>
            Dive deep into Scripture like never before. Explore original Greek &amp; Hebrew
            texts, Strong’s numbers, lexicons, and rich theological insights — all in one
            beautifully designed app.
          </p>

          <div style={styles.verseHighlight}>
            <em>
              In the beginning God created the heaven and the earth. — Genesis 1:1
            </em>
            <br />
            <small style={{ marginTop: 8, display: "block", color: "#555" }}>
              Tap any highlighted word to explore Strong’s definitions and lexicons.
            </small>
          </div>

          <div style={styles.features}>
            <Feature icon="📚" text="Study with Depth: Access original Greek & Hebrew texts with Strong’s numbers and lexicon meanings to enrich your understanding." />
            <Feature icon="🔍" text="Search & Discover: Find verses by keyword, topic, or theme with a powerful search that connects scripture insights." />
            <Feature icon="🌐" text="Offline & Anywhere: Download your favorite verses and study offline — stay connected to the Word wherever you go." />
          </div>

          <div style={styles.downloadButtons}>
            <a
              href={apkLink}
              download
              className="btn-download"
              style={{ ...styles.btn, backgroundColor: "#2563eb" }}
              aria-label="Download Android APK"
            >
              📱 Download for Android
            </a>
            <a
              href={ioslink}
              className="btn-download"
              style={{
                ...styles.btn,
                backgroundColor: "#999",
                cursor: "not-allowed",
                pointerEvents: "none",
              }}
              aria-disabled="true"
              title="iOS version coming soon"
            >
              🍏 Download for iOS
            </a>
          </div>

          <p style={styles.footer}>📜 Made with faith and code by Joseph Oduyebo</p>
        </div>
      </div>
    </>
  );
};

const Feature = ({ icon, text }) => (
  <div style={styles.featureItem} className="feature-item">
    <span className="feature-icon" aria-hidden="true">
      {icon}
    </span>
    <p style={{ margin: 0 }}>{text}</p>
  </div>
);

const styles = {
  page: {
    minHeight: "100vh",
    display: "flex",
    justifyContent: "center",
    alignItems: "center",
    background: "linear-gradient(135deg, #e0ebff, #c7d9ff)",
    padding: "1.5rem",
    fontFamily: "'Montserrat', sans-serif",
    color: "#222",
    textAlign: "center",
  },
  container: {
    maxWidth: 720,
    backgroundColor: "white",
    padding: "3rem 2.5rem",
    borderRadius: 20,
    boxShadow: "0 15px 40px rgba(37, 99, 235, 0.2)",
  },
  title: {
    marginBottom: 8,
    fontSize: "2.75rem",
    fontWeight: "700",
  },
  tagline: {
    fontSize: "1.15rem",
    marginBottom: "2.5rem",
    color: "#374151",
    fontWeight: 600,
    lineHeight: 1.4,
  },
  verseHighlight: {
    fontStyle: "italic",
    backgroundColor: "#dbeafe",
    padding: "1.2rem 1.5rem",
    borderRadius: 14,
    marginBottom: "2.5rem",
    fontSize: "1.2rem",
    color: "#1e3a8a",
    boxShadow: "inset 3px 3px 8px #a3bffa",
  },
  features: {
    textAlign: "left",
    marginBottom: "3rem",
  },
  featureItem: {
    display: "flex",
    alignItems: "center",
    marginBottom: "1.3rem",
    fontWeight: 600,
    fontSize: "1.07rem",
    color: "#1f2937",
    cursor: "default",
    userSelect: "none",
  },
  downloadButtons: {
    display: "flex",
    justifyContent: "center",
    gap: "1.8rem",
    flexWrap: "wrap",
    marginBottom: "2.5rem",
  },
  btn: {
    color: "white",
    fontWeight: 700,
    padding: "1rem 2rem",
    borderRadius: 14,
    textDecoration: "none",
    fontSize: "1.15rem",
    display: "flex",
    alignItems: "center",
    gap: "0.7rem",
    boxShadow: "0 8px 18px rgba(37, 99, 235, 0.4)",
    userSelect: "none",
    transition: "all 0.3s ease",
  },
  footer: {
    fontSize: "0.9rem",
    color: "#6b7280",
    fontStyle: "italic",
  },
};

export default BirdeyeLanding;
