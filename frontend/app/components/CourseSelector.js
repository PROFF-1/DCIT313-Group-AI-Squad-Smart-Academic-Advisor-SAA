'use client';

import { useMemo, useState } from 'react';

export default function CourseSelector({ courses, selectedCourses, toggleCourse }) {
  const [search, setSearch] = useState('');

  const filteredCourses = useMemo(() => {
    const q = search.trim().toLowerCase();
    if (!q) return courses;
    return courses.filter((course) => {
      const text = `${course.id} ${course.name}`.toLowerCase();
      return text.includes(q);
    });
  }, [courses, search]);

  const groupedCourses = useMemo(() => {
    return [1, 2, 3, 4].map((level) => ({
      level,
      courses: filteredCourses.filter((course) => course.level === level)
    })).filter(group => group.courses.length > 0);
  }, [filteredCourses]);

  return (
    <div className="field">
      <label>Completed Courses</label>
      <input
        placeholder="Search completed courses by ID or name..."
        value={search}
        onChange={(e) => setSearch(e.target.value)}
      />
      <div className="coursesBox">
        {groupedCourses.length > 0 ? groupedCourses.map((group) => (
          <div key={group.level}>
            <h4>Year {group.level}</h4>
            {group.courses.map((course) => (
              <label key={course.id} className="courseRow">
                <input
                  type="checkbox"
                  checked={selectedCourses.includes(course.id)}
                  onChange={() => toggleCourse(course.id)}
                />
                <span><strong>{course.id.toUpperCase()}</strong>: {course.name}</span>
              </label>
            ))}
          </div>
        )) : <p className="placeholder" style={{padding: '1rem 0'}}>No courses match your search.</p>}
      </div>
    </div>
  );
}
