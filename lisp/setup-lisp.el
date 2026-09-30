;;; setup-lisp.el --- Lisp, Fennel, and Lispy configuration -*- lexical-binding: t; -*-

;; Install fennel-mode for Fennel support
(use-package fennel-mode
  :ensure t
  :mode "\\.fnl\\'")

;; Install lispy for structural editing of Lisp dialects
(use-package lispy
  :ensure t
  :hook ((emacs-lisp-mode
          lisp-mode
          scheme-mode
          clojure-mode
          fennel-mode) . lispy-mode))

;; Install lispyville for evil-mode integration with lispy
(use-package lispyville
  :ensure t
  :hook ((lisp-data-mode . lispyville-mode))
  :config
  (lispyville-set-keytheme '(operators c-w additional)))

(provide 'setup-lisp)
