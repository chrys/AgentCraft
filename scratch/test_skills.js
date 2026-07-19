const fs = require('fs');
const path = require('path');

const SOURCES_FILE = path.join(__dirname, '../sources.txt');

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

function getSkills() {
  const sources = readSources();
  const allSkills = [];
  for (const src of sources) {
    const fullRepoPath = path.join(__dirname, '../repos', src.path);
    const fullSkillsDir = path.join(fullRepoPath, src.skillsPath);
    if (fs.existsSync(fullSkillsDir)) {
      try {
        const skillFiles = findSkillFiles(fullSkillsDir);
        for (const skillFile of skillFiles) {
          const skillContent = fs.readFileSync(skillFile, 'utf8');
          const skillDir = path.dirname(skillFile);
          const slug = path.basename(skillDir);
          
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
  return allSkills;
}

const skills = getSkills();
const slugCounts = {};
skills.forEach(s => {
  slugCounts[s.slug] = (slugCounts[s.slug] || 0) + 1;
});

const duplicates = Object.entries(slugCounts).filter(([slug, count]) => count > 1);
console.log('Duplicate slugs:', duplicates);

