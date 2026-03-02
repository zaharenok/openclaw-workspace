#!/usr/bin/env node

/**
 * Context Manager - Solves "prompt too large" errors
 * Compresses and manages context to fit within model limits
 */

const fs = require('fs');
const path = require('path');

class ContextManager {
  constructor(options = {}) {
    this.maxTokens = options.maxTokens || 200000; // Safe limit for most models
    this.compressionRatio = options.compressionRatio || 0.5; // Compress to 50%
    this.debug = options.debug || false;
  }

  /**
   * Analyze context size and suggest actions
   */
  analyze(context) {
    const stats = {
      totalMessages: context.messages?.length || 0,
      totalTokens: this.estimateTokens(JSON.stringify(context)),
      systemTokens: this.estimateTokens(context.system || ''),
      exceedsLimit: false,
      recommendedAction: 'none'
    };

    stats.exceedsLimit = stats.totalTokens > this.maxTokens;

    if (stats.exceedsLimit) {
      const overage = stats.totalTokens - this.maxTokens;
      const reductionNeeded = overage / stats.totalTokens;

      if (reductionNeeded > 0.5) {
        stats.recommendedAction = 'aggressive_compression';
      } else if (reductionNeeded > 0.3) {
        stats.recommendedAction = 'moderate_compression';
      } else {
        stats.recommendedAction = 'light_compression';
      }
    }

    return stats;
  }

  /**
   * Estimate token count (rough approximation)
   */
  estimateTokens(text) {
    if (!text) return 0;
    // Rough estimate: ~4 chars per token
    return Math.ceil(text.length / 4);
  }

  /**
   * Compress context by summarizing old messages
   */
  async compressMessages(messages, options = {}) {
    const {
      keepRecent = 20, // Keep last N messages
      summarizeThreshold = 40, // Summarize messages older than this
      importance = 'system' // Importance metric: 'system', 'user', 'all'
    } = options;

    if (messages.length <= keepRecent) {
      return messages; // No compression needed
    }

    // Split messages
    const recent = messages.slice(-keepRecent);
    const old = messages.slice(0, -keepRecent);

    // Create summary of old messages
    const summary = this.createSummary(old, importance);

    // Return compressed context
    return [
      {
        role: 'system',
        content: `[Previous conversation summary]\\n${summary}`
      },
      ...recent
    ];
  }

  /**
   * Create summary of messages
   */
  createSummary(messages, importance) {
    const keyPoints = [];

    // Extract tool calls
    const toolCalls = messages.filter(m => m.tool_calls?.length > 0);
    if (toolCalls.length > 0) {
      keyPoints.push(`- ${toolCalls.length} tool operations performed`);
    }

    // Extract user requests
    const userMessages = messages.filter(m => m.role === 'user');
    if (userMessages.length > 0) {
      const topics = userMessages.slice(-5).map(m => {
        const text = m.content?.substring(0, 50) || '';
        return text + (text.length >= 50 ? '...' : '');
      });
      keyPoints.push(`- Recent topics: ${topics.join(', ')}`);
    }

    // Extract assistant responses
    const assistantMessages = messages.filter(m => m.role === 'assistant');
    if (assistantMessages.length > 0) {
      keyPoints.push(`- ${assistantMessages.length} assistant responses`);
    }

    return keyPoints.join('\\n');
  }

  /**
   * Remove redundant context
   */
  removeRedundancy(context) {
    if (!context.messages) return context;

    // Remove consecutive duplicate messages
    const cleaned = context.messages.filter((msg, i, arr) => {
      if (i === 0) return true;
      const prev = arr[i - 1];
      return msg.content !== prev.content || msg.role !== prev.role;
    });

    return {
      ...context,
      messages: cleaned
    };
  }

  /**
   * Split large request into chunks
   */
  chunkRequest(request, maxChunkSize = 50000) {
    const text = typeof request === 'string' ? request : JSON.stringify(request);
    const chunks = [];

    if (text.length <= maxChunkSize) {
      return [request];
    }

    // Split by logical boundaries
    const lines = text.split('\\n');
    let currentChunk = '';
    let currentSize = 0;

    for (const line of lines) {
      const lineSize = line.length;

      if (currentSize + lineSize > maxChunkSize && currentChunk.length > 0) {
        chunks.push(currentChunk.trim());
        currentChunk = line;
        currentSize = lineSize;
      } else {
        currentChunk += (currentChunk ? '\\n' : '') + line;
        currentSize += lineSize;
      }
    }

    if (currentChunk.length > 0) {
      chunks.push(currentChunk.trim());
    }

    return chunks;
  }

  /**
   * Optimize system prompt
   */
  optimizeSystemPrompt(systemPrompt) {
    // Remove redundant instructions
    let optimized = systemPrompt
      .replace(/\\n{3,}/g, '\\n\\n') // Remove excessive newlines
      .replace(/ {2,}/g, ' ') // Remove excessive spaces
      .trim();

    // Truncate if still too large (max 2000 tokens for system)
    const maxSystemTokens = 8000;
    const currentTokens = this.estimateTokens(optimized);

    if (currentTokens > maxSystemTokens) {
      const ratio = maxSystemTokens / currentTokens;
      const maxLength = Math.floor(optimized.length * ratio);
      optimized = optimized.substring(0, maxLength) + '\\n... (truncated)';
    }

    return optimized;
  }

  /**
   * Main fix function - tries multiple strategies
   */
  async fixContextOverflow(context, options = {}) {
    const strategies = [
      () => this.removeRedundancy(context),
      () => this.compressMessages(context.messages, options),
      () => this.optimizeSystemPrompt(context.system || '')
    ];

    for (const strategy of strategies) {
      try {
        const result = strategy();
        const stats = this.analyze({ messages: result.messages || result });

        if (!stats.exceedsLimit) {
          return {
            success: true,
            strategy: strategy.name,
            result: result,
            stats: stats
          };
        }
      } catch (error) {
        if (this.debug) {
          console.error(`Strategy failed:`, error.message);
        }
      }
    }

    return {
      success: false,
      error: 'Could not compress context enough',
      suggestions: [
        'Use /new to start a fresh session',
        'Reduce the amount of context included',
        'Use a model with larger context window',
        'Break your request into smaller parts'
      ]
    };
  }
}

// CLI interface
if (require.main === module) {
  const args = process.argv.slice(2);
  const command = args[0];

  const manager = new ContextManager({ debug: true });

  if (command === 'analyze') {
    // Analyze context size
    const contextPath = args[1];
    if (!fs.existsSync(contextPath)) {
      console.error('Context file not found:', contextPath);
      process.exit(1);
    }

    const context = JSON.parse(fs.readFileSync(contextPath, 'utf8'));
    const stats = manager.analyze(context);

    console.log('📊 Context Analysis:');
    console.log(`  Messages: ${stats.totalMessages}`);
    console.log(`  Tokens: ${stats.totalTokens.toLocaleString()} / ${manager.maxTokens.toLocaleString()}`);
    console.log(`  System: ${stats.systemTokens} tokens`);
    console.log(`  Exceeds limit: ${stats.exceedsLimit ? '⚠️ YES' : '✅ NO'}`);
    console.log(`  Recommended: ${stats.recommendedAction}`);
  } else if (command === 'compress') {
    console.log('🔧 Compress context...');
    console.log('Usage: node context-manager.js compress <context.json>');
  } else {
    console.log(`
Context Manager - Fix "prompt too large" errors

Usage:
  node context-manager.js analyze <context.json>
  node context-manager.js compress <context.json>

Strategies:
  1. Remove redundant messages
  2. Summarize old messages
  3. Optimize system prompt
  4. Split large requests
    `);
  }
}

module.exports = ContextManager;
