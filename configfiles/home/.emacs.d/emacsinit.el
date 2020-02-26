(setq inhibit-startup-message t)
(tool-bar-mode -1)
(menu-bar-mode -1)
(fset 'yes-or-no-p 'y-or-n-p)

(setq make-backup-files nil)
(setq auto-save-default nil)

(customize-set-variable 'ad-redefinition-action 'accept)

(require 'package)
(setq package-check-signature nil)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives
            '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives
            '("org" . "https://orgmode.org/elpa/"))
(package-initialize)

(when (not package-archive-contents)
(package-refresh-contents))

(when (not (package-installed-p 'use-package))
(package-install 'use-package))

(require 'use-package)
(customize-set-variable 'use-package-always-ensure t)
(customize-set-variable 'use-package-verbose nil)

(add-to-list 'load-path "~/.emacs.d/lisp")

(use-package saveplace
:ensure t)
:config
(save-place-mode)

(use-package smooth-scrolling
:config
(smooth-scrolling-mode 1))

(require 'bind-key)
(bind-key (kbd "<f5>") 'revert-buffer)

(use-package company
:diminish company-mode
:hook
(after-init . global-company-mode))

(setq completion-ignore-case t)
(customize-set-variable 'read-file-name-completion-ignore-case t)
(customize-set-variable 'read-buffer-completion-ignore-case t)

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

(use-package cperl-mode
:ensure t
:mode "\\.p[lm]\\'"
:interpreter "perl"
:config
(setq cperl-hairy t))

(custom-set-variables
'(ediff-diff-options "-w")
'(ediff-split-window-function (quote split-window-horizontally))
'(ediff-window-setup-function (quote ediff-setup-windows-plain)))

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

(use-package evil-org
:ensure t
:after org
:config
(add-hook 'org-mode-hook 'evil-org-mode)
(add-hook 'evil-org-mode-hook
(lambda ()
(evil-org-set-key-theme)))
(require 'evil-org-agenda)
(evil-org-agenda-set-keys))

(use-package counsel
    :ensure t)

(use-package ido
:ensure t
:config
(ido-mode t)
(ido-everywhere 1)
(setq ido-use-virtual-buffers t)
(setq ido-enable-flex-matching t)
(setq ido-use-filename-at-point nil)
(setq ido-auto-merge-work-directories-length -1))

(use-package ido-completing-read+
:ensure t
:config
(ido-ubiquitous-mode 1))

(use-package swiper
:ensure t
:config
(defun custom-find-file ()
"Uses projectile if in a git repo, otherwise ido"
(interactive)
(let ((project-dir (projectile-project-root)))
(if project-dir
(progn
(projectile-find-file))
(ido-find-file))))

:bind
(("C-s" . swiper)
("C-r" . swiper)
("C-c C-r" . ivy-resume)
("M-x" . counsel-M-x)
("C-x C-f" . custom-find-file))
:config
(ivy-mode 1)
(setq ivy-use-virtual-buffers t)
(setq ivy-display-style 'fancy)
(define-key read-expression-map (kbd "C-r") 'counsel-expression-history))

(use-package hl-line
:ensure t
:config
(global-hl-line-mode))

(use-package iedit
:config
(set-face-background 'iedit-occurrence "Magenta")
:bind
("C-x M-r" . iedit-mode))

(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq indent-line-function 'insert-tab)

;(use-package auto-indent-mode
;:ensure t
;:config
;(auto-indent-global-mode))

(global-linum-mode)

(use-package magit
:diminish auto-revert-mode
:bind
(("C-x g" . magit-status)
:map magit-status-mode-map
("q"       . magit-quit-session))
:config
(defadvice magit-status (around magit-fullscreen activate)
"Make magit-status run alone in a frame."
(window-configuration-to-register :magit-fullscreen)
ad-do-it
(delete-other-windows))

(defun magit-quit-session ()
"Restore the previous window configuration and kill the magit buffer."
(interactive)
(kill-buffer)
(jump-to-register :magit-fullscreen)))

(use-package evil-multiedit
:ensure t
:config
(evil-multiedit-default-keybinds))

(use-package neotree
:ensure t
:custom
(neo-theme (if (display-graphic-p) 'icons 'arrow))
(neo-smart-open t)
(projectile-switch-project-action 'neotree-projectile-action)
:config
(setq-default neo-show-hidden-files t)
(defun neotree-project-dir ()
"Open NeoTree using the git root."
(interactive)
(let ((project-dir (projectile-project-root))
(file-name (buffer-file-name)))
(neotree-toggle)
(if project-dir
  (if (neo-global--window-exists-p)
    (progn
    (neotree-dir project-dir)
    (neotree-find file-name)))
    (message "Could not find git project root."))))
:bind
([f8] . neotree-project-dir))

(setq require-final-newline t)

(use-package org-bullets
:after org
:hook
(org-mode . (lambda () (org-bullets-mode 1))))
(defun zz/org-reformat-buffer ()
(interactive)
(when (y-or-n-p "Really format current buffer? ")
(let ((document (org-element-interpret-data (org-element-parse-buffer))))
(erase-buffer)
(insert document)
(goto-char (point-min)))))

(use-package ox-reveal
:ensure t)

(setq org-reveal-root "http://cdn.jsdeliver.net/npm/reveal.js/")
(setq org-reveal-mathjax t)

(use-package htmlize
:ensure t)

(use-package toc-org
:after org
:hook
(org-mode . toc-org-enable))

(use-package paradox
:custom
(paradox-github-token t)
:config
(paradox-enable))

(setq evil-normal-state-tag "NORMAL")
(setq evil-insert-state-tag "INSERT")
(setq evil-visual-state-tag "VISUAL")

(use-package projectile
:diminish projectile-mode
:config
(projectile-global-mode))

(use-package smartparens-config
:ensure smartparens
:config
(show-smartparens-global-mode t))

(add-hook 'prog-mode-hook 'turn-on-smartparens-mode)
(add-hook 'markdown-mode-hook 'turn-on-smartparens-mode)

(use-package rainbow-delimiters
:ensure t
:config
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode))

(show-paren-mode 1)

(use-package flyspell
:ensure t
:defer 1
:diminish)

(use-package doom-themes
:ensure t)

(use-package undo-tree
:ensure t)

(use-package which-key
:diminish which-key-mode
:config
(which-key-mode))

(setq-default show-trailing-whitespace t)
