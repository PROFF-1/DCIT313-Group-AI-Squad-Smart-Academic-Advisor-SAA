'use client';

const RISK_STYLES = {
  critical: { label: 'Critical', color: '#dc3545', description: 'Immediate action required' },
  high: { label: 'High', color: '#ffc107', description: 'Action recommended' },
  moderate: { label: 'Moderate', color: '#fd7e14', description: 'Monitor closely' },
  low: { label: 'Low', color: '#28a745', description: 'On track' },
};

function toTitle(text) {
  return text
    .split('_')
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(' ');
}

function Section({ title, children, hasData }) {
  if (hasData === false) return null;
  return (
    <div className="block">
      <h3>{title}</h3>
      {children}
    </div>
  );
}

export default function AdvisoryReport({ report, loadingMeta }) {
  if (!report) {
    return (
      <div className="panel">
        <h2>Advisory Report</h2>
        <p className="placeholder">{loadingMeta ? 'Loading data...' : 'Build or load a profile, then click "Get Advice" to see your report.'}</p>
      </div>
    );
  }

  const risk = RISK_STYLES[report.summary.risk] || { label: 'Unknown' };

  return (
    <div className="panel">
      <h2>Advisory Report for {report.student.name}</h2>
      <div className="report">

        <Section title="Student Snapshot">
          <p><strong>Year {report.student.year}</strong> with a <strong>GPA of {report.student.gpa}</strong></p>
          <p>{report.summary.class}</p>
          <p><strong>{report.summary.credits}</strong> credits from <strong>{report.summary.completed_courses}</strong> courses</p>
          <p>
            Academic Risk: <strong style={{ color: risk.color }}>{risk.label}</strong>
            <em style={{ marginLeft: '8px', color: '#6c757d' }}>({risk.description})</em>
          </p>
        </Section>

        <Section title="Key Recommendations" hasData={report.recommendations.next_steps?.length > 0}>
          <ul>
            {(report.recommendations.next_steps || []).map((step, index) => (
              <li key={`step-${index}`}>{step}</li>
            ))}
          </ul>
        </Section>

        <Section title="Courses You Can Take Now" hasData={report.recommendations.courses?.length > 0}>
          <ul>
            {(report.recommendations.courses || []).map((course) => (
              <li key={`eligible-${course.id}`}><strong>{course.id.toUpperCase()}</strong>: {course.name}</li>
            ))}
          </ul>
        </Section>

        <Section title="Career-Path Electives" hasData={report.recommendations.career?.path?.id !== 'none'}>
            <p>For your chosen path in <strong>{report.recommendations.career.path.label}</strong>:</p>
            <ul>
              {(report.recommendations.career.electives || []).map((course) => (
                <li key={`career-${course.id}`}><strong>{course.id.toUpperCase()}</strong>: {course.name}</li>
              ))}
            </ul>
        </Section>
        
        <Section title="Unresolved Issues" hasData={report.progress.missed_out_courses?.length > 0 || report.progress.missing_required_courses?.length > 0}>
          {report.progress.missed_out_courses?.length > 0 && <>
            <h4>Overdue Core Courses</h4>
            <ul>
              {report.progress.missed_out_courses.map((course) => (
                <li key={`missed-${course.id}`}><strong>{course.id.toUpperCase()}</strong>: {course.name}</li>
              ))}
            </ul>
          </>}
          {report.progress.missing_required_courses?.length > 0 && <>
            <h4 style={{marginTop: '1rem'}}>Graduation Requirements Missing</h4>
            <ul>
              {report.progress.missing_required_courses.map((course) => (
                <li key={`req-${course.id}`}><strong>{course.id.toUpperCase()}</strong>: {course.name}</li>
              ))}
            </ul>
          </>}
        </Section>

        <Section title="Graduation Outlook">
          <p>
            Current Status: <strong>{report.graduation.status === 'eligible' ? 'Eligible for Graduation' : 'Not Yet Eligible'}</strong>
          </p>
          {report.graduation.status !== 'eligible' && (
            <ul>
              {(report.graduation.reasons || []).map((reason, index) => (
                <li key={`reason-${index}`}>{toTitle(reason.type)}</li>
              ))}
            </ul>
          )}
        </Section>
      </div>
    </div>
  );
}
