;;; early-init.el --- Early initialization settings -*- lexical-binding: t; -*-

(setq gc-cons-threshold 100000000 ; 100MB
      gc-cons-percentage 0.6)

(defvar my-saved-file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold 16777216 ; 16MB
                  gc-cons-percentage 0.1
                  file-name-handler-alist my-saved-file-name-handler-alist)
            (garbage-collect)))

(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(push '(horizontal-scroll-bars) default-frame-alist)

(setq inhibit-startup-screen t
      inhibit-startup-echo-area-message t
      inhibit-startup-buffer-menu t)

(setq package-enable-at-startup nil)

(provide 'early-init)
