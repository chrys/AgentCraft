const express = require('express');
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.static('public'));
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

const SOURCES_FILE = path.join(__dirname, 'sources.txt');

// Safe query parameter reader
function getQueryParam(param) {
  if (typeof param === 'string') {
    return param.trim();
  }
  if (Array.isArray(param) && param.length > 0) {
    return typeof param[0] === 'string' ? param[0].trim() : '';
  }
  return '';
}

// Helper to read sources.txt
function readSources() {
  if (!fs.existsSync(SOURCES_FILE)) {
    return [];
  }
  const content = fs.readFileSync(SOURCES_FILE, 'utf8');
  const lines = content.split('\n');
  const sources = [];
  for (let line of lines) {
    line = line.trim();
    if (!line || line.startsWith('#')) {
      continue;
    }
    const parts = line.split('|').map(p => p.trim());
    if (parts.length >= 5) {
      sources.push({
        name: parts[0],
        path: parts[1],
        url: parts[2],
        branch: parts[3],
        skillsPath: parts[4]
      });
    }
  }
  return sources;
}

// Helper to write sources.txt
function writeSources(sources) {
  let content = `# Configuration file for Agent Skills Source Repositories\n`;
  content += `# Format: name | path | url | branch | skills_relative_path\n`;
  content += `# Lines starting with # are comments. Empty lines are ignored.\n\n`;
  for (const src of sources) {
    content += `${src.name} | ${src.path} | ${src.url} | ${src.branch} | ${src.skillsPath}\n`;
  }
  fs.writeFileSync(SOURCES_FILE, content, 'utf8');
}

// Helper to read sync-state.txt
const STATE_FILE = path.join(__dirname, 'sync-state.txt');
function readSyncStates() {
  const states = {};
  if (fs.existsSync(STATE_FILE)) {
    try {
      const content = fs.readFileSync(STATE_FILE, 'utf8');
      const lines = content.split('\n');
      for (let line of lines) {
        let trimmed = line.trim();
        if (trimmed) {
          const parts = trimmed.split(':');
          if (parts.length >= 2) {
            const key = parts[0].trim();
            const val = parts.slice(1).join(':').trim();
            states[key] = val;
          }
        }
      }
    } catch (err) {
      console.error(`Error reading sync states:`, err.message);
    }
  }
  return states;
}

// Helper to recursively find SKILL.md files
function findSkillFiles(dir) {
  let results = [];
  if (!fs.existsSync(dir)) return results;
  try {
    const list = fs.readdirSync(dir);
    for (const file of list) {
      const filePath = path.join(dir, file);
      const stat = fs.statSync(filePath);
      if (stat && stat.isDirectory()) {
        results = results.concat(findSkillFiles(filePath));
      } else if (file === 'SKILL.md') {
        results.push(filePath);
      }
    }
  } catch (err) {
    console.error(`Error scanning directory ${dir}:`, err.message);
  }
  return results;
}

// Helper to get all skills across all sources
function getSkills() {
  const sources = readSources();
  const allSkills = [];
  for (const src of sources) {
    const fullRepoPath = path.join(__dirname, 'repos', src.path);
    const fullSkillsDir = path.join(fullRepoPath, src.skillsPath);
    if (fs.existsSync(fullSkillsDir)) {
      try {
        const skillFiles = findSkillFiles(fullSkillsDir);
        for (const skillFile of skillFiles) {
          const skillContent = fs.readFileSync(skillFile, 'utf8');
          const skillDir = path.dirname(skillFile);
          const slug = path.basename(skillDir);
          
          // Extract name and description from frontmatter
          const nameMatch = skillContent.match(/^name:\s*(.+)$/m);
          const descMatch = skillContent.match(/^description:\s*(.+)$/m);
          const name = nameMatch ? nameMatch[1].trim() : slug;
          const description = descMatch ? descMatch[1].trim() : '*No description available*';
          
          allSkills.push({
            repo: src.name,
            slug,
            name,
            description
          });
        }
      } catch (err) {
        console.error(`Error reading skills from ${fullSkillsDir}:`, err.message);
      }
    }
  }
  // Sort alphabetically by slug
  allSkills.sort((a, b) => a.slug.localeCompare(b.slug, undefined, { sensitivity: 'base' }));
  return allSkills;
}

// Render source list HTML rows
function renderSourcesHtml(sources) {
  if (sources.length === 0) {
    return '<tr><td colspan="7" class="text-center">No repositories configured. Add one below.</td></tr>';
  }
  const syncStates = readSyncStates();
  return sources.map(src => {
    const lastSynced = syncStates[src.name] || 'Never';
    return `
      <tr>
        <td><span class="repo-badge">${src.name}</span></td>
        <td><code>${src.path}</code></td>
        <td><a href="${src.url}" target="_blank" class="repo-url-link">${src.url}</a></td>
        <td><code>${src.branch}</code></td>
        <td><code>${src.skillsPath}</code></td>
        <td><span class="sync-timestamp">⏱️ ${lastSynced}</span></td>
        <td>
          <button class="btn btn-danger btn-sm" 
                  hx-delete="/api/sources?name=${encodeURIComponent(src.name)}" 
                  hx-target="#sources-list-body"
                  hx-confirm="Are you sure you want to delete '${src.name}'?">
            Delete
          </button>
        </td>
      </tr>
    `;
  }).join('');
}

// Helper to render compact skills grid
function renderSkillsGrid(skillsList, isExisting, targetPath, tool) {
  if (skillsList.length === 0) {
    return `<div class="no-skills-msg py-4 text-center"><p>${isExisting ? 'No skills currently installed in this project directory.' : 'No new skills available in repositories.'}</p></div>`;
  }
  
  // Group skills by repo
  const grouped = {};
  skillsList.forEach(s => {
    if (!grouped[s.repo]) {
      grouped[s.repo] = [];
    }
    grouped[s.repo].push(s);
  });

  let html = '';
  for (const repo in grouped) {
    html += `
      <div class="skills-group">
        <h4 class="skills-group-title-sub">Repository: <span class="accent-text">${repo}</span></h4>
        <div class="skills-grid-compact">
    `;
    grouped[repo].forEach(s => {
      let locationHtml = '';
      if (isExisting && targetPath) {
        const resolvedPath = path.isAbsolute(targetPath) ? targetPath : path.resolve(__dirname, targetPath);
        let dest = '';
        if (tool === 'github-copilot') {
          dest = path.join(resolvedPath, '.github', 'skills', s.slug, 'SKILL.md');
        } else if (tool === 'antigravity-ide') {
          dest = path.join(resolvedPath, '.agents', 'skills', s.slug, 'SKILL.md');
        } else {
          dest = path.join(resolvedPath, 'skills', s.slug, 'SKILL.md');
        }
        locationHtml = `<p class="skill-location-compact">📍 <code>${dest}</code></p>`;
      }

      html += `
        <div class="skill-card-container-compact">
          <label class="skill-card-label-compact" style="flex: 1;">
            <input type="checkbox" name="skills" value="${s.slug}" class="skill-checkbox">
            <div class="skill-card-compact">
              <div class="skill-card-header-compact">
                <span class="skill-name-compact">${s.name}</span>
                ${isExisting ? '<span class="status-badge-installed">Installed</span>' : ''}
              </div>
              <span class="skill-slug-compact"><code>${s.slug}</code> <span style="opacity: 0.3; margin: 0 0.4rem;">•</span> <span class="repo-badge-compact">Source: ${s.repo}</span></span>
              <p class="skill-desc-compact">${s.description}</p>
              ${locationHtml}
            </div>
          </label>
          ${isExisting ? `
            <button type="button" class="btn btn-danger btn-sm btn-remove-skill"
                    hx-delete="/api/skills?targetPath=${encodeURIComponent(targetPath)}&tool=${encodeURIComponent(tool)}&slug=${encodeURIComponent(s.slug)}"
                    hx-target="#skills-card-container"
                    hx-confirm="Are you sure you want to remove '${s.name}' from the target project?">
              Remove
            </button>
          ` : ''}
        </div>
      `;
    });
    html += `
        </div>
      </div>
    `;
  }
  return html;
}

// ----------------------------------------------------
// API Routes
// ----------------------------------------------------

// Get list of sources
app.get('/api/sources', (req, res) => {
  const sources = readSources();
  res.send(renderSourcesHtml(sources));
});

// Add a source
app.post('/api/sources', (req, res) => {
  const { name, path: rpath, url, branch, skillsPath } = req.body;
  if (!name || !rpath || !url || !branch || !skillsPath) {
    return res.status(400).send('All fields are required.');
  }

  const sources = readSources();
  if (sources.some(src => src.name.toLowerCase() === name.trim().toLowerCase())) {
    return res.status(400).send('A repository with this name already exists.');
  }

  sources.push({
    name: name.trim(),
    path: rpath.trim(),
    url: url.trim(),
    branch: branch.trim(),
    skillsPath: skillsPath.trim()
  });

  writeSources(sources);
  res.send(renderSourcesHtml(sources));
});

// Delete a source
app.delete('/api/sources', (req, res) => {
  const name = req.query.name;
  if (!name) {
    return res.status(400).send('Name parameter required.');
  }

  let sources = readSources();
  sources = sources.filter(src => src.name !== name);
  writeSources(sources);
  res.send(renderSourcesHtml(sources));
});

// Helper to render full skills card HTML (header, sub-tabs, lists, and footer)
function renderSkillsCardHtml(targetPath, tool) {
  const allSkills = getSkills();
  const existingSkills = [];
  const availableSkills = [];

  const resolvedPath = path.isAbsolute(targetPath) ? targetPath : path.resolve(__dirname, targetPath);

  for (const skill of allSkills) {
    let isInstalled = false;
    let dest = '';
    if (tool === 'github-copilot') {
      dest = path.join(resolvedPath, '.github', 'skills', skill.slug, 'SKILL.md');
    } else if (tool === 'antigravity-ide') {
      dest = path.join(resolvedPath, '.agents', 'skills', skill.slug, 'SKILL.md');
    } else {
      dest = path.join(resolvedPath, 'skills', skill.slug, 'SKILL.md');
    }
    if (fs.existsSync(dest)) {
      isInstalled = true;
    }

    if (isInstalled) {
      existingSkills.push(skill);
    } else {
      availableSkills.push(skill);
    }
  }

  return `
    <div class="card-header flex-between">
      <div>
        <h2>2. Skills</h2>
        <p>Select skills to apply to your project.</p>
      </div>
      <div class="selection-actions">
        <button type="button" class="btn btn-sm btn-outline" onclick="selectAllSkills(true)">Select All</button>
        <button type="button" class="btn btn-sm btn-outline" onclick="selectAllSkills(false)">Clear All</button>
      </div>
    </div>

    <!-- Sub-tabs for Existing vs Available -->
    <div class="subtabs-nav">
      <button type="button" class="subtab-btn active" id="btn-subtab-existing" onclick="switchSubTab('existing')">
        Existing Skills (${existingSkills.length})
      </button>
      <button type="button" class="subtab-btn" id="btn-subtab-available" onclick="switchSubTab('available')">
        Available Skills (${availableSkills.length})
      </button>
    </div>

    <div class="scrollable-skills-list">
      <!-- Tab content: Existing Skills -->
      <div id="subtab-existing" class="subtab-panel active">
        ${renderSkillsGrid(existingSkills, true, targetPath, tool)}
      </div>
      
      <!-- Tab content: Available Skills -->
      <div id="subtab-available" class="subtab-panel">
        ${renderSkillsGrid(availableSkills, false, targetPath, tool)}
      </div>
    </div>

    <div class="card-footer">
      <button type="submit" class="btn btn-primary btn-lg">
        <span class="btn-icon">🚀</span> Apply Selected Skills
      </button>
    </div>
  `;
}

// Get consolidated skills checklist with sub-tabs
app.get('/api/skills', (req, res) => {
  const targetPath = getQueryParam(req.query.targetPath);
  const tool = getQueryParam(req.query.tool) || 'github-copilot';

  if (!targetPath) {
    return res.send(`
      <div class="card-header">
        <h2>2. Skills</h2>
        <p>Please enter a target path and click Discover Skills to load the list.</p>
      </div>
      <div class="skills-placeholder-body text-center py-4">
        <span style="font-size: 3rem; opacity: 0.5;">🔍</span>
        <p style="margin-top: 1rem; color: var(--text-secondary);">Enter a project path and click "Discover Skills" to query installed and available skills.</p>
      </div>
    `);
  }

  res.send(renderSkillsCardHtml(targetPath, tool));
});

// Delete (remove) a skill from the target project
app.delete('/api/skills', (req, res) => {
  const targetPath = getQueryParam(req.query.targetPath);
  const tool = getQueryParam(req.query.tool) || 'github-copilot';
  const slug = getQueryParam(req.query.slug);

  if (!targetPath || !slug) {
    return res.status(400).send('Target path and skill slug are required.');
  }

  const resolvedPath = path.isAbsolute(targetPath) ? targetPath : path.resolve(__dirname, targetPath);

  let destFolder = '';
  if (tool === 'github-copilot') {
    destFolder = path.join(resolvedPath, '.github', 'skills', slug);
  } else if (tool === 'antigravity-ide') {
    destFolder = path.join(resolvedPath, '.agents', 'skills', slug);
  } else {
    destFolder = path.join(resolvedPath, 'skills', slug);
  }

  try {
    if (fs.existsSync(destFolder)) {
      fs.rmSync(destFolder, { recursive: true, force: true });
    }
    res.send(renderSkillsCardHtml(targetPath, tool));
  } catch (err) {
    console.error(`Error deleting skill ${slug}:`, err.message);
    res.status(500).send(`Failed to delete skill: ${err.message}`);
  }
});

// Run Sync Repositories (get-updates.sh)
app.post('/api/sync', (req, res) => {
  res.setHeader('Content-Type', 'text/html');
  exec('bash scripts/get-updates.sh', (error, stdout, stderr) => {
    const logs = stdout + stderr;
    const cleanLogs = logs.replace(/\x1B\[[0-9;]*[a-zA-Z]/g, ''); // strip ansi escape colors if any
    
    if (error) {
      res.send(`
        <div class="console-status status-error">
          <span class="status-icon">⚠️</span>
          <span class="status-msg">Synchronization failed with exit code ${error.code}</span>
        </div>
        <pre class="console-body">${cleanLogs}</pre>
      `);
    } else {
      res.send(`
        <div class="console-status status-success">
          <span class="status-icon">✅</span>
          <span class="status-msg">Repositories synchronized successfully!</span>
        </div>
        <pre class="console-body">${cleanLogs}</pre>
      `);
    }
  });
});

// Run Provisioning (createagents.sh)
app.post('/api/provision', (req, res) => {
  const { targetPath, tool, skills } = req.body;
  
  if (!targetPath) {
    return res.send(`
      <div class="console-status status-error">
        <span class="status-icon">⚠️</span>
        <span class="status-msg">Error: Target path is required.</span>
      </div>
      <pre class="console-body">Please enter a valid directory path.</pre>
    `);
  }

  if (!tool) {
    return res.send(`
      <div class="console-status status-error">
        <span class="status-icon">⚠️</span>
        <span class="status-msg">Error: Tool type is required.</span>
      </div>
      <pre class="console-body">Please select a tool style (GitHub Copilot, OpenCode, or Antigravity IDE).</pre>
    `);
  }

  let skillsArg = '';
  if (Array.isArray(skills)) {
    skillsArg = skills.join(' ');
  } else if (skills) {
    skillsArg = skills;
  }

  let cmd = `bash scripts/createagents.sh "${targetPath.trim()}" --tool "${tool}"`;
  if (skillsArg) {
    cmd += ` --skills "${skillsArg}"`;
  }

  res.setHeader('Content-Type', 'text/html');
  exec(cmd, (error, stdout, stderr) => {
    const logs = stdout + stderr;
    const cleanLogs = logs.replace(/\x1B\[[0-9;]*[a-zA-Z]/g, '');

    if (error) {
      res.send(`
        <div class="console-status status-error">
          <span class="status-icon">⚠️</span>
          <span class="status-msg">Provisioning failed with exit code ${error.code}</span>
        </div>
        <pre class="console-body">${cleanLogs}</pre>
      `);
    } else {
      res.send(`
        <div class="console-status status-success">
          <span class="status-icon">✅</span>
          <span class="status-msg">Skills provisioned successfully!</span>
        </div>
        <pre class="console-body">${cleanLogs}</pre>
      `);
    }
  });
});

// Start Server
app.listen(PORT, () => {
  console.log(`AgentCraft Dashboard running on http://localhost:${PORT}`);
});
