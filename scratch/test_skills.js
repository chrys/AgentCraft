function diffLines(lines1, lines2) {
  const n = lines1.length;
  const m = lines2.length;
  const dp = Array.from({ length: n + 1 }, () => Array(m + 1).fill(0));
  
  for (let i = 1; i <= n; i++) {
    for (let j = 1; j <= m; j++) {
      if (lines1[i - 1] === lines2[j - 1]) {
        dp[i][j] = dp[i - 1][j - 1] + 1;
      } else {
        dp[i][j] = Math.max(dp[i - 1][j], dp[i][j - 1]);
      }
    }
  }
  
  let i = n, j = m;
  const diff = [];
  while (i > 0 || j > 0) {
    if (i > 0 && j > 0 && lines1[i - 1] === lines2[j - 1]) {
      diff.unshift({ type: 'unchanged', text: lines1[i - 1] });
      i--;
      j--;
    } else if (j > 0 && (i === 0 || dp[i][j - 1] >= dp[i - 1][j])) {
      diff.unshift({ type: 'addition', text: lines2[j - 1] });
      j--;
    } else {
      diff.unshift({ type: 'deletion', text: lines1[i - 1] });
      i--;
    }
  }
  return diff;
}

function getDiffText(content1, content2) {
  const lines1 = content1.replace(/\r/g, '').split('\n');
  const lines2 = content2.replace(/\r/g, '').split('\n');
  const diff = diffLines(lines1, lines2);
  
  let result = '';
  const context = 3;
  
  for (let k = 0; k < diff.length; k++) {
    const item = diff[k];
    if (item.type !== 'unchanged') {
      for (let offset = -context; offset <= context; offset++) {
        if (k + offset >= 0 && k + offset < diff.length) {
          diff[k + offset].needed = true;
        }
      }
    }
  }
  
  let inHunk = false;
  for (let k = 0; k < diff.length; k++) {
    const item = diff[k];
    if (item.needed) {
      if (!inHunk) {
        result += `@@ -... +... @@\n`;
        inHunk = true;
      }
      if (item.type === 'addition') {
        result += `+ ${item.text}\n`;
      } else if (item.type === 'deletion') {
        result += `- ${item.text}\n`;
      } else {
        result += `  ${item.text}\n`;
      }
    } else {
      inHunk = false;
    }
  }
  return result;
}

// Test cases
const str1 = 'hello\nmy\nname\nis\njohn\nand\ni\nlike\ncoding';
const str2 = 'hello\nname\nwas\nis\njohn\nand\ni\nlove\ncoding\nvery much';

console.log(getDiffText(str1, str2));


