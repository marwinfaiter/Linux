(require 'org)
(org-babel-load-file (expand-file-name (concat user-emacs-directory "emacsinit.org")))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ad-redefinition-action (quote accept))
 '(custom-enabled-themes (quote (spacemacs-dark)))
 '(custom-safe-themes
   (quote
    ("56ffe2e4a924e2f5190055c8ef993fadba9a0329ece7be566d1a1b8e5a9c775b" "11e57648ab04915568e558b77541d0e94e69d09c9c54c06075938b6abc0189d8" "fa2b58bb98b62c3b8cf3b6f02f058ef7827a8e497125de0254f56e373abee088" "78cb3874ba79a3ff53ba2e7aafc40e4567120848f947e3816464f3f01cf49aa1" "bffa9739ce0752a37d9b1eee78fc00ba159748f50dc328af4be661484848e476" default)))
 '(ediff-diff-options "-w")
 '(ediff-split-window-function (quote split-window-horizontally))
 '(ediff-window-setup-function (quote ediff-setup-windows-plain))
 '(neo-smart-open t t)
 '(neo-theme (quote arrow) t)
 '(package-selected-packages
   (quote
    (spacemacs-theme which-key toc-org smooth-scrolling rainbow-delimiters quelpa-use-package projectile paradox ox-reveal org-bullets neotree molokai-theme magit ido-completing-read+ htmlize eyebrowse evil-surround evil-org evil-numbers evil-nerd-commenter evil-multiedit evil-leader evil-ediff evil-cleverparens doom-themes doom-modeline counsel company auto-indent-mode auto-complete auto-compile ace-window)))
 '(paradox-github-token t)
 '(projectile-switch-project-action (quote neotree-projectile-action))
 '(read-buffer-completion-ignore-case t)
 '(read-file-name-completion-ignore-case t)
 '(use-package-always-ensure t)
 '(use-package-verbose nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(aw-leading-char-face ((t (:inherit ace-jump-face-foreground :height 3.0)))))
