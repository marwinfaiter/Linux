(setq inhibit-startup-message t)
(tool-bar-mode -1)
(menu-bar-mode -1)
(fset 'yes-or-no-p 'y-or-n-p)
(global-set-key (kbd "<f5>") 'revert-buffer)

(setq make-backup-files nil)
(use-package saveplace
    :init (save-place-mode))
    :ensure t
(setq auto-save-default nil)

(use-package which-key
  :ensure t
  :config
  (which-key-mode))

(use-package ox-reveal
:ensure t)

(setq org-reveal-root "http://cdn.jsdeliver.net/npm/reveal.js/")
(setq org-reveal-mathjax t)

(use-package htmlize
   :ensure t)

(use-package evil
:ensure t
:config
(global-evil-leader-mode)
(evil-mode 1))

(use-package evil-numbers
:ensure t
:config
(global-set-key (kbd "C-c +") 'evil-numbers/inc-at-pt)
(global-set-key (kbd "C-c -") 'evil-numbers/dec-at-pt))

(use-package evil-surround
:ensure t
:config
(global-evil-surround-mode 1))

(use-package evil-nerd-commenter
:ensure t)

(use-package evil-multiedit
:ensure t)

(use-package evil-leader
:ensure t)

(use-package evil-ediff
:ensure t)

(use-package evil-cleverparens
:ensure t)

(use-package doom-modeline
:ensure t
:init
(doom-modeline-mode 1))

(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq indent-line-function 'insert-tab)

(define-key evil-insert-state-map (kbd "TAB") 'tab-to-tab-stop)

(use-package auto-indent-mode
:ensure t
:config
(auto-indent-global-mode))

;(require 'autopair)
;(autopair-global-mode) ;; enable autopair in all buffers
(use-package smartparens-config
:ensure smartparens
:config
(show-smartparens-global-mode t))

(add-hook 'prog-mode-hook 'turn-on-smartparens-strict-mode)
(add-hook 'markdown-mode-hook 'turn-on-smartparens-strict-mode)

(use-package rainbow-delimiters
:ensure t
:config
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode))

(show-paren-mode 1)

(global-linum-mode)

;(require 'org-tempo)
(use-package org-bullets
    :ensure t
    :config
    (add-hook 'org-mode-hook(lambda () (org-bullets-mode 1 ))))

(evil-define-key 'normal org-mode-map (kbd "TAB") #'org-cycle)

(custom-set-variables
 '(ediff-diff-options "-w")
    '(ediff-split-window-function (quote split-window-horizontally))
    '(ediff-window-setup-function (quote ediff-setup-windows-plain)))

(defalias 'list-buffers 'ibuffer)

(use-package ace-window
:ensure t
:init
(global-set-key [remap other-window] 'ace-window)
(custom-set-faces
'(aw-leading-char-face
    ((t (:inherit ace-jump-face-foreground :height 3.0)))))
)

(use-package eyebrowse
:ensure t
:config
(eyebrowse-mode t)
(eyebrowse-setup-opinionated-keys))

(use-package neotree
:ensure t
:bind ([f8] . neotree-toggle)
:config
(setq neo-default-system-application "open")
(setq-default neo-show-hidden-files t))

(use-package counsel
  :ensure t
)

(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode 1)

(use-package swiper
:ensure t
:bind (("C-s" . swiper)
    ("C-r" . swiper)
    ("C-c C-r" . ivy-resume)
    ("M-x" . counsel-M-x)
    ("C-x C-f" . ido-find-file))
:config
    (ivy-mode 1)
    (setq ivy-use-virtual-buffers t)
    (setq ivy-display-style 'fancy)
    (define-key read-expression-map (kbd "C-r") 'counsel-expression-history)
    )

(use-package auto-complete
:ensure t
:init
(ac-config-default)
(global-auto-complete-mode t)
)

(setq require-final-newline t)

(use-package evil-multiedit
:ensure t
:config
(evil-multiedit-default-keybinds))

(use-package magit
:ensure t
:bind
("C-x g" . magit-status))

(setq-default show-trailing-whitespace t)

;(require 'powerline)
;(powerline-evil-vim-color-theme)
(setq evil-normal-state-tag "NORMAL")
(setq evil-insert-state-tag "INSERT")
(setq evil-visual-state-tag "VISUAL")
