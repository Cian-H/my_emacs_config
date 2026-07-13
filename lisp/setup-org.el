;;; setup-org.el --- Org Mode configurations -*- lexical-binding: t; -*-

(use-package org
  :ensure t
  :config
  ;; Define agenda files and default notes file matching Neovim config
  (setq org-agenda-files '("~/orgfiles/"))
  (setq org-default-notes-file "~/orgfiles/refile.org")
  
  ;; Make sure orgfiles directory exists
  (unless (file-exists-p "~/orgfiles/")
    (make-directory "~/orgfiles/" t)))

;; Install org-bullets for modern visual appearance
(use-package org-bullets
  :ensure t
  :hook (org-mode . org-bullets-mode))

;; Define keybindings using general.el (similar to setup-evil.el and setup-editor.el)
(with-eval-after-load 'general
  (my-leader-def
   "a" '(:ignore t :which-key "Agenda/Org Mode")
   "aa" 'org-agenda
   "ac" 'org-capture))

(provide 'setup-org)
