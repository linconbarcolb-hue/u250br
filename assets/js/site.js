(() => {
  const toggle = document.querySelector('.menu-toggle');
  const nav = document.querySelector('.site-nav');
  if (toggle && nav) {
    toggle.addEventListener('click', () => {
      const open = nav.classList.toggle('is-open');
      toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
      toggle.textContent = open ? 'FECHAR' : 'MENU';
    });
    nav.querySelectorAll('a').forEach(a => a.addEventListener('click', () => {
      nav.classList.remove('is-open');
      toggle.setAttribute('aria-expanded', 'false');
      toggle.textContent = 'MENU';
    }));
  }

  document.querySelectorAll('details.show').forEach(item => {
    item.addEventListener('toggle', () => {
      if (!item.open) return;
      document.querySelectorAll('details.show[open]').forEach(other => {
        if (other !== item) other.open = false;
      });
    });
  });

  // Album covers: keep the U250 SVG as a safe fallback.
  // When a local real cover exists in /assets/covers, it replaces the SVG automatically.
  document.querySelectorAll('.album-art img[data-cover]').forEach(img => {
    const cover = img.dataset.cover;
    if (!cover) return;
    const probe = new Image();
    probe.onload = () => {
      img.src = cover;
      img.classList.add('has-real-cover');
    };
    probe.src = cover;
  });

})();
