
;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(require 'org)
(org-babel-load-file (expand-file-name (concat user-emacs-directory "emacsinit.org")))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ad-redefinition-action (quote accept))
 '(company-quickhelp-color-background "#4F4F4F")
 '(company-quickhelp-color-foreground "#DCDCCC")
 '(custom-enabled-themes (quote (spacemacs-dark)))
 '(custom-safe-themes
   (quote
    ("c7f10959cb1bc7a36ee355c765a1768d48929ec55dde137da51077ac7f899521" "2d835b43e2614762893dc40cbf220482d617d3d4e2c35f7100ca697f1a388a0e" "7aaee3a00f6eb16836f5b28bdccde9e1079654060d26ce4b8f49b56689c51904" "56ffe2e4a924e2f5190055c8ef993fadba9a0329ece7be566d1a1b8e5a9c775b" "11e57648ab04915568e558b77541d0e94e69d09c9c54c06075938b6abc0189d8" "fa2b58bb98b62c3b8cf3b6f02f058ef7827a8e497125de0254f56e373abee088" "78cb3874ba79a3ff53ba2e7aafc40e4567120848f947e3816464f3f01cf49aa1" "bffa9739ce0752a37d9b1eee78fc00ba159748f50dc328af4be661484848e476" default)))
 '(ediff-diff-options "-w")
 '(ediff-split-window-function (quote split-window-horizontally))
 '(ediff-window-setup-function (quote ediff-setup-windows-plain))
 '(fci-rule-color "#383838")
 '(neo-smart-open t t)
 '(neo-theme (quote arrow) t)
 '(nrepl-message-colors
   (quote
    ("#CC9393" "#DFAF8F" "#F0DFAF" "#7F9F7F" "#BFEBBF" "#93E0E3" "#94BFF3" "#DC8CC3")))
 '(package-selected-packages
   (quote
    (spacemacs-theme which-key toc-org smooth-scrolling rainbow-delimiters quelpa-use-package projectile paradox ox-reveal org-bullets neotree molokai-theme magit ido-completing-read+ htmlize eyebrowse evil-surround evil-org evil-numbers evil-nerd-commenter evil-multiedit evil-leader evil-ediff evil-cleverparens doom-themes doom-modeline counsel company auto-indent-mode auto-complete auto-compile ace-window)))
 '(paradox-github-token t)
 '(projectile-switch-project-action (quote neotree-projectile-action))
 '(read-buffer-completion-ignore-case t)
 '(read-file-name-completion-ignore-case t)
 '(use-package-always-ensure t)
 '(use-package-verbose nil)
 '(vc-annotate-background "#2B2B2B")
 '(vc-annotate-color-map
   (quote
    ((20 . "#BC8383")
     (40 . "#CC9393")
     (60 . "#DFAF8F")
     (80 . "#D0BF8F")
     (100 . "#E0CF9F")
     (120 . "#F0DFAF")
     (140 . "#5F7F5F")
     (160 . "#7F9F7F")
     (180 . "#8FB28F")
     (200 . "#9FC59F")
     (220 . "#AFD8AF")
     (240 . "#BFEBBF")
     (260 . "#93E0E3")
     (280 . "#6CA0A3")
     (300 . "#7CB8BB")
     (320 . "#8CD0D3")
     (340 . "#94BFF3")
     (360 . "#DC8CC3"))))
 '(vc-annotate-very-old-color "#DC8CC3"))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(aw-leading-char-face ((t (:inherit ace-jump-face-foreground :height 3.0)))))
