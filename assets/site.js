/* Shared behaviour for every page: theme toggle and copy-to-clipboard.
   Loaded with defer, and each block returns early when its element is
   absent, so the same file is safe on a page that has only one of them.
   The pre-paint theme script stays inline in each page's <head>. */

(function(){
  var root=document.documentElement;
  var btn=document.getElementById('theme-toggle');
  var icon=document.getElementById('theme-icon');
  if(!btn||!icon)return;
  var timer;
  function current(){
    return root.getAttribute('data-theme') ||
      (window.matchMedia && window.matchMedia('(prefers-color-scheme: light)').matches ? 'light' : 'dark');
  }
  function sync(){
    var c=current();
    icon.textContent = c==='dark' ? '☀' : '☾';
    btn.setAttribute('aria-label', c==='dark' ? 'Switch to light theme' : 'Switch to dark theme');
  }
  btn.addEventListener('click',function(){
    var next = current()==='dark' ? 'light' : 'dark';

    // fade the colours only for the duration of the change
    root.classList.add('theme-anim');
    clearTimeout(timer);
    timer=setTimeout(function(){ root.classList.remove('theme-anim'); }, 340);

    // restart the icon animation even on rapid clicks
    icon.classList.remove('swap');
    void icon.offsetWidth;
    icon.classList.add('swap');

    root.setAttribute('data-theme', next);
    try{ localStorage.setItem('theme', next); }catch(e){}
    sync();
  });
  icon.addEventListener('animationend',function(){ icon.classList.remove('swap'); });
  sync();
})();

(function(){
  var link=document.getElementById('email-action');
  var status=document.getElementById('copy-status');
  if(!link)return;
  var label=link.querySelector('.btn-label');
  var original=label.textContent, timer;
  function say(msg){ if(status) status.textContent=msg; }
  function done(ok,email){
    if(ok){ label.textContent='copied'; link.classList.add('done'); }
    say(ok ? 'Email address copied: '+email
           : 'Could not copy. The address is '+email);
    clearTimeout(timer);
    timer=setTimeout(function(){
      label.textContent=original; link.classList.remove('done'); say('');
    }, 2400);
  }
  // the mailto is NOT cancelled: the click still opens a mail client when one
  // exists, and the copy is the fallback for the machines where it does not.
  link.addEventListener('click',function(){
    var email=link.getAttribute('data-email');
    if(navigator.clipboard && navigator.clipboard.writeText){
      navigator.clipboard.writeText(email).then(function(){ done(true,email); },
                                               function(){ legacy(email); });
    } else { legacy(email); }
  });
  function legacy(email){
    try{
      var ta=document.createElement('textarea');
      ta.value=email; ta.setAttribute('readonly','');
      ta.style.position='absolute'; ta.style.left='-9999px';
      document.body.appendChild(ta); ta.select();
      var ok=document.execCommand('copy');
      document.body.removeChild(ta);
      done(ok,email);
    }catch(e){ done(false,email); }
  }
})();
