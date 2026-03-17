'use client';

import { useEffect, useState } from 'react';
import ProfileBuilder from './components/ProfileBuilder';
import AdvisoryReport from './components/AdvisoryReport';

const initialForm = {
  name: '',
  year: 1,
  gpa: '',
  career_path: 'none'
};

export default function HomePage() {
  const [meta, setMeta] = useState({ students: [], careers: [], courses: [] });
  const [form, setForm] = useState(initialForm);
  const [selectedCourses, setSelectedCourses] = useState([]);
  const [profiles, setProfiles] = useState([]);
  const [report, setReport] = useState(null);
  const [loadingMeta, setLoadingMeta] = useState(true);
  const [savingProfile, setSavingProfile] = useState(false);
  const [evaluating, setEvaluating] = useState(false);
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');

  async function loadMeta() {
    setLoadingMeta(true);
    setError('');
    const response = await fetch('/api/meta');
    const data = await response.json();

    if (!data.ok) {
      setError(data.error || 'Failed to load app metadata.');
      setLoadingMeta(false);
      return;
    }

    setMeta({ students: data.students, careers: data.careers, courses: data.courses });
    setLoadingMeta(false);
  }

  async function loadProfiles() {
    const response = await fetch('/api/profiles');
    const data = await response.json();
    if (!data.ok) {
      setError(data.error || 'Failed to load saved profiles.');
      return;
    }
    setProfiles(data.profiles || []);
  }

  useEffect(() => {
    loadMeta().then(loadProfiles).catch(() => {
      setError('Initialization failed. Ensure both Next and Prolog servers are running.');
      setLoadingMeta(false);
    });
  }, []);

  function toggleCourse(courseId) {
    setSelectedCourses((prev) =>
      prev.includes(courseId) ? prev.filter((id) => id !== courseId) : [...prev, courseId]
    );
  }

  function payloadFromForm() {
    return {
      name: form.name.trim(),
      year: Number(form.year),
      gpa: Number(form.gpa),
      career_path: form.career_path,
      completed_courses: selectedCourses
    };
  }

  async function saveProfile() {
    setSavingProfile(true);
    setError('');
    setNotice('');

    const response = await fetch('/api/profiles', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payloadFromForm())
    });
    const data = await response.json();

    if (!data.ok) {
      setError(data.error || 'Profile creation failed.');
      setSavingProfile(false);
      return;
    }

    setNotice('Profile created successfully.');
    await loadProfiles();
    setSavingProfile(false);
  }

  async function evaluate() {
    setEvaluating(true);
    setError('');
    setNotice('');

    const response = await fetch('/api/evaluate', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payloadFromForm())
    });

    const data = await response.json();
    if (!data.ok) {
      setError(data.error || 'Could not evaluate profile.');
      setEvaluating(false);
      return;
    }

    setReport(data.report);
    setNotice('Profile evaluated successfully.');
    setEvaluating(false);
  }

  function loadSample(studentId) {
    const student = meta.students.find((item) => item.id === studentId);
    if (!student) return;

    setForm({
      name: student.name,
      year: student.year,
      gpa: student.gpa,
      career_path: 'none'
    });
    setSelectedCourses(student.completed || []);
    setNotice(`Loaded sample student: ${student.name}`);
    setReport(null);
  }

  function loadSavedProfile(profileId) {
    const profile = profiles.find((item) => item.id === profileId);
    if (!profile) return;

    setForm({
      name: profile.name,
      year: profile.year,
      gpa: profile.gpa,
      career_path: profile.career_path || 'none'
    });
    setSelectedCourses(profile.completed || []);
    setNotice(`Loaded saved profile: ${profile.name}`);
    setReport(null);
  }

  return (
    <main className="page">
      <header className="hero">
        <h1>Smart Academic Advisor</h1>
        <p>Create student profiles, track completed courses, and get next-step advice from the Prolog expert system.</p>
      </header>

      {error && <div className="alert error">{error}</div>}
      {notice && <div className="alert success">{notice}</div>}

      <section className="layout">
        <ProfileBuilder
          form={form}
          setForm={setForm}
          meta={meta}
          profiles={profiles}
          selectedCourses={selectedCourses}
          toggleCourse={toggleCourse}
          loadSample={loadSample}
          loadSavedProfile={loadSavedProfile}
          saveProfile={saveProfile}
          evaluate={evaluate}
          savingProfile={savingProfile}
          evaluating={evaluating}
          loadingMeta={loadingMeta}
        />
        <AdvisoryReport report={report} loadingMeta={loadingMeta} />
      </section>
    </main>
  );
}
