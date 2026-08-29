# Vithey App — AI Requirements & Task List


| Block | AI feature (simple name)      | User value                                               |
| ----- | ----------------------------- | -------------------------------------------------------- |
| **1** | Auto Create CV                | Build CV from profile/project data → apply jobs faster   |
| **2** | Smart Feed for User Audience  | Learn profile → show posts that match this user          |
| **3** | AI Chatbot Q&A                | Ask about jobs, CV, media, finance, interviews           |
| **4** | Skill Score (Certify / track) | Score & track skills from profile + activity             |
| **5** | Job Apply Match Score         | Certify how well this user fits **this job** (top score) |


---



# BLOCK 1 — Auto Create CV (from project / profile data)



## Goal

User taps **Generate CV with AI** → AI reads their Vithey profile + skills + education + work + projects → outputs a ready CV → user can preview / edit / save → use it when applying to a job post.

## Why

- Students often have data already in Profile but no clean CV file  
- Makes **Apply Job** faster and higher quality  
- Competition-friendly: youth career feature



## Requirements


| ID       | Requirement                                                                                 |
| -------- | ------------------------------------------------------------------------------------------- |
| AI-CV-01 | Read profile fields: name, bio, education, work, skills, links, contact                     |
| AI-CV-02 | Optionally include user “projects / posts / job experience” from profile or content         |
| AI-CV-03 | Generate structured CV sections (Summary, Skills, Education, Experience, Projects, Contact) |
| AI-CV-04 | Allow user to edit AI draft before save                                                     |
| AI-CV-05 | Save CV to File Service (PDF or structured JSON + PDF)                                      |
| AI-CV-06 | One-tap use generated CV in **Apply Job** wizard                                            |
| AI-CV-07 | Never invent fake companies/degrees — only use user data + clear “suggested” wording        |
| AI-CV-08 | Works offline-mock first; live via `POST /ai/cv/suggest` (extend to `/ai/cv/generate`)      |




## Tasks (do in order)


| #   | Task                                                                              | Layer           |
| --- | --------------------------------------------------------------------------------- | --------------- |
| 1.1 | Define CV data model (sections + fields) shared Flutter ↔ API                     | Spec            |
| 1.2 | API: `POST /ai/cv/generate` (input: user_id / profile snapshot; output: CV draft) | Backend         |
| 1.3 | Extend existing `POST /ai/cv/suggest` or replace with generate + improve          | Backend         |
| 1.4 | Flutter: “Generate CV with AI” on Profile / Apply CV screen                       | Frontend        |
| 1.5 | Flutter: draft editor (edit sections, regenerate one section)                     | Frontend        |
| 1.6 | Export PDF → upload via file-service → link `cv_file_id`                          | Frontend + File |
| 1.7 | Apply Job: default to latest AI CV if present                                     | Frontend        |
| 1.8 | Mock fixtures for demo without LLM key                                            | Data            |
| 1.9 | Acceptance: empty profile → clear “complete profile first” message                | QA              |




## Entry points in app

- Profile → About / CV tab → **Generate with AI**  
- Apply Job Step 1 → **Create CV with AI** (if no CV uploaded)

---



# BLOCK 2 — AI Personalized Feed (learn profile → show posts for this user)



## Goal

AI learns who the user is (skills, university, interests, follow graph, past likes) and ranks / recommends Home feed posts so this user’s **audience** sees more relevant posters, videos, and jobs.

## Why

- Feed feels personal (not random)  
- Job posts match student major / skills  
- Better engagement for Technical Excellence story



## Requirements


| ID         | Requirement                                                                                    |
| ---------- | ---------------------------------------------------------------------------------------------- |
| AI-FEED-01 | Build a **user interest profile** from: skills, major, follows, likes, applies, search history |
| AI-FEED-02 | Score each candidate post for this user (0–100 relevance)                                      |
| AI-FEED-03 | Home feed mixes: personalized rank + some fresh/explore posts (avoid filter bubble)            |
| AI-FEED-04 | Job posts boosted when skills overlap with job requirements                                    |
| AI-FEED-05 | Respect privacy / blocks; never show blocked authors                                           |
| AI-FEED-06 | Explain lightly (optional): “Because you follow Flutter / Applied Jobs”                        |
| AI-FEED-07 | Fallback: chronological feed if AI unavailable                                                 |
| AI-FEED-08 | Cache recommendations short TTL (Redis) for speed                                              |




## Tasks (do in order)


| #   | Task                                                                           | Layer    |
| --- | ------------------------------------------------------------------------------ | -------- |
| 2.1 | Spec user-feature vector (skills, tags, majors, engagement)                    | Spec     |
| 2.2 | API: `GET /ai/feed/recommendations?limit=` or content-service calls ai-service | Backend  |
| 2.3 | Job: nightly / on-event update of user interest embedding                      | Backend  |
| 2.4 | Content-service: accept ranked post IDs for Home mix                           | Backend  |
| 2.5 | Flutter Home: consume ranked feed; keep pull-to-refresh                        | Frontend |
| 2.6 | Feature flag `USE_AI_FEED=true/false`                                          | Config   |
| 2.7 | Analytics: click-through on recommended vs organic                             | Optional |
| 2.8 | Acceptance: new user with empty profile gets safe default feed                 | QA       |




## Entry points in app

- Home mixed feed (automatic)  
- Optional “For You” vs “Following” tabs (if you add later)

---



# BLOCK 3 — AI Chatbot Q&A (jobs, media, profile, finance…)



## Goal

User opens **Vithey AI** and asks questions in natural language. Bot answers using app context (jobs, how to apply, CV tips, interview prep, finance for verified students, how media/posts work).

## Why

- Already a core Vithey module  
- Helps students without leaving the app  
- Supports all other AI blocks (CV help, skill advice, job Q&A)



## Requirements


| ID        | Requirement                                                                     |
| --------- | ------------------------------------------------------------------------------- |
| AI-BOT-01 | Chat sessions: new / continue / history / delete                                |
| AI-BOT-02 | Topics: `CV`, `JOB`, `INTERVIEW`, `STUDENT`, `FINANCE`, (+ `MEDIA` / general)   |
| AI-BOT-03 | Answers in Markdown; safe, student-friendly tone                                |
| AI-BOT-04 | Can use **user context** (profile summary, open applications) when authorized   |
| AI-BOT-05 | Can explain **media types** (poster / video / job post) and how to create/apply |
| AI-BOT-06 | Suggestion chips on empty home (quick prompts)                                  |
| AI-BOT-07 | Streaming reply (nice-to-have); Stop generation                                 |
| AI-BOT-08 | Copy / share / regenerate actions                                               |
| AI-BOT-09 | JWT via Gateway; no fake login in AI service                                    |
| AI-BOT-10 | Mock mode when no AI API key                                                    |




## Tasks (do in order)


| #   | Task                                                                   | Layer             |
| --- | ---------------------------------------------------------------------- | ----------------- |
| 3.1 | Keep Flutter chatbot UI (already largely complete)                     | Frontend          |
| 3.2 | Harden `POST /ai/chat`, sessions list/messages/delete                  | Backend           |
| 3.3 | Add topic `MEDIA` + job/media system prompts                           | Backend           |
| 3.4 | Inject safe user context (name, skills, verification) into LLM prompt  | Backend           |
| 3.5 | Optional: tool calls to search open jobs / user’s applications         | Backend           |
| 3.6 | Streaming `POST /ai/chat/stream` (SSE)                                 | Backend + Flutter |
| 3.7 | Deep-link from notifications “AI response ready”                       | Optional          |
| 3.8 | Acceptance: finance answers only if student verified (or generic tips) | QA                |




## Entry points in app

- Home app bar → Vithey AI  
- Profile / Apply Job → “Ask AI” shortcuts  
- Suggestions: “Help me write a CV”, “How to apply this job?”, “Explain this post type”

---



# BLOCK 4 — Skill Score / Skill Tracking (Certify score)



## Goal

AI scores and tracks user skills (from profile skill % + posts + applications + chatbot practice). Shows a **skill score** (e.g. 0–100 per skill or overall “Career readiness”) so users know what to improve before applying.

> “Setify score” here = **skill certify / skill score tracking**.



## Why

- Makes Profile skills meaningful (not just self-typed %)  
- Guides learning path + AI chatbot practice  
- Helps job matching (Block 2) and CV quality (Block 1)



## Requirements


| ID       | Requirement                                                                                                      |
| -------- | ---------------------------------------------------------------------------------------------------------------- |
| AI-SK-01 | Store skills with level / percent on profile (already exists)                                                    |
| AI-SK-02 | Compute **AI skill score** per skill using signals: self-rating, related posts, applications, quiz/chat practice |
| AI-SK-03 | Show overall **Career readiness score** on Profile                                                               |
| AI-SK-04 | Suggest next skills to improve (top 3)                                                                           |
| AI-SK-05 | Optional micro-assessment via Chatbot (“Ask me 3 Flutter questions”)                                             |
| AI-SK-06 | Score updates when profile or activity changes                                                                   |
| AI-SK-07 | Transparent: show “how this score is calculated” (simple rules)                                                  |
| AI-SK-08 | No public shaming — visitor sees only what privacy allows                                                        |




## Tasks (do in order)


| #   | Task                                                                | Layer    |
| --- | ------------------------------------------------------------------- | -------- |
| 4.1 | Spec scoring formula (weights for self / activity / assessment)     | Spec     |
| 4.2 | API: `GET /ai/skills/score`, `POST /ai/skills/assess`               | Backend  |
| 4.3 | Persist scores in `ai_db` or profile extension                      | Backend  |
| 4.4 | Flutter Profile About: skill rings use AI score + self %            | Frontend |
| 4.5 | Flutter: “Improve skills” → opens Chatbot assessment topic          | Frontend |
| 4.6 | Feed job matching uses skill scores (link Block 2)                  | Backend  |
| 4.7 | CV generate prefers high-score skills first (link Block 1)          | Backend  |
| 4.8 | Acceptance: new user score = self-rating only until activity exists | QA       |




## Entry points in app

- Profile → About → Skills section  
- Chatbot → “Test my skills”  
- Optional Home card: “Your readiness: 72 — Improve”

---



# BLOCK 5 — Job Apply Match Score (certify fit for this job)



## Goal

When a user applies (or is about to apply) to a **specific job post**, AI compares their profile + skills + CV against **that job’s title / description / requirements** and returns a **match / certify score** (0–100) plus short reasons. Top scores help the applicant know fit, and help the job poster rank applicants.

## Why

- Block 4 scores skills in general; Block 5 scores **this user × this job**  
- Applicants see “You match 86% — strong on Flutter, weak on Docker” before submit  
- Job posters see AI match on applicant list / detail (fairer shortlist)  
- Ties Auto CV (Block 1) + Skill Score (Block 4) into Apply Job flow



## Requirements


| ID        | Requirement                                                                               |
| --------- | ----------------------------------------------------------------------------------------- |
| AI-JOB-01 | Input: `job_post_id` + applicant `user_id` (and optional `cv_file_id`)                    |
| AI-JOB-02 | Load job fields: title, description, requirements, deadline                               |
| AI-JOB-03 | Load applicant: profile, skills (prefer Block 4 scores), education, work, CV text/summary |
| AI-JOB-04 | Output **match score 0–100** + label (e.g. Excellent / Good / Fair / Low)                 |
| AI-JOB-05 | Output **top matched skills** and **missing / weak skills** for this job                  |
| AI-JOB-06 | Output short **AI reason** (3–5 bullets, student-friendly, no fake claims)                |
| AI-JOB-07 | Show score on **Apply Job review** step before submit                                     |
| AI-JOB-08 | Store score on application (`career-service`) for poster applicant list/detail            |
| AI-JOB-09 | Poster can sort/filter applicants by AI match score                                       |
| AI-JOB-10 | Optional: “Improve to raise score” → Chatbot or regenerate CV                             |
| AI-JOB-11 | Recalculate when CV or profile updates before decision (not after final decision)         |
| AI-JOB-12 | Mock mode without LLM (rule-based skill overlap) for demo                                 |
| AI-JOB-13 | Transparent disclaimer: “AI assist only — not a hiring decision”                          |




## Tasks (do in order)


| #    | Task                                                                                       | Layer          |
| ---- | ------------------------------------------------------------------------------------------ | -------------- |
| 5.1  | Spec match score formula (skills overlap + experience + education + CV keywords)           | Spec           |
| 5.2  | API: `POST /ai/jobs/{jobPostId}/match` → `{ score, label, matched_skills, gaps, reasons }` | Backend        |
| 5.3  | career-service: save `ai_match_score` (+ snapshot JSON) on application create/update       | Backend        |
| 5.4  | Flutter Apply Job review: show match card before Submit                                    | Frontend       |
| 5.5  | Flutter Applicant list/detail (poster): show score badge + reasons                         | Frontend       |
| 5.6  | Sort applicants by AI score (highest first)                                                | Frontend + API |
| 5.7  | CTA “Improve match” → Chatbot topic JOB or Block 1 CV regenerate                           | Frontend       |
| 5.8  | Feature flag `USE_AI_JOB_MATCH=true/false`                                                 | Config         |
| 5.9  | Acceptance: empty skills → low score + clear “add skills to improve”                       | QA             |
| 5.10 | Acceptance: poster never sees score as “guarantee hire” (disclaimer visible)               | QA             |




## Entry points in app

- Job card / Post Detail → Apply → **Review** step → Match score card  
- Profile → Applied Jobs → tap application → see your score for that job  
- Poster → Job applicants list → sort by **AI Match**  
- Applicant detail → AI certify panel (score + gaps)

---



## Cross-block shared tasks (do once)


| #   | Shared task                                                                                   | Why                 |
| --- | --------------------------------------------------------------------------------------------- | ------------------- |
| S1  | One `ai-service` owns all AI APIs                                                             | Single LLM gateway  |
| S2  | Feature flags: `USE_MOCK_AI`, `USE_AI_FEED`, `USE_AI_CV`, `USE_AI_SKILLS`, `USE_AI_JOB_MATCH` | Safe demo / rollout |
| S3  | Env: `AI_PROVIDER`, `AI_API_KEY`, `AI_MODEL`                                                  | DevOps / prod       |
| S4  | Rate limit AI endpoints at Gateway                                                            | Cost + abuse        |
| S5  | Never send passwords, CV binary, or payment secrets to LLM                                    | Security            |
| S6  | Log prompt/response IDs only (not full PII dumps)                                             | Privacy             |
| S7  | Document APIs in OpenAPI / `API_ENDPOINTS.md`                                                 | Team clarity        |


---

---



## Master checklist (all AI on this app)



### Block 1 — Auto CV

- [ ] Generate CV from profile/project data  
- [ ] Edit draft + save file  
- [ ] Use in Apply Job  



### Block 2 — Personalized feed

- [ ] User interest model  
- [ ] Ranked Home posts / jobs  
- [ ] Fallback chronological  



### Block 3 — Chatbot Q&A

- [ ] Sessions + history  
- [ ] Job / CV / interview / finance / media answers  
- [ ] Context-aware + mock mode  



### Block 4 — Skill score

- [ ] Per-skill + overall score  
- [ ] Improve suggestions + optional assessment  
- [ ] Linked to CV + feed  



### Block 5 — Job apply match score

- [ ] Score user vs this job (0–100 + reasons)  
- [ ] Show on Apply review + poster applicant list  
- [ ] Gaps + improve CTA; disclaimer  



### Shared

- [ ] Flags, secrets, rate limit, privacy  

---



## One-sentence summary per block

1. **Auto CV** — AI writes your CV from Vithey profile so applying is easy.
2. **Smart Feed** — AI learns your profile and shows posts/jobs for *you*.
3. **Chatbot** — Ask anything about jobs, media, CV, interviews, student life.
4. **Skill Score** — AI tracks and scores your skills so you know what to improve.
5. **Job Match Score** — AI certifies how well you fit **this job** when you apply (top score + gaps).

