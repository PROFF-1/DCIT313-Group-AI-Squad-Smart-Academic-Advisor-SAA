import './globals.css';

export const metadata = {
  title: 'Smart Academic Advisor',
  description: 'Student profile creation and advisory planning powered by Prolog'
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
