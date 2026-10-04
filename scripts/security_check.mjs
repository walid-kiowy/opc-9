// Garde-fou pédagogique limité : ne remplace pas SAST, SCA ni Gitleaks.
import fs from 'node:fs';
import path from 'node:path';
const patterns = [/-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----/, /(?:AKIA|ASIA)[A-Z0-9]{16}/];
let failures=0;
function walk(dir) {
 for (const item of fs.readdirSync(dir,{withFileTypes:true})) {
  if (['.git','node_modules','dist'].includes(item.name)) continue;
  const p=path.join(dir,item.name);
  if (item.isDirectory()) walk(p);
  else if (/\.(mjs|json|yml|yaml|sh|md)$/.test(p) && !p.endsWith('security_check.mjs')) {
   const content=fs.readFileSync(p,'utf8');
   if (patterns.some(re=>re.test(content))) { console.error('Secret potentiel dans',p); failures++; }
  }
 }
}
walk('.');
if (failures) process.exit(1);
console.log('Garde-fou réussi ; audit de sécurité complet requis avant production.');
