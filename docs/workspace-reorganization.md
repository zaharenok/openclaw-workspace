# 📁 Workspace Structure Reorganization Proposal

**Goal:** Separate business projects from personal projects for better organization and clarity.

---

## 🏗️ Proposed Structure

```
~/repos/
├── business/           # 💼 Business & Client Projects
│   ├── araninc-reports/
│   ├── austrian-ai-agency/
│   ├── Meta_ads_bulk_harmozi_generator/
│   ├── StromPlan_website/
│   ├── crunchbase-news-scraper/
│   ├── garage-door-automation/
│   ├── weenergy_api/
│   └── davinci-checker/
│
├── personal/           # 👤 Personal & Hobby Projects
│   ├── Apify_youtube_scraper/
│   ├── AutoTitle_Obsidian_plugin/
│   ├── Davinci_subs/
│   ├── HTF2020/
│   ├── Hacktoberfest2020/
│   ├── Integrator/
│   ├── LlamaMind/
│   ├── PDF_dewrapper/
│   ├── Pet_projects_vas3kclub_scraper/
│   ├── Promptix_clone/
│   ├── RUHacks/
│   ├── SIP_telephone_v01/
│   ├── ScribaScriptum/
│   ├── SmartPDF-OCR/
│   ├── SportChat/
│   ├── SportChat_ver3/
│   ├── Willnicht_ui/
│   ├── ai-video-transcriber/
│   ├── awesome-claude-prompts/
│   ├── claude_code_maestro/
│   ├── dtld_parsing/
│   ├── face_recognition/
│   ├── free-medium-extension/
│   ├── health_idea/
│   ├── intelmed/
│   ├── mjamChecker/
│   ├── movie_sites/
│   ├── obsidian-autotitle/
│   ├── obsidian-releases/
│   ├── standupstoreparser/
│   ├── tl_ssd/
│   ├── universal-community-landing-page/
│   ├── vas3k.club.fork/
│   ├── vienna_metro_app/
│   ├── yandexvacancy/
│   ├── youtube-transcript-processor-obsidian-plugin/
│   └── zaharenok/
│
├── tools/              # 🛠️ Utilities & Scripts
│   ├── thepopebot/     # Automation framework
│   └── integrations/   # API integrations
│
└── archive/            # 📦 Old/Inactive Projects
    ├── HTF2020/
    ├── Hacktoberfest2020/
    ├── RUHacks/
    └── SIP_telephone_v01/
```

---

## 📊 Categorization Logic

### 💼 Business Projects (8 repos)

| Repo | Purpose | Status |
|------|---------|--------|
| **araninc-reports** | Client reports (Aran Inc) | ✅ Active |
| **austrian-ai-agency** | Agency website/portfolio | ✅ Active |
| **Meta_ads_bulk_harmozi_generator** | Client work (Harmozi) | ✅ Active |
| **StromPlan_website** | Client website (Austrian energy) | ✅ Active |
| **crunchbase-news-scraper** | Business intelligence tool | 🟡 Maybe |
| **garage-door-automation** | Smart home for client/business | ✅ Active |
| **weenergy_api** | Energy API integration | ✅ Active |
| **davinci-checker** | Client billing automation | ✅ Active |

**Total Business:** 8 repos

---

### 👤 Personal Projects (35 repos)

#### Active Development
- **AutoTitle_Obsidian_plugin** → Obsidian plugin (hobby)
- **obsidian-autotitle** → Obsidian plugin (hobby)
- **obsidian-releases** → Community contributions
- **youtube-transcript-processor-obsidian-plugin** → Obsidian plugin
- **health_idea** → Personal health tracking
- **mjamChecker** → Food ordering automation (personal)

#### Learning & Experiments
- **LlamaMind** → AI/ML experiments
- **claude_code_maestro** → AI experiments
- **awesome-claude-prompts** → Prompt library
- **ai-video-transcriber** → Transcription tool (personal)
- **face_recognition** → CV experiments

#### Pet Projects & Fun
- **Pet_projects_vas3kclub_scraper** → Vas3k.club scraper
- **vas3k.club.fork** → Vas3k.club fork
- **SportChat** → Sports chat app (hobby)
- **SportChat_ver3** → Sports chat app v3
- **vienna_metro_app** → Vienna metro app
- **movie_sites** → Movie discovery

#### Utilities & Tools
- **Apify_youtube_scraper** → YouTube scraper
- **Davinci_subs** → Subtitle tools
- **PDF_dewrapper** → PDF processing
- **SmartPDF-OCR** → OCR tool
- **free-medium-extension** → Medium enhancement
- **dtld_parsing** → Data parsing
- **standupstoreparser** → Store parsing

#### Inactive/Old (Archive)
- **HTF2020** → Hacktoberfest 2020 (old)
- **Hacktoberfest2020** → Hacktoberfest 2020 (old)
- **RUHacks** → Old hackathon (old)
- **SIP_telephone_v01** → Old VoIP project (old)
- **Integrator** → Old integration project
- **Promptix_clone** → Clone project (old)
- **ScribaScriptum** → Old project
- **Willnicht_ui** → Old UI project
- **tl_ssd** → Unknown (old?)
- **universal-community-landing-page** → Landing page template
- **yandexvacancy** → Yandex job scraper
- **zaharenok** → Personal GitHub profile README

**Total Personal:** 35 repos

---

### 🛠️ Tools & Infrastructure (3 repos)

| Repo | Purpose |
|------|---------|
| **thepopebot** | Automation framework (z.ai integration) |
| **OpenClaw workspace** | Main workspace (separate) |

---

## 🚀 Migration Plan

### Step 1: Create Structure
```bash
cd ~/repos
mkdir -p business personal tools archive
```

### Step 2: Move Business Projects
```bash
mv araninc-reports business/
mv austrian-ai-agency business/
mv Meta_ads_bulk_harmozi_generator business/
mv StromPlan_website business/
mv garage-door-automation business/
mv weenergy_api business/
mv davinci-checker business/
mv crunchbase-news-scraper business/  # Optional
```

### Step 3: Move Personal Projects
```bash
# Active personal projects
mv AutoTitle_Obsidian_plugin personal/
mv obsidian-autotitle personal/
mv obsidian-releases personal/
mv youtube-transcript-processor-obsidian-plugin personal/
mv health_idea personal/
mv mjamChecker personal/

# Learning & experiments
mv LlamaMind personal/
mv claude_code_maestro personal/
mv awesome-claude-prompts personal/
mv ai-video-transcriber personal/
mv face_recognition personal/

# Pet projects
mv Pet_projects_vas3kclub_scraper personal/
mv vas3k.club.fork personal/
mv SportChat personal/
mv SportChat_ver3 personal/
mv vienna_metro_app personal/
mv movie_sites personal/

# Utilities
mv Apify_youtube_scraper personal/
mv Davinci_subs personal/
mv PDF_dewrapper personal/
mv SmartPDF-OCR personal/
mv free-medium-extension personal/
mv dtld_parsing personal/
mv standupstoreparser personal/

# Other personal
mv zaharenok personal/
mv yandexvacancy personal/
mv universal-community-landing-page personal/
mv Promptix_clone personal/
mv ScribaScriptum personal/
mv Willnicht_ui personal/
mv tl_ssd personal/
mv Integrator personal/
```

### Step 4: Archive Old Projects
```bash
mv HTF2020 archive/
mv Hacktoberfest2020 archive/
mv RUHacks archive/
mv SIP_telephone_v01 archive/
```

### Step 5: Move Tools
```bash
mv thepopebot tools/
```

---

## ✅ Benefits

### 💼 Business Folder
- **Clear separation** of client work
- **Easy to backup** important projects
- **Professional appearance** for demos
- **Time tracking** focus on billable work

### 👤 Personal Folder
- **Creative freedom** for experiments
- **No client pressure**
- **Learning projects** grouped together
- **Hobby projects** easily accessible

### 📦 Archive
- **Cleaner main workspace**
- **Historical record** of old work
- **Easy to restore** if needed

### 🛠️ Tools
- **Infrastructure separate** from projects
- **Shared utilities** in one place
- **Clear distinction** between tools and projects

---

## 🔄 Alternative: Git Worktree Approach

Instead of moving repos, use Git worktrees:

```bash
# Create worktree structure
mkdir -p ~/work/{business,personal,tools,archive}

# Create worktrees (lightweight links)
cd ~/repos/araninc-reports
git worktree add ~/work/business/araninc-reports main

cd ~/repos/AutoTitle_Obsidian_plugin
git worktree add ~/work/personal/AutoTitle_Obsidian_plugin main
```

**Benefits:**
- Original repos stay in place
- Separate working directories for each purpose
- Easy to switch between contexts

---

## 📝 Notes

- **OpenClaw workspace** (`~/.openclaw/workspace`) stays separate
- **Skills directory** (`~/.openclaw/skills`) not affected
- **GitHub repositories** remote URLs remain the same
- **Git history** preserved in all cases

---

## 🎯 Recommendation

**Start with:**
1. **Business folder** (8 repos) - most important to separate
2. **Archive folder** (4 repos) - clean up old projects
3. **Keep personal mixed** for now (can organize later)

This gives you **immediate business/personal separation** with minimal disruption.

---

**Created:** 2026-02-11 08:00 UTC
**Total repos:** 46
**Business:** 8 | **Personal:** 35 | **Tools:** 2 | **Archive:** 4
