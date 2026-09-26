(function () {
  var lightbox = document.createElement('div');
  lightbox.className = 'image-lightbox';
  var big = document.createElement('img');
  lightbox.appendChild(big);
  document.body.appendChild(lightbox);

  document.addEventListener('click', function (event) {
    var img = event.target.closest && event.target.closest('google-codelab-step img');
    if (img) {
      big.src = img.src;
      big.alt = img.alt;
      lightbox.classList.add('open');
    } else if (event.target === lightbox || event.target === big) {
      lightbox.classList.remove('open');
    }
  });

  document.addEventListener('keydown', function (event) {
    if (event.key === 'Escape') lightbox.classList.remove('open');
  });

  // X e Done puntano a "/", che su GitHub Pages non esiste: rimandano al repository.
  var REPO = 'https://github.com/nicolaguglielmi/OII-Agentic-Trainer-Codelab';
  function fixExitLinks() {
    document.querySelectorAll('#arrow-back, #done').forEach(function (a) {
      if (a.getAttribute('href') !== REPO) a.setAttribute('href', REPO);
    });
  }
  new MutationObserver(fixExitLinks).observe(document.body, { childList: true, subtree: true });
  fixExitLinks();
})();
