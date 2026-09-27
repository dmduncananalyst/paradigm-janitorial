(() => {
  'use strict';
  const nav = document.querySelector('.main-nav');
  const menu = document.querySelector('.menu-button');
  const compact = window.matchMedia('(max-width: 1280px)');
  const closeGroups = () => document.querySelectorAll('.nav-group').forEach(group => {
    group.classList.remove('expanded');
    group.querySelector(':scope > a').setAttribute('aria-expanded', 'false');
  });
  const closeMenu = () => {
    nav?.classList.remove('open');
    menu?.setAttribute('aria-expanded', 'false');
    menu?.setAttribute('aria-label', 'Open menu');
    closeGroups();
  };
  menu?.addEventListener('click', () => {
    const open = nav.classList.toggle('open');
    menu.setAttribute('aria-expanded', String(open));
    menu.setAttribute('aria-label', open ? 'Close menu' : 'Open menu');
    if (!open) closeGroups();
  });
  // Preload dropdown photography so the first hover does not flash alt text before images decode.
  document.querySelectorAll('.nav-panel img').forEach(img => {
    img.loading = 'eager';
    if (img.src) { const preload = new Image(); preload.src = img.src; }
  });

  document.querySelectorAll('.nav-group').forEach(group => {
    const link = group.querySelector(':scope > a');
    const setOpen = open => {
      group.classList.toggle('expanded', open);
      link.setAttribute('aria-expanded', String(open));
    };
    group.addEventListener('pointerenter', event => {
      if (!compact.matches && event.pointerType !== 'touch') { closeGroups(); setOpen(true); }
    });
    group.addEventListener('pointerleave', () => {
      if (!compact.matches && !group.contains(document.activeElement)) setOpen(false);
    });
    group.addEventListener('focusin', () => { if (!compact.matches) setOpen(true); });
    group.addEventListener('focusout', event => {
      if (!group.contains(event.relatedTarget)) setOpen(false);
    });
    // On touch screens the first tap reveals the menu; a second tap follows the overview link.
    link.addEventListener('click', event => {
      if ((compact.matches || window.matchMedia('(hover: none)').matches) && !group.classList.contains('expanded')) {
        event.preventDefault();
        closeGroups();
        // On mobile, collapsing the previously-open section can leave the nav's
        // scrollTop stranded halfway down the menu. Reset the menu BEFORE opening
        // the new section so Home, About, Residential and Commercial stay visible
        // and the Commercial label has the same breathing room as Residential.
        if (compact.matches && nav) nav.scrollTop = 0;
        setOpen(true);
        if (compact.matches && nav) requestAnimationFrame(() => { nav.scrollTop = 0; });
      }
    });
    group.addEventListener('keydown', event => {
      if (event.key === 'ArrowDown' && event.target === link) {
        event.preventDefault(); closeGroups(); setOpen(true);
        group.querySelector('.nav-panel a')?.focus();
      }
      if (event.key === 'Escape') {
        event.preventDefault(); event.stopPropagation();
        link.focus(); setOpen(false);
      }
    });
  });
  document.addEventListener('pointerdown', event => {
    if (!event.target.closest('.site-header')) closeMenu();
  });
  document.addEventListener('keydown', event => {
    if (event.key === 'Escape' && !document.body.classList.contains('chat-open')) {
      closeMenu();
      if (compact.matches) menu?.focus();
    }
  });
  compact.addEventListener('change', closeMenu);

  const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');

  // Mobile-only one-card-at-a-time carousel treatment for visual card groups.
  const mobileCardMode = window.matchMedia('(max-width: 600px)');

  // On mobile, keep the Home video clean and place the service buttons immediately below it.
  const homeHero = document.querySelector('.home-page-hero');
  // Start a fresh Home navigation at the hero once. Never reset the user's
  // scroll position after loading media or while they are already browsing.
  if (homeHero && !window.location.hash) {
    if ('scrollRestoration' in history) history.scrollRestoration = 'manual';
    window.scrollTo({top: 0, left: 0, behavior: 'instant'});
  }
  const mobileCarouselSelectors = ['.hub-grid', '.panel-grid', '.clean-question-grid', '.story-grid', '.service-static-grid', '.county-cards'];

  function setupMobileCardCarousel(container) {
    if (!container || container.dataset.mobileCarouselReady === 'true') return;
    container.dataset.mobileCarouselReady = 'true';
    container.classList.add('mobile-card-carousel');
    const cards = [...container.children].filter(el => !el.classList.contains('mobile-card-nav'));
    if (cards.length < 2) return;
    const nav = document.createElement('div');
    nav.className = 'mobile-card-nav';
    nav.innerHTML = `<button type="button" class="mobile-card-prev" aria-label="Previous item">←</button><span class="mobile-card-count" aria-live="polite">1 of ${cards.length}</span><button type="button" class="mobile-card-next" aria-label="Next item">→</button>`;
    container.insertAdjacentElement('afterend', nav);
    const count = nav.querySelector('.mobile-card-count');
    const go = direction => {
      const index = Math.round(container.scrollLeft / Math.max(container.clientWidth, 1));
      const next = Math.max(0, Math.min(cards.length - 1, index + direction));
      container.scrollTo({left: next * container.clientWidth, behavior: reducedMotion.matches ? 'auto' : 'smooth'});
    };
    nav.querySelector('.mobile-card-prev').addEventListener('click', () => go(-1));
    nav.querySelector('.mobile-card-next').addEventListener('click', () => go(1));
    const update = () => {
      const index = Math.max(0, Math.min(cards.length - 1, Math.round(container.scrollLeft / Math.max(container.clientWidth, 1))));
      count.textContent = `${index + 1} of ${cards.length}`;
    };
    container.addEventListener('scroll', () => requestAnimationFrame(update), {passive:true});
    window.addEventListener('resize', update);
    update();
  }

  function initializeMobileCardCarousels() {
    if (!mobileCardMode.matches) return;
    document.querySelectorAll(mobileCarouselSelectors.join(',')).forEach(setupMobileCardCarousel);
    document.querySelectorAll('.service-carousel').forEach(carousel => {
      if (carousel.dataset.mobileNavReady === 'true') return;
      carousel.dataset.mobileNavReady = 'true';
      const cards = [...carousel.querySelectorAll('.service-card')];
      if (cards.length < 2) return;
      const nav = document.createElement('div');
      nav.className = 'mobile-card-nav';
      nav.innerHTML = `<button type="button" class="mobile-card-prev" aria-label="Previous service">←</button><span class="mobile-card-count" aria-live="polite">1 of ${cards.length}</span><button type="button" class="mobile-card-next" aria-label="Next service">→</button>`;
      carousel.insertAdjacentElement('afterend', nav);
      const count = nav.querySelector('.mobile-card-count');
      const go = direction => {
        const index = Math.round(carousel.scrollLeft / Math.max(carousel.clientWidth, 1));
        const next = Math.max(0, Math.min(cards.length - 1, index + direction));
        carousel.scrollTo({left: next * carousel.clientWidth, behavior: reducedMotion.matches ? 'auto' : 'smooth'});
      };
      nav.querySelector('.mobile-card-prev').addEventListener('click', () => go(-1));
      nav.querySelector('.mobile-card-next').addEventListener('click', () => go(1));
      const update = () => {
        const index = Math.max(0, Math.min(cards.length - 1, Math.round(carousel.scrollLeft / Math.max(carousel.clientWidth, 1))));
        count.textContent = `${index + 1} of ${cards.length}`;
      };
      carousel.addEventListener('scroll', () => requestAnimationFrame(update), {passive:true});
      window.addEventListener('resize', update);
      update();
    });
  }
  initializeMobileCardCarousels();
  mobileCardMode.addEventListener('change', initializeMobileCardCarousels);

  document.querySelectorAll('.hero > video').forEach(video => {
    video.muted = true;
    if (reducedMotion.matches) video.pause();
    else video.play().catch(() => {});
    const control = video.parentElement.querySelector('.video-toggle');
    const sync = () => {
      if (!control) return;
      control.textContent = video.paused ? 'Play video' : 'Pause video';
      control.setAttribute('aria-label', video.paused ? 'Play background video' : 'Pause background video');
    };
    control?.addEventListener('click', () => {
      if (video.paused) video.play().catch(() => {}); else video.pause();
    });
    video.addEventListener('play', sync);
    video.addEventListener('pause', sync);
    sync();
  });

  // Service photos move only when the visitor scrolls, swipes, or uses controls.
  document.querySelectorAll('.service-carousel').forEach(carousel => {
    carousel.querySelectorAll('img').forEach(img => { img.draggable = false; });
    carousel.addEventListener('keydown', event => {
      if (event.target !== carousel) return;
      if (event.key === 'ArrowRight' || event.key === 'ArrowLeft') {
        event.preventDefault();
        carousel.scrollBy({
          left: (event.key === 'ArrowRight' ? 1 : -1) * carousel.clientWidth * .8,
          behavior: reducedMotion.matches ? 'auto' : 'smooth'
        });
      }
    });
  });

  const PORTAL = '247103073';
  // Both entry points use the existing chat form, whose fields are contact properties.
  const QUOTE_FORM = 'b90d8e3d-5896-4bc1-b73a-69cdb94e51ec';
  const SUBMIT_URL = `https://api.hsforms.com/submissions/v3/integration/submit/${PORTAL}/${QUOTE_FORM}`;
  let transcript = '';
  let draftMessage = '';
  let chatForm;

  function makeQuoteForm(target, prefix, getContext = () => '') {
    target.innerHTML = `<form class="cleaning-quote-form" data-hubspot-form-id="${QUOTE_FORM}">
      <div class="quote-field"><label for="${prefix}-name">Name <span aria-hidden="true">*</span></label><input id="${prefix}-name" name="name" autocomplete="name" maxlength="200" required></div>
      <div class="quote-field"><label for="${prefix}-phone">Phone</label><input id="${prefix}-phone" name="phone" type="tel" autocomplete="tel" maxlength="80"></div>
      <div class="quote-field"><label for="${prefix}-email">Email <span aria-hidden="true">*</span></label><input id="${prefix}-email" name="email" type="email" autocomplete="email" maxlength="254" required></div>
      <div class="quote-field"><label for="${prefix}-message">Message <span aria-hidden="true">*</span></label><textarea id="${prefix}-message" name="message" rows="6" maxlength="20000" required></textarea></div>
      <p class="quote-error" role="alert" hidden></p><button class="button quote-submit" type="submit">Send My Request</button>
      <p class="quote-confirmation" role="status" tabindex="-1" hidden>Thank you. Your cleaning request has been sent. We’ll be in touch soon.</p>
    </form><p class="form-fallback">You can also call <a href="tel:8187465432">818-746-5432</a>.</p>`;
    const form = target.querySelector('form');
    const message = form.elements.message;
    form.addEventListener('submit', async event => {
      event.preventDefault();
      if (form.dataset.sending === 'true' || form.dataset.sent === 'true') return;
      for (const field of [form.elements.name, form.elements.email, message]) {
        field.value = field.value.trim();
      }
      if (!form.reportValidity()) return;
      const button = form.querySelector('.quote-submit');
      const error = form.querySelector('.quote-error');
      error.hidden = true;
      const names = form.elements.name.value.split(/\s+/);
      const fields = [
        {objectTypeId: '0-1', name: 'firstname', value: names.shift()},
        {objectTypeId: '0-1', name: 'lastname', value: names.join(' ')},
        {objectTypeId: '0-1', name: 'email', value: form.elements.email.value},
        {objectTypeId: '0-1', name: 'phone', value: form.elements.phone.value.trim()}
      ];
      const details = getContext();
      const value = details && !message.value.includes(details) ? `${message.value}\n\nCleaning details:\n${details}` : message.value;
      fields.push({objectTypeId: '0-1', name: 'message', value});
      const context = {
        pageUri: /^https?:$/.test(location.protocol) ? location.href.split('#')[0].split('?')[0] : document.querySelector('link[rel="canonical"]').href,
        pageName: document.title
      };
      form.dataset.sending = 'true';button.disabled = true;button.textContent = 'Sending…';
      const controller = new AbortController();
      const timeout = setTimeout(() => controller.abort(), 30000);
      try {
        const response = await fetch(SUBMIT_URL, {
          method: 'POST', headers: {'Content-Type': 'application/json'}, signal: controller.signal,
          body: JSON.stringify({fields, context, submittedAt: String(Date.now())})
        });
        if (!response.ok) {
          const result = await response.json().catch(() => ({}));
          if (response.status === 429) throw new Error('Please wait a moment before sending again. Your details are still here.');
          if (result.errors?.some(item => /EMAIL/.test(item.errorType || ''))) throw new Error('Please check your email address and try again.');
          throw new Error('Your request could not be sent. Please try again or call 818-746-5432.');
        }
        form.dataset.sent = 'true';
        form.querySelectorAll('.quote-field,.quote-submit').forEach(element => {element.hidden = true;});
        const confirmation = form.querySelector('.quote-confirmation');confirmation.hidden = false;confirmation.focus();
        form.dispatchEvent(new CustomEvent('quote:sent', {bubbles: true}));
      } catch (reason) {
        error.textContent = reason.name === 'AbortError' ? 'We couldn’t confirm delivery. Your details are still here. Please call 818-746-5432 if you need help.' : reason instanceof TypeError ? 'Please check your connection and try again. Your details are still here.' : reason.message;
        error.hidden = false;
      } finally {
        clearTimeout(timeout);form.dataset.sending = 'false';button.disabled = false;button.textContent = 'Send My Request';
      }
    });
    return {element: form, message};
  }
  const contact = document.querySelector('.hubspot-contact-form');
  if (contact) makeQuoteForm(contact, 'contact');

  function applyTranscript() {
    // The transcript is intentionally never rendered to the visitor.
    // It is submitted to HubSpot in the background as the Message property.
  }

  const config = window.PARADIGM_PAGE_CHAT || {source: location.pathname.split('/').pop() || 'contact.html', title: document.title, questions: []};
  // One approved quote flow everywhere on the site.
  config.questions = [
    'What type of property do you have?',
    'What are you looking to have done?',
    'What city is the property in?'
  ];
  const universalChoices = {
    'What type of property do you have?': ['Estate', 'Apartment Building', 'Office', 'Retail / Storefront', 'Restaurant', 'Warehouse / Industrial', 'Learning Facility', 'Construction Site', 'Other'],
    'What are you looking to have done?': ['Janitorial Cleaning', 'Porter Service', 'Power Washing', 'Window Cleaning', 'Floor Care', 'Move-In / Move-Out Cleaning', 'Post-Construction Cleaning', 'Other']
  };
  const multiSelectQuestions = new Set();
  const overlay = document.createElement('div');
  overlay.className = 'chat-overlay';
  overlay.innerHTML = `<div class="chat-panel ai-chat-panel" role="dialog" aria-modal="true" aria-labelledby="chat-brand" tabindex="-1">
    <div class="chat-top"><div class="chat-brand-lockup"><img class="chat-brand-logo" src="assets/images/paradigm-logo.png" alt="Paradigm Janitorial Services"><p class="chat-brand-name" id="chat-brand">Paradigm Janitorial Services</p></div><button type="button" class="chat-close" aria-label="Close chat">×</button></div>
    <div class="ai-chat-log" aria-live="polite"></div>
    <div class="ai-chat-composer"></div>
  </div>`;
  document.body.appendChild(overlay);
  const panel = overlay.querySelector('.chat-panel');
  const log = overlay.querySelector('.ai-chat-log');
  const composer = overlay.querySelector('.ai-chat-composer');
  let answers = [], step = 0, returnFocus = null, submitted = false;
  let contactName = '', contactPhone = '', contactEmail = '';
  let contactStep = 0;
  const background = [...document.querySelectorAll('body > header,body > main,body > footer,body > .skip-link')];

  const esc = value => String(value).replace(/[&<>"']/g, char => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[char]));
  const canonical = () => document.querySelector('link[rel="canonical"]')?.href || location.href.split('#')[0].split('?')[0];
  const buildTranscript = () => [`Page: ${config.title}`, `Source: ${canonical()}`, '', ...config.questions.flatMap((question, index) => [question, answers[index] || '', ''])].join('\n').trim();
  const scrollBottom = () => requestAnimationFrame(() => { log.scrollTop = log.scrollHeight; });
  const addBubble = (kind, text) => {
    const item = document.createElement('div');
    item.className = `ai-bubble ${kind}`;
    item.innerHTML = `<div class="ai-bubble-label">${kind === 'assistant' ? 'Paradigm' : 'You'}</div><div class="ai-bubble-text">${esc(text)}</div>`;
    log.appendChild(item); scrollBottom();
  };
  const resetLog = () => { log.innerHTML = ''; };
  const rebuildLog = () => {
    resetLog();
    for (let i = 0; i < step; i++) {
      addBubble('assistant', config.questions[i]);
      if (answers[i]) addBubble('user', answers[i]);
    }
  };
  const focusFirst = () => composer.querySelector('textarea,input,button')?.focus();

  const close = () => {
    overlay.classList.remove('open');
    document.body.classList.remove('chat-open');
    background.forEach(element => {element.inert = false;});
    returnFocus?.focus();
  };
  overlay.querySelector('.chat-close').addEventListener('click', close);
  overlay.addEventListener('click', event => {if (event.target === overlay) close();});
  overlay.addEventListener('keydown', event => {
    if (overlay.classList.contains('chat-embedded')) return;
    if (event.key === 'Escape') {event.preventDefault();close();return;}
    if (event.key !== 'Tab') return;
    const focusable = [...overlay.querySelectorAll('button,a,input,textarea,select,[tabindex="0"]')].filter(x => x.getClientRects().length && !x.disabled);
    const first = focusable[0], last = focusable[focusable.length - 1];
    if (event.shiftKey && document.activeElement === first) {event.preventDefault();last?.focus();}
    else if (!event.shiftKey && document.activeElement === last) {event.preventDefault();first?.focus();}
  });

  function renderQuestion(shouldFocus = true) {
    rebuildLog();
    addBubble('assistant', config.questions[step]);
    const question = config.questions[step];
    const choices = universalChoices[question];
    if (choices) {
      const isMulti = multiSelectQuestions.has(question);
      composer.innerHTML = `<div class="ai-choice-grid">${choices.map(choice => `<button type="button" class="button ai-choice" data-value="${esc(choice)}" aria-pressed="false">${esc(choice)}</button>`).join('')}</div><div class="ai-other-wrap" hidden><input class="ai-contact-input ai-other-input" type="text" maxlength="200" placeholder="Please specify"></div>${isMulti ? '<button type="button" class="button ai-choice-continue">Continue</button>' : ''}${step ? '<button type="button" class="chat-back ai-back">Back</button>' : ''}`;
      const otherWrap = composer.querySelector('.ai-other-wrap');
      const otherInput = composer.querySelector('.ai-other-input');
      if (isMulti) {
        const selected = new Set((answers[step] || '').split(', ').filter(Boolean));
        composer.querySelectorAll('.ai-choice').forEach(button => {
          if (selected.has(button.dataset.value)) { button.classList.add('selected'); button.setAttribute('aria-pressed','true'); }
          button.addEventListener('click', () => {
            const value = button.dataset.value;
            if (selected.has(value)) selected.delete(value); else selected.add(value);
            button.classList.toggle('selected', selected.has(value)); button.setAttribute('aria-pressed', selected.has(value) ? 'true' : 'false');
            if (value === 'Other') otherWrap.hidden = !selected.has('Other');
          });
        });
        composer.querySelector('.ai-choice-continue').addEventListener('click', () => {
          if (!selected.size) return;
          let vals = [...selected];
          if (selected.has('Other') && otherInput.value.trim()) vals = vals.map(v => v === 'Other' ? `Other: ${otherInput.value.trim()}` : v);
          const value = vals.join(', '); answers[step] = value; addBubble('user', value); step++;
          if (step < config.questions.length) renderQuestion(); else renderContact();
        });
      } else {
        composer.querySelectorAll('.ai-choice').forEach(button => button.addEventListener('click', () => {
          const value = button.dataset.value;
          if (value === 'Other') {
            // Other is the only choice that needs a typed detail before advancing.
            composer.innerHTML = `<label class="ai-other-question" for="ai-other-detail">What do you need cleaned?</label><input id="ai-other-detail" class="ai-contact-input ai-other-input" type="text" maxlength="200"><button type="button" class="button ai-other-next">Next</button><button type="button" class="chat-back ai-other-cancel">Back</button>`;
            const detailInput = composer.querySelector('#ai-other-detail');
            const submitOther = () => {
              const detail = detailInput.value.trim();
              if (!detail) { detailInput.focus(); return; }
              answers[step] = `Other: ${detail}`;
              addBubble('user', answers[step]);
              step++;
              if (step < config.questions.length) renderQuestion(); else renderContact();
            };
            composer.querySelector('.ai-other-next').addEventListener('click', submitOther);
            composer.querySelector('.ai-other-cancel').addEventListener('click', renderQuestion);
            detailInput.addEventListener('keydown', event => {
              if (event.key === 'Enter') { event.preventDefault(); submitOther(); }
            });
            detailInput.focus();
            return;
          }
          answers[step] = value; addBubble('user', value); step++;
          if (step < config.questions.length) renderQuestion(); else renderContact();
        }));
      }
    } else {
      composer.innerHTML = `<div class="ai-composer-row"><textarea class="chat-input ai-chat-input" rows="2" maxlength="4000" placeholder="Type your answer…"></textarea><button type="button" class="button ai-send">Send</button></div><p class="chat-form-error" role="status" hidden></p>${step ? '<button type="button" class="chat-back ai-back">Back</button>' : ''}`;
      const input = composer.querySelector('.ai-chat-input');
      input.value = answers[step] || '';
      const send = () => {
        const value = input.value.trim();
        if (!value) {
          const error = composer.querySelector('.chat-form-error'); error.textContent = 'Add a few details so we can keep going.'; error.hidden = false; input.focus(); return;
        }
        answers[step] = value; addBubble('user', value); step++;
        if (step < config.questions.length) renderQuestion(); else renderContact();
      };
      composer.querySelector('.ai-send').addEventListener('click', send);
      input.addEventListener('keydown', event => { if (event.key === 'Enter' && !event.shiftKey) { event.preventDefault(); send(); } });
    }
    composer.querySelector('.ai-back')?.addEventListener('click', () => { if (step > 0) { step--; renderQuestion(); } });
    if (shouldFocus) focusFirst();
  }

  let contactMethod = '';
  function renderContact() {
    resetLog();
    config.questions.forEach((question, index) => { addBubble('assistant', question); addBubble('user', answers[index] || ''); });
    if (contactName) { addBubble('assistant', "Great. What's your name?"); addBubble('user', contactName); }
    if (contactStep >= 1 && !contactName) contactStep = 0;

    if (contactStep === 0) {
      addBubble('assistant', "Great. What's your name?");
      composer.innerHTML = `<div class="ai-composer-row"><input class="ai-contact-input" type="text" autocomplete="name" placeholder="Your name" value="${esc(contactName)}"><button type="button" class="button ai-send">Continue</button></div><p class="chat-form-error" role="status" hidden></p><button type="button" class="chat-back ai-back">Back</button>`;
      const input = composer.querySelector('.ai-contact-input');
      const next = () => {
        const value = input.value.trim();
        if (!value) { const error=composer.querySelector('.chat-form-error'); error.textContent='Please add your name to continue.'; error.hidden=false; input.focus(); return; }
        contactName = value; contactStep = 1; renderContact();
      };
      composer.querySelector('.ai-send').addEventListener('click', next);
      input.addEventListener('keydown', event => { if (event.key === 'Enter') { event.preventDefault(); next(); } });
      composer.querySelector('.ai-back').addEventListener('click', () => { step = config.questions.length - 1; renderQuestion(); });
      focusFirst(); return;
    }

    addBubble('assistant', "What's the best way for us to get back to you?");
    if (contactStep === 1) {
      composer.innerHTML = `<div class="ai-choice-grid"><button type="button" class="button ai-choice" data-contact="phone">Phone</button><button type="button" class="button ai-choice" data-contact="email">Email</button></div><button type="button" class="chat-back ai-back">Back</button>`;
      composer.querySelectorAll('[data-contact]').forEach(button => button.addEventListener('click', () => { contactMethod = button.dataset.contact; contactStep = 2; renderContact(); }));
      composer.querySelector('.ai-back').addEventListener('click', () => { contactName=''; contactStep=0; renderContact(); });
      focusFirst(); return;
    }

    addBubble('user', contactMethod === 'phone' ? 'Phone' : 'Email');
    const isPhone = contactMethod === 'phone';
    const prompt = isPhone ? "What's the best phone number to reach you?" : "What's the best email address to reach you?";
    addBubble('assistant', prompt);
    const current = isPhone ? contactPhone : contactEmail;
    composer.innerHTML = `<div class="ai-composer-row"><input class="ai-contact-input" type="${isPhone ? 'tel' : 'email'}" autocomplete="${isPhone ? 'tel' : 'email'}" placeholder="${isPhone ? 'Phone number' : 'Email address'}" value="${esc(current)}"><button type="button" class="button ai-send">Submit</button></div><p class="chat-form-error" role="status" hidden></p><button type="button" class="chat-back ai-back">Back</button>`;
    const input = composer.querySelector('.ai-contact-input');
    const send = async () => {
      const value = input.value.trim();
      if (!value) { const error=composer.querySelector('.chat-form-error'); error.textContent=`Please add your ${isPhone ? 'phone number' : 'email address'} to continue.`; error.hidden=false; input.focus(); return; }
      if (!isPhone && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) { const error=composer.querySelector('.chat-form-error'); error.textContent='Please enter a valid email address.'; error.hidden=false; input.focus(); return; }
      if (isPhone) { contactPhone=value; contactEmail=''; } else { contactEmail=value; contactPhone=''; }
      await submitChatRequest();
    };
    composer.querySelector('.ai-send').addEventListener('click', send);
    input.addEventListener('keydown', event => { if (event.key === 'Enter') { event.preventDefault(); send(); } });
    composer.querySelector('.ai-back').addEventListener('click', () => { contactStep=1; renderContact(); });
    focusFirst();
  }

  async function submitChatRequest() {
    if (submitted) return;
    const sendButton = composer.querySelector('.ai-send');
    if (sendButton?.disabled) return;
    if (sendButton) { sendButton.disabled = true; sendButton.textContent = 'Sending…'; }
    const names = contactName.trim().split(/\s+/);
    // Only submit the contact method the visitor actually chose. Sending an
    // empty email/phone value can be rejected by HubSpot field validation.
    const fields = [
      {objectTypeId:'0-1', name:'firstname', value:names.shift() || ''},
      {objectTypeId:'0-1', name:'lastname', value:names.join(' ')},
      {objectTypeId:'0-1', name:'message', value:buildTranscript()}
    ];
    if (contactMethod === 'phone' && contactPhone.trim()) {
      fields.push({objectTypeId:'0-1', name:'phone', value:contactPhone.trim()});
    }
    if (contactMethod === 'email' && contactEmail.trim()) {
      fields.push({objectTypeId:'0-1', name:'email', value:contactEmail.trim()});
    }
    const context = {pageUri: canonical(), pageName: document.title};
    try {
      const response = await fetch(SUBMIT_URL, {method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify({fields, context, submittedAt:String(Date.now())})});
      if (!response.ok) {
        const result = await response.json().catch(() => ({}));
        const errors = Array.isArray(result.errors) ? result.errors : [];
        const invalidEmail = errors.some(item => /email/i.test(JSON.stringify(item)));
        if (contactMethod === 'email' && invalidEmail) {
          throw new Error('Please check the email address and try again.');
        }
        throw new Error('We couldn’t send that just yet. Please try again or call 818-746-5432.');
      }
      submitted = true; resetLog();
      addBubble('assistant', `Thanks, ${contactName.split(/\s+/)[0] || 'there'}. We have your cleaning details and will be in touch soon.`);
      composer.innerHTML = `<div class="ai-chat-finished"><a class="button" href="tel:8187465432">Call 818-746-5432</a><button type="button" class="chat-back ai-close-finished">Close</button></div>`;
      composer.querySelector('.ai-close-finished').addEventListener('click', close);
    } catch (error) {
      const msg = composer.querySelector('.chat-form-error');
      if (msg) { msg.textContent = error.message; msg.hidden = false; }
      if (sendButton) { sendButton.disabled=false; sendButton.textContent='Submit'; }
    }
  }
  // On the Contact/Get a Quote page, replace the old form area with the same chat already open.
  const quoteSection = document.querySelector('#quote-form');
  if (quoteSection && document.body.classList.contains('page-contact')) {
    const wrap = quoteSection.querySelector('.form-wrap');
    if (wrap) {
      wrap.innerHTML = '';
      overlay.classList.add('open', 'chat-embedded');
      panel.querySelector('.chat-close')?.remove();
      wrap.appendChild(overlay);
      panel.removeAttribute("aria-modal");
      panel.setAttribute("role", "region");
      renderQuestion(false);
    }
  }

  document.querySelectorAll('.open-page-chat').forEach(button => {
    button.setAttribute('aria-haspopup', 'dialog');
    button.addEventListener('click', () => {
      returnFocus = button;
      closeMenu();
      overlay.classList.add('open');document.body.classList.add('chat-open');
      background.forEach(element => {element.inert = true;});
      if (submitted) {
        resetLog();
        addBubble('assistant', `Thanks, ${contactName.split(/\s+/)[0] || 'there'}. We have your cleaning details and will be in touch soon.`);
        composer.innerHTML = `<div class="ai-chat-finished"><a class="button" href="tel:8187465432">Call 818-746-5432</a><button type="button" class="chat-back ai-close-finished">Close</button></div>`;
        composer.querySelector('.ai-close-finished').addEventListener('click', close);
      } else if (step >= config.questions.length) {
        renderContact();
      } else {
        renderQuestion();
      }
      panel.focus();
    });
  });
})();
