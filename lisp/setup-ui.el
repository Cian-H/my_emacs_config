;;; setup-ui.el --- Visual and UI settings -*- lexical-binding: t; -*-

;; Set default frame parameters (clean background, no scrollbars)
(setq-default frame-title-format '("%b - Emacs"))
(setq ring-bell-function 'ignore) ; Silence bells

;; Install and load doom-themes for Tokyonight Night
(use-package doom-themes
  :ensure t
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-tokyo-night t)
  
  ;; Customizations for modeline, visual bell, and org-mode
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

;; Install nerd-icons for the modeline and dashboard
(use-package nerd-icons
  :ensure t)

;; Modeline: beautiful, thin status line mirroring lualine.nvim
(use-package doom-modeline
  :ensure t
  :config
  (doom-modeline-mode 1)
  (setq doom-modeline-height 25
        doom-modeline-bar-width 4
        doom-modeline-icon t
        doom-modeline-major-mode-icon t
        doom-modeline-buffer-state-icon t
        doom-modeline-indent-info t
        doom-modeline-buffer-file-name-style 'truncate-nil))

;; Dashboard: elegant startup page mirroring mini.starter
(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-startup-banner 'official
        dashboard-center-content t
        dashboard-show-shortcuts nil
        dashboard-items '((recents  . 5)
                          (projects . 5)
                          (bookmarks . 5)))
  (setq dashboard-set-heading-icons t
        dashboard-set-file-icons t
        dashboard-banner-logo-title "Welcome to Emacs - Custom Neovim Mirror"
        dashboard-footer-messages '("Press Space in normal mode for keybind options.")
        dashboard-footer-icon (nerd-icons-octicon "nf-oct-terminal" :height 1.1 :face 'font-lock-keyword-face)))

;; Font configuration - attempt to load common high-quality developer fonts
(defun my/configure-font ()
  (let ((font-families '("JetBrains Mono" "Fira Code" "Hack" "SF Mono" "Source Code Pro" "Monospace"))
        (found-font nil))
    (while (and font-families (not found-font))
      (let ((family (car font-families)))
        (if (member family (font-family-list))
            (progn
              (set-face-attribute 'default nil :font (font-spec :family family :size 11))
              (setq found-font t))
          (setq font-families (cdr font-families)))))))

;; Run font config on frame creation or directly if running in graphical mode
(if (daemonp)
    (add-hook 'after-make-frame-functions
              (lambda (frame)
                (with-selected-frame frame
                  (my/configure-font))))
  (my/configure-font))

(provide 'setup-ui)
