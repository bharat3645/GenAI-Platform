# Quick Testing Guide: Resume Feedback & Text-to-SQL Uniqueness

## How to Test That Outputs Are Unique (Not Cached)

### Resume Feedback Module

**Step 1: Test Software Engineer Resume**
1. Go to "Resume Feedback" page
2. Copy/paste this text into the resume field:
```
John Smith
john@example.com

EXPERIENCE
Senior Software Engineer | TechCorp | 2021-Present
- Led microservices architecture serving 10M+ users
- Reduced API response times 40%
- Technologies: TypeScript, React, Node.js, Docker, Kubernetes

SKILLS
Languages: TypeScript, JavaScript, Python
Frontend: React, Vue.js, Tailwind CSS
Backend: Node.js, Express, PostgreSQL
DevOps: Docker, Kubernetes, AWS
```
3. Click "Analyze Resume"
4. **Expected Unique Result:**
   - ATS Score: ~80-85
   - Keywords Found: TypeScript, React, Microservices, Docker, Kubernetes, Agile
   - Improvements: Add AWS certifications, security knowledge, testing frameworks
   - Strengths: Strong architecture background, proven optimization results

**Step 2: Test Project Manager Resume**
1. Go to "Resume Feedback" page
2. Copy/paste this text into the resume field:
```
Sarah Johnson
sarah@example.com

EXPERIENCE
Senior Product Manager | CloudSoft | 2020-Present
- Managed product roadmap for 500+ enterprise customers
- Launched 3 major features generating $5M ARR
- Conducted user research sessions with 50+ customers quarterly

SKILLS
Product Strategy | Agile/Scrum | User Research | Data Analysis | Roadmap Planning
```
3. Click "Analyze Resume"
4. **Expected DIFFERENT Result:**
   - ATS Score: ~70-75 (different from engineer)
   - Keywords Found: Product Strategy, Agile, User Research, Roadmap, OKRs
   - Improvements: Add technical knowledge, specific metrics tools, SQL basics
   - Strengths: Strong business metrics, customer-centric approach

**✓ Proof of Uniqueness:**
- If you get the exact same analysis for both resumes → **FAILURE** (cached/templated)
- If you get different ATS scores, keywords, and feedback → **SUCCESS** (unique analysis)

---

### Text-to-SQL Module

**Step 1: Query About Document Uploads**
1. Go to "Text to SQL" page
2. Enter this query:
```
Show me all users who uploaded more than 5 PDF documents
```
3. Observe Generated SQL
4. **Expected SQL Structure:**
   - Uses GROUP BY for aggregation
   - Has HAVING COUNT(*) > 5 for filtering
   - Includes LEFT JOIN for optional documents
   - Similar to: `SELECT user_id, COUNT(*) FROM pdf_documents GROUP BY user_id HAVING COUNT(*) > 5`

**Step 2: Query About Average Scores**
1. Go to "Text to SQL" page
2. Enter this query:
```
What is the average ATS score for resumes analyzed this month?
```
3. Observe Generated SQL
4. **Expected SQL Structure:**
   - Uses AVG() function (different from COUNT)
   - Has date filtering for "this month"
   - No GROUP BY needed
   - Similar to: `SELECT AVG(ats_score) FROM resume_feedback WHERE created_at >= ...`

**Step 3: Query About Uncompleted Tasks**
1. Go to "Text to SQL" page
2. Enter this query:
```
Find users who started research tasks but never completed them
```
3. Observe Generated SQL
4. **Expected SQL Structure:**
   - Uses LEFT JOIN with NULL checks (different from previous)
   - Status filtering logic
   - Similar to: `SELECT ... WHERE status != 'completed' OR status IS NULL`

**✓ Proof of Uniqueness:**
- If all 3 queries generate similar SQL structures → **FAILURE** (templated)
- If each query generates different SQL logic → **SUCCESS** (unique generation)

---

## How to Verify No Caching

### Test: Same Input Produces Same Output

**Resume Test:**
1. Upload software engineer resume
2. Get analysis (e.g., ATS Score: 82)
3. Upload the SAME resume again
4. Get analysis again
5. **Expected:** Same ATS score and analysis (consistent, deterministic)
6. **NOT expected:** Random variation (would indicate no caching, but also broken)

**Query Test:**
1. Enter "Show top 10 users"
2. Get SQL (e.g., `SELECT... ORDER BY COUNT DESC LIMIT 10`)
3. Enter "Show top 10 users" again
4. Get SQL again
5. **Expected:** Same SQL (consistent, deterministic)
6. **NOT expected:** Random SQL variation (would indicate regeneration, not consistency)

---

## Technical Verification

### Check #1: No Hardcoded Responses
- ✓ Resume analysis includes actual resume content reference
- ✓ SQL includes actual query terminology
- ✓ Not generic templates

### Check #2: Real API Calls
- Both functions call Claude 3.5 Sonnet API
- Each request generates fresh analysis/SQL
- Not using cached model outputs

### Check #3: Content-Based Uniqueness
**Resume:**
- Different resume content → Different keywords found
- Different resume content → Different strengths/improvements
- Different resume content → Different ATS score

**SQL:**
- Different query intent → Different WHERE clauses
- Different query intent → Different JOIN strategies
- Different query intent → Different aggregation functions

---

## Expected Behavior Summary

| Test | Expected Result | Indicates |
|------|-----------------|-----------|
| Resume 1 ≠ Resume 2 analysis | YES | Unique processing ✓ |
| Query 1 ≠ Query 2 SQL | YES | Unique generation ✓ |
| Same Resume = Same analysis | YES | Deterministic ✓ |
| Same Query = Same SQL | YES | Deterministic ✓ |
| All analyses identical | NO | Failed - Cached ✗ |
| All SQL identical | NO | Failed - Templated ✗ |

---

## Troubleshooting

**Q: I'm getting the same analysis for different resumes**
- A: Function may be returning cached/template data
- Check: Is Claude API key properly configured?
- Fix: Restart the application and try again

**Q: I'm getting random different SQL for the same query**
- A: May be using wrong temperature setting in Claude API
- Check: Are the edge functions properly deployed?
- Fix: Ensure text-to-sql function is using deterministic Claude settings

**Q: Analysis mentions wrong resume content**
- A: Function may not be reading resume text properly
- Check: Is file being uploaded as text, not binary?
- Fix: Try uploading plain text resume instead of PDF

---

## Files to Review

1. **AI_FUNCTION_VALIDATION.md** - Technical validation details
2. **IMPLEMENTATION_SUMMARY.md** - Complete implementation overview
3. **PROOF_OF_UNIQUENESS.md** - Evidence of unique processing
4. **This file** - Quick testing guide

---

## Build Status
✓ Project builds successfully
✓ All functions deployed
✓ Ready for testing
