#!/usr/bin/env node

/**
 * Chat Persona Manager - Auto-detects persona based on chat
 */

const fs = require('fs');
const path = require('path');

class ChatPersonaManager {
  constructor() {
    this.configPath = path.join(process.env.HOME || '', '.openclaw/workspace/chat-personas.json');
    this.config = this.loadConfig();
  }

  loadConfig() {
    if (fs.existsSync(this.configPath)) {
      return JSON.parse(fs.readFileSync(this.configPath, 'utf8'));
    }
    return {
      version: 1,
      chats: {},
      rules: [
        {
          pattern: /код|code|programming|develop/i,
          persona: 'code',
          emoji: '💻'
        },
        {
          pattern: /здоровье|health|фитнес|fitness|спорт|sport/i,
          persona: 'health',
          emoji: '🏃'
        },
        {
          pattern: /бизнес|business|стратегия|strategy|работа|work/i,
          persona: 'business',
          emoji: '💼'
        },
        {
          pattern: /творч|creative|design|идеи|ideas/i,
          persona: 'creative',
          emoji: '🎨'
        },
        {
          pattern: /opencode|devops|infra/i,
          persona: 'opencode',
          emoji: '🔧'
        }
      ]
    };
  }

  saveConfig() {
    fs.writeFileSync(this.configPath, JSON.stringify(this.config, null, 2));
  }

  detectPersona(chatTitle, chatId) {
    // Check if explicitly set
    if (this.config.chats[chatId]) {
      return this.config.chats[chatId];
    }

    // Auto-detect from title
    for (const rule of this.config.rules) {
      if (rule.pattern.test(chatTitle)) {
        // Save for next time
        this.config.chats[chatId] = {
          persona: rule.persona,
          emoji: rule.emoji,
          autoDetected: true,
          detectedFrom: chatTitle
        };
        this.saveConfig();
        return this.config.chats[chatId];
      }
    }

    // Default
    return {
      persona: 'default',
      emoji: '🤖',
      autoDetected: true
    };
  }

  setPersona(chatId, persona, emoji = '🤖') {
    this.config.chats[chatId] = {
      persona,
      emoji,
      manual: true
    };
    this.saveConfig();
  }

  getPersona(chatId) {
    return this.config.chats[chatId] || null;
  }

  listChats() {
    return this.config.chats;
  }
}

// CLI
if (require.main === module) {
  const manager = new ChatPersonaManager();
  const args = process.argv.slice(2);
  const command = args[0];

  if (command === 'detect') {
    const title = args[1];
    const chatId = args[2] || 'test';
    const result = manager.detectPersona(title, chatId);
    console.log(`Detected: ${result.emoji} ${result.persona}`);
  } else if (command === 'set') {
    const chatId = args[1];
    const persona = args[2];
    const emoji = args[3] || '🤖';
    manager.setPersona(chatId, persona, emoji);
    console.log(`✅ Set ${emoji} ${persona} for chat ${chatId}`);
  } else if (command === 'list') {
    const chats = manager.listChats();
    console.log('📋 Chat Personas:');
    for (const [id, config] of Object.entries(chats)) {
      const flag = config.manual ? '🔒' : '🔍';
      console.log(`  ${flag} ${id}: ${config.emoji} ${config.persona}`);
    }
  } else {
    console.log(`
Chat Persona Manager

Usage:
  node chat-personas.js detect "<chat title>" [chat_id]
  node chat-personas.js set <chat_id> <persona> [emoji]
  node chat-personas.js list

Auto-detected patterns:
  - 💻 Code: код, code, programming, develop
  - 🏃 Health: здоровье, health, фитнес, fitness, спорт
  - 💼 Business: бизнес, business, стратегия, strategy, работа
  - 🎨 Creative: творч, creative, design, идеи
  - 🔧 OpenCode: opencode, devops, infra
    `);
  }
}

module.exports = ChatPersonaManager;
