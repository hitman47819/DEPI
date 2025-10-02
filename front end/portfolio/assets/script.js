
const themeBtn = document.getElementById('themeBtn');
function setLightIcon(){
  themeBtn.innerHTML = ` <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="w-5 h-5" aria-hidden="true"><circle cx="12" cy="12" r="4"></circle><path d="M12 2v2"></path><path d="M12 20v2"></path><path d="m4.93 4.93 1.41 1.41"></path><path d="m17.66 17.66 1.41 1.41"></path><path d="M2 12h2"></path><path d="M20 12h2"></path><path d="m6.34 17.66-1.41 1.41"></path><path d="m19.07 4.93-1.41 1.41"></path></svg>`;
}
function setDarkIcon(){
  themeBtn.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1111.21 3 7 7 0 0021 12.79z"></path></svg>`;
}

function isDark(){ return document.documentElement.classList.contains('dark'); }
if(window.matchMedia && window.matchMedia('(prefers-color-scheme:dark)').matches){ document.documentElement.classList.add('dark'); setDarkIcon(); } else { setLightIcon(); }

themeBtn.addEventListener('click', ()=>{
  document.documentElement.classList.toggle('dark');
  if(isDark()) setDarkIcon(); else setLightIcon();
});
(() => {
  const slides = document.querySelectorAll('.certificate-slide');
  const prevBtn = document.getElementById('prevCert');
  const nextBtn = document.getElementById('nextCert');
  let index = 0;

  function showSlide(i) {
    slides.forEach((s, n) => s.classList.toggle('active', n === i));
  }

  prevBtn.addEventListener('click', () => {
    index = (index - 1 + slides.length) % slides.length;
    showSlide(index);
  });

  nextBtn.addEventListener('click', () => {
    index = (index + 1) % slides.length;
    showSlide(index);
  });

  showSlide(index);
})();


const langs = ['C#','Java','Python','C++','C','SQL'];
const dotnet = ['ASP.NET Core MVC','ASP.NET Core Web APIs','Entity Framework','LINQ','Windows Forms'];
const tools = ['MySQL','SQL Server','Visual Studio','Git','GitHub'];
const Methodologies = ['Agile','Alogritm','Scrum','OOP','MVC Architecture','Project Management','Problem Solving'];
const others = ['Communication','Leadership','Teamwork'];

const Languages = [
  { name: 'Arabic',  level: 'Native' },
  { name: 'English', level: 'B2' },
  { name: 'German',  level: 'A2' },
  { name: 'Italian', level: 'A2' }
];

function makeChips(arr, containerId) {
  const c = document.getElementById(containerId);
  if (!c) return;
  arr.forEach((s, i) => {
    const el = document.createElement('span');
    el.className =
      'inline-block px-3 py-1 rounded-full text-sm font-medium ' +
      'bg-white/5 ring-1 ring-white/10';
    el.textContent = s;
    el.dataset.index = i;
    c.appendChild(el);
  });
}

function makeLanguageChips(arr, containerId) {
  const c = document.getElementById(containerId);
  if (!c) return;
  arr.forEach((lang, i) => {
    const wrapper = document.createElement('span');
    wrapper.className =
      'flex items-center gap-2 bg-white/5 ring-1 ring-white/10 ' +
      'rounded-md px-3 py-1 text-sm font-medium';

    const nameEl = document.createElement('span');
    nameEl.textContent = lang.name;

    const levelEl = document.createElement('span');
    levelEl.textContent = lang.level;
    levelEl.className =
      'px-2 py-0.5 rounded-full bg-blue-600/20 text-blue-300 text-xs font-semibold';

    wrapper.appendChild(nameEl);
    wrapper.appendChild(levelEl);
    c.appendChild(wrapper);
  });
}

document.addEventListener('DOMContentLoaded', () => {
  makeChips(langs, 'langs');
  makeChips(dotnet, 'dotnet');
  makeChips(tools, 'tools');
  makeChips(Methodologies, 'Methodologies');
  makeChips(others, 'others');
  makeLanguageChips(Languages, 'Languages');
});

const sections = document.querySelectorAll('main section');
const navLinks = document.querySelectorAll('.nav-link');

const observer = new IntersectionObserver((entries)=>{
  entries.forEach(entry=>{
    const id = entry.target.id;
    const link = document.querySelector(`a[href="#${id}"]`);
    if(entry.isIntersecting){
      navLinks.forEach(n=>n.classList.remove('active'));
      if(link) link.classList.add('active');
      entry.target.querySelectorAll('.fade-up').forEach((el,i)=>{
        setTimeout(()=>el.classList.add('in'), i*80);
      });
      entry.target.querySelectorAll('span').forEach((chip, idx)=>{
        chip.style.transition = `transform .5s cubic-bezier(.2,.9,.2,1) ${idx*50}ms, opacity .4s ${idx*50}ms`;
        chip.style.transform = 'translateY(0)'; chip.style.opacity=1;
      });
    } else {
      if(link) link.classList.remove('active');
      entry.target.querySelectorAll('.fade-up').forEach(el=>el.classList.remove('in'));
      entry.target.querySelectorAll('span').forEach(chip=>{ chip.style.transform='translateY(8px)'; chip.style.opacity=0; });
    }
  });
}, {threshold:0.45});
sections.forEach(s=>observer.observe(s));

document.querySelectorAll('a.nav-link, a[href^="#"]').forEach(a=>{
  a.addEventListener('click', (e)=>{
    const href = a.getAttribute('href');
    if(href && href.startsWith('#')){
      e.preventDefault(); const el = document.querySelector(href); if(el) el.scrollIntoView({behavior:'smooth', block:'start'});
    }
  });
});

document.querySelectorAll('main section').forEach((s,i)=>{ s.classList.add('fade-up'); setTimeout(()=>s.classList.add('in'), 220 + i*80); });

 
 

const photo = document.getElementById('photo'); if(photo) photo.loading = 'lazy';



const contactCard = document.getElementById('contactCard');
if(contactCard){
  const contactObserver = new IntersectionObserver((entries)=>{
    entries.forEach(e=>{
      if(e.isIntersecting){ contactCard.classList.add('in'); contactObserver.unobserve(contactCard); }
    });
  }, {threshold: 0.18});
  contactObserver.observe(contactCard);
}

const sendEmailBtn = document.getElementById('sendEmailBtn');
if(sendEmailBtn){
  sendEmailBtn.addEventListener('click', ()=>{
    window.location.href = 'mailto:mohamedabdelbaky365@gmail.com?subject=' + encodeURIComponent('Contact from portfolio');
  });
}

const downloadPdfBtn = document.getElementById('downloadPdfBtn');
if(downloadPdfBtn){
  downloadPdfBtn.addEventListener('click', ()=>{
    const link = document.createElement('a');
    link.href = 'assets/Mohamed_Ali.pdf';
    link.download = '';
    document.body.appendChild(link);
    link.click();
    link.remove();
  });
}


const storedTheme = localStorage.getItem('theme');
if(storedTheme === 'dark'){ document.documentElement.classList.add('dark'); setDarkIcon(); }
else if(storedTheme === 'light'){ document.documentElement.classList.remove('dark'); setLightIcon(); }

themeBtn.addEventListener('click', ()=>{
  document.documentElement.classList.toggle('dark');
  if(isDark()){ setDarkIcon(); localStorage.setItem('theme','dark'); } 
  else { setLightIcon(); localStorage.setItem('theme','light'); }
});



const animCards = document.querySelectorAll('.animate-card');
const animObserver = new IntersectionObserver((entries)=>{
  entries.forEach((ent, idx)=>{
    if(ent.isIntersecting){
      setTimeout(()=>ent.target.classList.add('in'), 60 * (idx+1));
      animObserver.unobserve(ent.target);
    }
  });
},{threshold: 0.18});
animCards.forEach(c=>animObserver.observe(c));

function applyTheme(theme){
  document.documentElement.classList.remove('dark','light');
  if(theme === 'dark') document.documentElement.classList.add('dark');
  else if(theme === 'light') document.documentElement.classList.add('light');
  // update icon
  if(document.documentElement.classList.contains('dark')) setDarkIcon(); else setLightIcon();
  localStorage.setItem('theme', theme);
}

const stored = localStorage.getItem('theme');
if(stored) applyTheme(stored);
else {
  if(window.matchMedia && window.matchMedia('(prefers-color-scheme:dark)').matches) applyTheme('dark');
  else applyTheme('light');
}

themeBtn.addEventListener('click', ()=>{
  const nowDark = document.documentElement.classList.contains('dark');
  applyTheme(nowDark? 'light' : 'dark');
});
