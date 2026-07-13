;;; init.el --- Configuration entry point -*- lexical-binding: t; -*-

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

(xterm-mouse-mode 1)
(setq select-enable-clipboard t)

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Ensure package archives are populated on first launch
(unless (file-exists-p (expand-file-name "elpa/archives/melpa" user-emacs-directory))
  (package-refresh-contents))
(package-read-all-archive-contents)

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(setq backup-directory-alist `(("." . ,(expand-file-name "backups" user-emacs-directory)))
      auto-save-file-name-transforms `((".*" ,(expand-file-name "auto-saves" user-emacs-directory) t))
      create-lockfiles nil)

(use-package gcmh
  :init
  (setq gcmh-idle-delay 'auto
        gcmh-auto-idle-delay-factor 10
        gcmh-high-cons-threshold 33554432) ; 32MB during idle
  :config
  (gcmh-mode 1))

(require 'setup-evil)
(require 'setup-ui)
(require 'setup-completion)
(require 'setup-editor)
(require 'setup-lsp)
(require 'setup-git)
(require 'setup-org)
(require 'setup-lisp)

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

(provide 'init)
