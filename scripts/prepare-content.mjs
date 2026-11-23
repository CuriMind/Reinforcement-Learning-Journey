#!/usr/bin/env node
/**
 * scripts/prepare-content.mjs
 * 把仓库根的 README.md 与 docs/*.md
 * 拷贝到 site/content/ 并注入 Hugo 需要的 front matter。
 * 原则：只读源文件，绝不修改；所有加工都发生在 site/content/ 的副本上。
 * 用法：node scripts/prepare-content.mjs [--check] [--with-appendix]
 */
import { readFileSync, writeFileSync, mkdirSync, rmSync, readdirSync, existsSync, statSync } from 'node:fs';
import { join, dirname, basename } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const SRC_DOCS = join(ROOT, 'docs');
const OUT = join(ROOT, 'site', 'content');
const CHECK_ONLY = process.argv.includes('--check');

const yamlStr = (s) => JSON.stringify(String(s).trim());

function firstHeadingIndex(lines, re) {
  for (let i = 0; i < lines.length; i++) {
    if (re.test(lines[i])) return i;
    if (lines[i].trim() === '' || lines[i].startsWith('<!--')) continue;
    return -1;
  }
  return -1;
}

function frontMatter(fields) {
  const body = Object.entries(fields)
    .filter(([, v]) => v !== undefined && v !== null && v !== '')
    .map(([k, v]) => `${k}: ${typeof v === 'number' ? v : yamlStr(v)}`)
    .join('\n');
  return `---\n${body}\n---\n\n`;
}

function outsideFences(md, fn) {
  const lines = md.split(/\r?\n/);
  let inFence = false;
  return lines.map((ln) => {
    if (/^\s*(```|~~~)/.test(ln)) { inFence = !inFence; return ln; }
    return inFence ? ln : fn(ln);
  }).join('\n');
}
/**
 * 删除 $$ ... $$ 块内部的空行。
 * 为什么需要：Hugo/Goldmark 会把块内空行当成段落分隔，`$$` 被拆进两个 <p>，
 * KaTeX 就认不出这是块级公式（表现为一段公式显示成原文）。
 * 这一步只作用于副本，源 md 不受影响。
 */
function normalizeMath(md) {
  const src = md.split(/\r?\n/);
  const out = [];
  let i = 0;
  while (i < src.length) {
    if (/^\$\$\s*$/.test(src[i])) {
      let j = i + 1;
      while (j < src.length && !/^\$\$\s*$/.test(src[j])) j++;
      if (j >= src.length) { out.push(src[i]); i++; continue; }
      out.push(src[i]);
      for (let k = i + 1; k < j; k++) {
        if (src[k].trim() !== '') out.push(src[k]);
      }
      out.push(src[j]);
      i = j + 1;
    } else { out.push(src[i]); i++; }
  }
  return out.join('\n');
}

if (!existsSync(SRC_DOCS)) { console.error('找不到源目录：' + SRC_DOCS); process.exit(1); }
const chapterFiles = readdirSync(SRC_DOCS).filter((f) => f.endsWith('.md')).sort();

const chapterIndex = new Map();
for (const file of chapterFiles) {
  const lines = readFileSync(join(SRC_DOCS, file), 'utf8').split(/\r?\n/);
  const h = firstHeadingIndex(lines, /^##\s+\S/);
  const num = Number((file.match(/^(\d+)/) || [0, -1])[1]);
  const title = h >= 0 ? lines[h].replace(/^##\s+/, '').trim() : basename(file, '.md');
  chapterIndex.set(num, { slug: basename(file, '.md'), title, file });
}

if (CHECK_ONLY) {
  console.log('[check] ' + chapterFiles.length + ' 章');
  process.exit(0);
}

rmSync(OUT, { recursive: true, force: true });
mkdirSync(join(OUT, 'docs'), { recursive: true });

function linkifyReadme(md) {
  return outsideFences(md, (ln) => {
    let s = ln;
    // 两份附录默认不发布：把指向它们的链接降级为纯文本，避免死链
    s = s.replace(/\[([^\]]+)\]\(_EXPERIMENTS\.md\)/g, (m, text) => text);
    s = s.replace(/\[([^\]]+)\]\(_STYLE-GUIDE\.md\)/g, (m, text) => text);
    s = s.replace(/^\|\s*(\d{1,2})\s*\|\s*([^|]+?)\s*\|/, (m, n, cell) => {
      const ch = chapterIndex.get(Number(n));
      if (!ch) return m;
      if (/^\*\*/.test(cell.trim())) return m;
      return '| [' + n + '](docs/' + ch.slug + '/) | ' + cell + ' |';
    });
    s = s.replace(/`([0-9]{2}-[a-z0-9-]+)\.md`/g, (m, slug) => {
      const found = [...chapterIndex.values()].some((c) => c.slug === slug);
      return found ? '[`' + slug + '.md`](docs/' + slug + '/)' : m;
    });
    return s;
  });
}

{
  const lines = readFileSync(join(ROOT, 'README.md'), 'utf8').split(/\r?\n/);
  let start = 0;
  if (lines[0] && /^(中文|English)/i.test(lines[0].trim())) start = 1;
  const body = lines.slice(start);
  const h = firstHeadingIndex(body, /^#\s+\S/);
  const title = h >= 0 ? body[h].replace(/^#\s+/, '').trim() : '总目录';
  const rest = h >= 0 ? [...body.slice(0, h), ...body.slice(h + 1)] : body;
  writeFileSync(
    join(OUT, '_index.md'),
    frontMatter({ title, description: '从贝尔曼方程到 Agentic RL 的 34 章教材' }) +
      normalizeMath(linkifyReadme(rest.join('\n').replace(/^\s*\n/, ''))),
    'utf8'
  );
  console.log('  OK 首页  <- README.md  「' + title + '」');
}

writeFileSync(
  join(OUT, 'docs', '_index.md'),
  frontMatter({ title: '正文（34 章）', weight: 1 }) + '按顺序读，或从左侧目录跳转。',
  'utf8'
);

for (const [num, ch] of chapterIndex) {
  const lines = readFileSync(join(SRC_DOCS, ch.file), 'utf8').split(/\r?\n/);
  const h = firstHeadingIndex(lines, /^##\s+\S/);
  const rest = h >= 0 ? [...lines.slice(0, h), ...lines.slice(h + 1)] : lines;
  writeFileSync(
    join(OUT, 'docs', ch.file),
    frontMatter({ title: ch.title, weight: num + 1 }) + normalizeMath(rest.join('\n').replace(/^\s*\n/, '')),
    'utf8'
  );
}
console.log('  OK 正文  <- docs/*.md  ' + chapterIndex.size + ' 章');

const WITH_APPENDIX = process.argv.includes('--with-appendix');
const appendices = WITH_APPENDIX ? [
  { src: '_EXPERIMENTS.md', dst: 'experiments.md', weight: 100, fallback: '四个诊断实验' },
  { src: '_STYLE-GUIDE.md', dst: 'style-guide.md', weight: 200, fallback: '写作规范与纪律' },
] : [];
if (!WITH_APPENDIX) console.log('  -- 附录未发布（如需发布：node scripts/prepare-content.mjs --with-appendix）');
for (const a of appendices) {
  const p = join(ROOT, a.src);
  if (!existsSync(p)) { console.warn('  SKIP（不存在）：' + a.src); continue; }
  const lines = readFileSync(p, 'utf8').split(/\r?\n/);
  const h = firstHeadingIndex(lines, /^#\s+\S/);
  const title = h >= 0 ? lines[h].replace(/^#\s+/, '').trim() : a.fallback;
  const rest = h >= 0 ? [...lines.slice(0, h), ...lines.slice(h + 1)] : lines;
  const body = outsideFences(rest.join('\n'), (ln) =>
    ln.replace(/\]\(_EXPERIMENTS\.md\)/g, '](experiments/)')
      .replace(/\]\(_STYLE-GUIDE\.md\)/g, '](style-guide/)')
  ).replace(/^\s*\n/, '');
  writeFileSync(join(OUT, a.dst), frontMatter({ title, weight: a.weight }) + normalizeMath(body), 'utf8');
  console.log('  OK 附录  <- ' + a.src + '  「' + title + '」');
}

let count = 0;
(function walk(d) {
  for (const e of readdirSync(d)) {
    const p = join(d, e);
    statSync(p).isDirectory() ? walk(p) : count++;
  }
})(OUT);
console.log('\n完成：site/content/ 共 ' + count + ' 个页面（源 md 未做任何修改）');
