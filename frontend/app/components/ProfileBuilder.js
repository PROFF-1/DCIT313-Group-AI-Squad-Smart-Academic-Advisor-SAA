'use client';

import CourseSelector from './CourseSelector';

export default function ProfileBuilder({
  form,
  setForm,
  meta,
  profiles,
  selectedCourses,
  toggleCourse,
  loadSample,
  loadSavedProfile,
  saveProfile,
  evaluate,
  savingProfile,
  evaluating,
  loadingMeta,
}) {
  return (
    <div className="panel">
      <h2>1. Build Your Profile</h2>

      <div className="field">
        <label>Start from a Template</label>
        <div className="grid2">
          <select onChange={(e) => loadSample(e.target.value)} defaultValue="">
            <option value="" disabled>Load sample student...</option>
            {meta.students.map((student) => (
              <option value={student.id} key={student.id}>{student.id} — {student.name}</option>
            ))}
          </select>
          <select onChange={(e) => loadSavedProfile(e.target.value)} defaultValue="">
            <option value="" disabled>Load saved profile...</option>
            {profiles.map((profile) => (
              <option value={profile.id} key={profile.id}>{profile.name} ({profile.id})</option>
            ))}
          </select>
        </div>
      </div>

      <div className="field">
        <label>Student Information</label>
        <input
          value={form.name}
          onChange={(e) => setForm((prev) => ({ ...prev, name: e.target.value }))}
          placeholder="Enter student's full name"
        />
        <div className="grid2" style={{ marginTop: '1rem' }}>
          <select
            value={form.year}
            onChange={(e) => setForm((prev) => ({ ...prev, year: Number(e.target.value) }))}
          >
            {[1, 2, 3, 4].map((year) => (
              <option value={year} key={year}>Year {year}</option>
            ))}
          </select>
          <input
            type="number"
            step="0.01"
            min="0"
            max="4"
            value={form.gpa}
            onChange={(e) => setForm((prev) => ({ ...prev, gpa: e.target.value }))}
            placeholder="Current GPA (e.g., 3.4)"
          />
        </div>
      </div>

      <div className="field">
        <label>Academic Goal</label>
        <select
          value={form.career_path}
          onChange={(e) => setForm((prev) => ({ ...prev, career_path: e.target.value }))}
        >
          <option value="none">Select a career path (optional)</option>
          {meta.careers.map((career) => (
            <option key={career.id} value={career.id}>{career.label}</option>
          ))}
        </select>
      </div>

      <CourseSelector
        courses={meta.courses}
        selectedCourses={selectedCourses}
        toggleCourse={toggleCourse}
      />

      <div className="actions">
        <button onClick={evaluate} disabled={evaluating || loadingMeta}>
          {evaluating ? 'Evaluating...' : '2. Get Advice'}
        </button>
        <button className="secondary" onClick={saveProfile} disabled={savingProfile || loadingMeta}>
          {savingProfile ? 'Saving...' : 'Save Profile'}
        </button>
      </div>
    </div>
  );
}
