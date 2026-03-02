# 🃏 Poker Strategy - Complete Preflop System

<p align="center">
  <img src="https://img.shields.io/badge/Poker-Texas%20Hold'em-blue?style=for-the-badge" alt="Texas Hold'em">
  <img src="https://img.shields.io/badge/Strategy-GTO-green?style=for-the-badge" alt="GTO Strategy">
  <img src="https://img.shields.io/badge/Python-3.10+-yellow?style=for-the-badge&logo=python" alt="Python 3.10+">
  <img src="https://img.shields.io/badge/Status-Complete-success?style=for-the-badge" alt="Complete">
</p>

---

## 📚 Overview

Complete poker preflop strategy system based on Game Theory Optimal (GTO) principles. This repository contains preflop charts, an interactive Python trainer, online resources, and mathematical foundations for Texas Hold'em 6-Max cash games.

**Perfect for:** Beginners to intermediate players who want to master preflop play.

---

## 🎯 What's Included

### 📖 **Complete Theory** (`PREFLOP_STRATEGY.md`)
- GTO-based ranges for every position
- Equity tables and mathematics
- Rules for different hand types
- Position value analysis
- Bankroll management tips

### 📊 **Quick Reference Chart** (`PREFLOP_CHART_QUICK.txt`)
- Visual table for instant lookup
- Color-coded actions (✅ RAISE | ❌ FOLD | ⚡ DEPENDS)
- Print-ready format
- All positions covered (UTG → BTN → Blinds)

### 🎮 **Interactive Trainer** (`preflop_trainer.py`)
- Practice with random hands and positions
- Real-time feedback on decisions
- Score tracking and mistake analysis
- Customizable question count
- Progressive difficulty

### 🌐 **Online Resources** (`ONLINE_RESOURCES.md`)
- **Preflop Prodigy** (Upswing Poker) — FREE solver-backed charts
- **GTO Wizard** — Professional AI solver
- Comparison of tools
- Learning roadmap

### 📖 **Quick Start** (`README.md`)
- 3 essential rules
- Hand categories guide
- Quick reference card
- Next steps

### 📘 **Complete Guide** (`COMPLETE_GUIDE.md`)
- Step-by-step learning plan
- Progress tracking
- Success metrics
- Pro tips

---

## 🚀 Quick Start

### Option 1: Train Now (10 minutes)
```bash
# Clone the repo
git clone https://github.com/zaharenok/poker-strategy.git
cd poker-strategy

# Run the trainer
python3 preflop_trainer.py
```

### Option 2: Study First
```bash
# Read the complete guide
cat COMPLETE_GUIDE.md

# Then practice
python3 preflop_trainer.py
```

### Option 3: Use Online Tools
1. Open **Preflop Prodigy**: https://upswingpoker.com/preflop/
2. Choose your position
3. Study the solver-backed charts
4. Come back here to practice

---

## 📊 Core Concepts

### The 3 Golden Rules:
1. ✅ **Never limp** (except pairs 22-99 for set-mining)
2. ✅ **Position > Cards** (BTN is always better than UTG)
3. ✅ **Tight is right** (start tight, expand later)

### Position Value:
| Position | Profit (BB/100) | Action |
|----------|-----------------|--------|
| **BTN** | +30 | Raise wide |
| **CO** | +10 | Raise wide |
| **MP** | 0 | Be selective |
| **UTG** | -10 | Only premium |

### Hand Categories:
- **🔥 Premium:** AA, KK, QQ, AK → Always raise
- **💪 Strong:** JJ, TT, AQ, KQ → Raise from position
- **🎲 Speculative:** Suited connectors, small pairs → Deep stacks only
- **❌ Trash:** Weak offsuit → Always fold

---

## 🎓 Learning Path

### Week 1: Foundation
- [ ] Read `COMPLETE_GUIDE.md`
- [ ] Understand position value
- [ ] Learn "green zone" hands (RAISE ALWAYS)
- [ ] Practice with trainer (20 questions/day)

### Week 2-3: Practice
- [ ] Daily trainer: 20 questions
- [ ] Focus on weak positions
- [ ] Use Preflop Prodigy for verification
- [ ] Goal: 80%+ accuracy

### Week 4: Mastery
- [ ] Try GTO Wizard (free trial)
- [ ] Analyze your own hands
- [ ] Study postflop play
- [ ] Goal: 90%+ accuracy

---

## 🛠️ Technical Details

### Trainer Script (`preflop_trainer.py`)
- **Language:** Python 3.10+
- **Dependencies:** None (standard library only)
- **Features:**
  - Random hand generation
  - Position-based ranges
  - Real-time feedback
  - Score tracking
  - Mistake analysis by position

### Usage:
```bash
# Interactive mode
python3 preflop_trainer.py

# Specify question count
echo -e "20\n" | python3 preflop_trainer.py

# Run multiple rounds
for i in {1..5}; do echo -e "10\n" | python3 preflop_trainer.py; done
```

---

## 🌐 Free Online Tools

### Preflop Prodigy (Upswing Poker)
- **URL:** https://upswingpoker.com/preflop/
- **Cost:** FREE (for now)
- **Features:**
  - Solver-backed charts
  - Mobile + Desktop
  - Instant lookup
  - All positions covered

### GTO Wizard
- **URL:** https://gtowizard.com
- **Cost:** Freemium (free trial available)
- **Features:**
  - AI solver (millions of spots)
  - Practice trainer
  - Game analysis
  - ICM support

---

## 📈 Progress Tracking

### Success Metrics:
- **Beginner:** 70%+ accuracy on trainer
- **Intermediate:** 80%+ accuracy, know "green zone"
- **Advanced:** 90%+ accuracy, use GTO Wizard
- **Expert:** Sustained profit, postflop mastery

### Common Mistakes:
- ❌ Limping with premium hands
- ❌ Calling 3-bets with weak hands
- ❌ Defending too wide OOP
- ❌ Playing trash hands from UTG

---

## 💡 Pro Tips

### ✅ DO:
- Follow position guidelines
- Study with Preflop Prodigy
- Practice daily with trainer
- Review your mistakes
- Start tight, expand later

### ❌ DON'T:
- Don't limp with AA-QQ
- Don't call 3-bets with weak hands
- Don't auto-pilot (think!)
- Don't neglect position
- Don't play trash hands

---

## 📁 File Structure

```
poker-strategy/
├── README.md                   ← This file
├── COMPLETE_GUIDE.md           ← 📘 Full guide (START HERE!)
├── PREFLOP_STRATEGY.md         ← 📖 Theory + math
├── PREFLOP_CHART_QUICK.txt     ← 📊 Quick chart (printable!)
├── preflop_trainer.py          ← 🎮 Interactive trainer
├── ONLINE_RESOURCES.md         ← 🌐 Free + paid tools
└── LICENSE                     ← MIT License
```

---

## 🤝 Contributing

This is a personal project for learning purposes. However, suggestions and improvements are welcome!

1. Fork the repo
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🎓 Acknowledgments

- **Upswing Poker** — Preflop Prodigy (free charts)
- **GTO Wizard** — Solver technology and education
- **Matthew Janda** — "Applications of No-Limit Hold'em"
- **Sklansky & Miller** — "No Limit Hold'em: Theory and Practice"

---

## 📞 Support

For questions or feedback:
- Open an issue on GitHub
- Study the `COMPLETE_GUIDE.md`
- Use the `preflop_trainer.py` to practice

---

## 🚀 Next Steps

1. ⭐ **Star this repo** if you find it helpful
2. 📖 **Read the complete guide**
3. 🎮 **Practice with the trainer**
4. 🌐 **Explore Preflop Prodigy**
5. 📈 **Track your progress**

---

<p align="center">
  <b>Remember:</b> Position > Cards | Tight is Right | Practice Makes Perfect
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Made%20with-♥️-red?style=flat-square" alt="Made with love">
  <img src="https://img.shields.io/badge/For-Poker%20Players-blue?style=flat-square" alt="For Poker Players">
  <img src="https://img.shields.io/badge/Based%20on-GTO-green?style=flat-square" alt="Based on GTO">
</p>
