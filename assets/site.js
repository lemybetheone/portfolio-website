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
  var still = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)');
  btn.addEventListener('click',function(){
    var next = current()==='dark' ? 'light' : 'dark';
    function apply(){
      // restart the icon animation even on rapid clicks
      icon.classList.remove('swap');
      void icon.offsetWidth;
      icon.classList.add('swap');

      root.setAttribute('data-theme', next);
      try{ localStorage.setItem('theme', next); }catch(e){}
      sync();
    }

    // Where the browser supports it, the new theme is revealed by a circle
    // growing from the button. The browser snapshots the page before and
    // after apply() and CSS animates between the two, so nothing in the DOM
    // is copied and images change with everything else.
    if(document.startViewTransition && !(still && still.matches)){
      var r=btn.getBoundingClientRect();
      var x=r.left+r.width/2, y=r.top+r.height/2;
      // radius to the farthest corner of the viewport, so the circle just
      // covers it
      var rad=Math.hypot(Math.max(x, innerWidth-x), Math.max(y, innerHeight-y));
      root.style.setProperty('--vt-x', x+'px');
      root.style.setProperty('--vt-y', y+'px');
      root.style.setProperty('--vt-r', rad+'px');
      document.startViewTransition(apply);
      return;
    }

    // otherwise fade the colours only for the duration of the change
    root.classList.add('theme-anim');
    clearTimeout(timer);
    timer=setTimeout(function(){ root.classList.remove('theme-anim'); }, 340);
    apply();
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

/* The sticky header's height is what every anchor has to clear, and it is not
   a constant: the nav wraps to its own line once the labels no longer fit, so
   the header is 56px, 96px or 109px depending on the width and on the labels.
   Publishing the measured height as a custom property keeps the CSS honest
   without a breakpoint that has to be corrected by hand. */
(function(){
  var header=document.querySelector('header');
  if(!header) return;
  function publish(){
    document.documentElement.style.setProperty('--header-h',header.offsetHeight+'px');
  }
  publish();
  /* Both, not one or the other. The published value is an inline custom
     property, so it outranks the stylesheet's fallback: correct while fresh,
     wrong the moment it is stale. resize covers rotation and window changes;
     ResizeObserver additionally catches the header changing height on its own,
     such as a font loading late and rewrapping the nav. */
  window.addEventListener('resize',publish);
  if(window.ResizeObserver){ new ResizeObserver(publish).observe(header); }
  /* a late webfont can rewrap the nav after this runs */
  if(document.fonts && document.fonts.ready){ document.fonts.ready.then(publish); }
})();
