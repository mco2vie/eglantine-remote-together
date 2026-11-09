(() => {
  const storageKey = 'eglantine-remote-together-language';
  const buttons = Array.from(document.querySelectorAll('[data-language]'));

  function setLanguage(language) {
    const selected = language === 'fr' ? 'fr' : 'en';
    document.body.classList.remove('language-en', 'language-fr');
    document.body.classList.add(`language-${selected}`);
    document.documentElement.lang = selected;
    buttons.forEach((button) => {
      button.setAttribute('aria-pressed', String(button.dataset.language === selected));
    });
    try {
      localStorage.setItem(storageKey, selected);
    } catch (_) {
      // A private browser window can block storage. The page still works.
    }
  }

  let savedLanguage = null;
  try {
    savedLanguage = localStorage.getItem(storageKey);
  } catch (_) {
    // Use the browser language below when storage is unavailable.
  }
  const browserLanguage = (navigator.language || '').toLowerCase();
  setLanguage(savedLanguage || (browserLanguage.startsWith('fr') ? 'fr' : 'en'));

  buttons.forEach((button) => {
    button.addEventListener('click', () => setLanguage(button.dataset.language));
  });
})();
